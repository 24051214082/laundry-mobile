import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_page.dart';
import 'user_profile_store.dart';
import 'user_session.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const button = Color(0xFF263F73);
  static const border = Color(0xFFBDBDBD);
  static const infoBg = Color(0xFFD9D2FB);
  static const infoIcon = Color(0xFF5B429A);
}

class CostItem {
  final String label;
  final String amount;

  const CostItem(this.label, this.amount);
}

class OrderSummary {
  final String jenisLaundry;
  final String kecepatan;
  final String pengerjaan;
  final String deterjen;
  final String pewangi;
  final String metode;
  final String pickupMethod;
  final String deliveryMethod;
  final String jadwal;
  final String alamat;
  final String catatan;
  final int weightOrQty;
  final int estimatedTotal;
  final List<CostItem> biaya;
  final String subtotal;

  const OrderSummary({
    required this.jenisLaundry,
    required this.kecepatan,
    required this.pengerjaan,
    required this.deterjen,
    required this.pewangi,
    required this.metode,
    this.pickupMethod = '',
    this.deliveryMethod = '',
    required this.jadwal,
    required this.alamat,
    this.catatan = '',
    this.weightOrQty = 1,
    this.estimatedTotal = 0,
    this.biaya = const [],
    this.subtotal = '',
  });

  /// Data contoh jika halaman dibuka tanpa arguments.
  static const OrderSummary dummy = OrderSummary(
    jenisLaundry: 'Laundry Kiloan',
    kecepatan: 'Express',
    pengerjaan: 'Cuci + Setrika',
    deterjen: 'Rinso Gentle',
    pewangi: 'Molto Floral',
    metode: 'Jemput: Penjemputan • Kirim: Diantar Kurir',
    pickupMethod: 'Penjemputan',
    deliveryMethod: 'Diantar Kurir',
    jadwal: '22 Oktober 2026, 08:00 WIB',
    alamat: 'Jl. Ketintang Baru No. 12, Surabaya',
    weightOrQty: 7,
    estimatedTotal: 20000,
  );
}

class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({super.key});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isSubmitting = false;

  String _resolvePickupMethod(OrderSummary s) {
    if (s.pickupMethod.trim().isNotEmpty) return s.pickupMethod.trim();
    if (s.metode.contains('Antar Sendiri')) return 'Antar Sendiri';
    return 'Penjemputan';
  }

  String _resolveDeliveryMethod(OrderSummary s) {
    if (s.deliveryMethod.trim().isNotEmpty) return s.deliveryMethod.trim();
    if (s.metode.contains('Ambil Sendiri')) return 'Ambil Sendiri';
    return 'Diantar Kurir';
  }

  String _normalizeTreatment(String raw) {
    final trimmed = raw.trim();
    if (trimmed.toLowerCase() == 'cuci saja') return 'Cuci Saja';
    return trimmed;
  }

  int _parseRupiahToInt(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  String _formatRupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  String _resolveCustomerName(User? currentUser) {
    final sessionName = UserSession.name?.trim();
    if (sessionName != null && sessionName.isNotEmpty) {
      return sessionName;
    }

    final storeName = UserProfileStore.instance.name.trim();
    if (storeName.isNotEmpty) {
      return storeName;
    }

    final metaName = (currentUser?.userMetadata?['full_name'] ??
        currentUser?.userMetadata?['name'])
        ?.toString()
        .trim();
    if (metaName != null && metaName.isNotEmpty) {
      return metaName;
    }

    final email = currentUser?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'Pelanggan';
  }

  String? _resolveUserId(User? currentUser) {
    final sessionUid = UserSession.userId?.trim();
    if (sessionUid != null && sessionUid.isNotEmpty) {
      return sessionUid;
    }
    return currentUser?.id;
  }

  Future<String> _generateNextOrderCode(SupabaseClient client) async {
    try {
      final rows = await client.from('orders').select('order_code');
      var maxNumber = 0;

      for (final row in rows) {
        final rawCode = (row['order_code'] ?? '').toString();
        final match = RegExp(r'(\d+)').firstMatch(rawCode);
        if (match != null) {
          final numVal = int.tryParse(match.group(1) ?? '') ?? 0;
          if (numVal > maxNumber) {
            maxNumber = numVal;
          }
        }
      }

      final nextNum = (maxNumber + 1).toString().padLeft(3, '0');
      return '#WYW-$nextNum';
    } catch (_) {
      final fallbackNum =
      (DateTime.now().millisecondsSinceEpoch % 900 + 100).toString();
      return '#WYW-$fallbackNum';
    }
  }

  Future<void> _submitOrder(BuildContext context, OrderSummary summary) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      final orderCode = await _generateNextOrderCode(client);

      final totalPrice = summary.estimatedTotal > 0
          ? summary.estimatedTotal
          : _parseRupiahToInt(summary.subtotal);

      final customerName = _resolveCustomerName(currentUser);
      final resolvedUid = _resolveUserId(currentUser);

      final payload = <String, dynamic>{
        'order_code': orderCode,
        'customer_name': customerName,
        'service_name': summary.jenisLaundry,
        'speed': summary.kecepatan,
        'treatment': _normalizeTreatment(summary.pengerjaan),
        'detergent_name': summary.deterjen,
        'perfume_name': summary.pewangi,
        'pickup_method': _resolvePickupMethod(summary),
        'delivery_method': _resolveDeliveryMethod(summary),
        'pickup_schedule': summary.jadwal,
        'address': summary.alamat,
        'notes': summary.catatan.trim().isEmpty ? null : summary.catatan.trim(),
        'weight_or_qty': summary.weightOrQty <= 0 ? 1 : summary.weightOrQty,
        'total_price': totalPrice,
        'status': 'Waiting',
        'payment_status': 'Belum Lunas',
      };

      if (resolvedUid != null && resolvedUid.isNotEmpty) {
        payload['user_id'] = resolvedUid;
      }

      await client.from('orders').insert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan $orderCode berhasil disimpan',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPage(
            orderId: orderCode,
            serviceName: summary.jenisLaundry,
            totalAmount: _formatRupiah(totalPrice),
            isPaid: false,
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal menyimpan pesanan: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final summary = args is OrderSummary ? args : OrderSummary.dummy;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(summary),
                  const SizedBox(height: 16),
                  _buildInfoNote(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, summary),
        ],
      ),
    );
  }

  // ---- Header -------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _C.headerBlue,
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top + 14,
        20,
        14,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isSubmitting ? null : () => Navigator.maybePop(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _C.navy),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Konfirmasi Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.navy,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Detail pesanan -----------------------------------------------------
  Widget _buildDetailSection(OrderSummary s) {
    final previewCustomer = _resolveCustomerName(
      Supabase.instance.client.auth.currentUser,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.navy,
          ),
        ),
        Text(
          'Periksa kembali detail pesanan kamu',
          style: GoogleFonts.poppins(fontSize: 10, color: _C.navy),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _C.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Nama Pelanggan', previewCustomer),
              _DetailRow('Jenis Laundry', s.jenisLaundry),
              _DetailRow('Kecepatan Layanan', s.kecepatan),
              _DetailRow('Pengerjaan', _normalizeTreatment(s.pengerjaan)),
              _DetailRow('Deterjen', s.deterjen),
              _DetailRow('Pewangi', s.pewangi),
              _DetailRow('Metode Pengantaran', s.metode),
              _DetailRow('Jadwal Penjemputan', s.jadwal),
              _DetailRow('Alamat', s.alamat),
              if (s.catatan.trim().isNotEmpty)
                _DetailRow('Catatan', s.catatan.trim()),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Informasi Konfirmasi Tagihan ---------------------------------------
  Widget _buildInfoNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _C.infoBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 24, color: _C.infoIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Total tagihan akan dikonfirmasi setelah cucian diperiksa '
                  'oleh pihak laundry',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Tombol bawah -------------------------------------------------------
  Widget _buildBottomButtons(BuildContext context, OrderSummary summary) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed:
              _isSubmitting ? null : () => Navigator.maybePop(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: _C.button),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Ubah Pesanan',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.button,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed:
              _isSubmitting ? null : () => _submitOrder(context, summary),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.button,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'Konfirmasi Pesanan',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Satu baris di kotak "Detail Pesanan": label tebal, nilai di bawahnya.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.navy,
              height: 1.3,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: _C.navy,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}