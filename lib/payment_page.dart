import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gal/gal.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String serviceName;
  final String totalAmount;
  final bool isPaid;
  final String paymentDate;

  const PaymentPage({
    super.key,
    this.orderId = '#LKN4wa123',
    this.serviceName = 'Laundry Kiloan (5.0 kg)',
    this.totalAmount = 'Rp 35.000',
    this.isPaid = false,
    this.paymentDate = 'Hari ini',
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late bool _isPaid;
  late String _paymentDate;
  String _orderId = '#LKN4wa123';
  String _serviceName = 'Laundry Kiloan (5.0 kg)';
  String _totalAmount = 'Rp 35.000';

  bool _isInitialized = false;
  bool _isLoadingQr = false;
  bool _isDownloadingQr = false;
  bool _isCheckingStatus = false;
  String? _qrImageUrl;
  String? _qrError;
  StreamSubscription<List>? _orderSub;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.isPaid;
    _paymentDate = widget.paymentDate;
    _orderId = widget.orderId;
    _serviceName = widget.serviceName;
    _totalAmount = widget.totalAmount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _orderId = (args['orderId'] ?? _orderId).toString();
        _serviceName = (args['serviceName'] ?? _serviceName).toString();
        _totalAmount = (args['totalAmount'] ?? _totalAmount).toString();
        _isPaid = args['isPaid'] is bool ? args['isPaid'] as bool : _isPaid;
        _paymentDate = (args['paymentDate'] ?? _paymentDate).toString();
      }
      _isInitialized = true;

      if (!_isPaid) {
        _listenOrderPaymentRealtime();
        _generateMidtransQris();
      }
    }
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  int _parseAmountToInt(String formatted) {
    final digits = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 10000;
  }

  bool _looksLikeUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value.trim());
  }

  void _listenOrderPaymentRealtime() {
    final client = Supabase.instance.client;
    final trimmedId = _orderId.trim();
    final filterCol = _looksLikeUuid(trimmedId) ? 'id' : 'order_code';

    _orderSub = client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq(filterCol, trimmedId)
        .listen((rows) {
      if (rows.isEmpty || !mounted) return;
      final payStatus =
          (rows.first['payment_status'] ?? '').toString().toLowerCase();
      if (payStatus == 'lunas' && !_isPaid) {
        setState(() {
          _isPaid = true;
          _paymentDate = 'Hari ini, Baru saja';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            content: Text(
              'Pembayaran QRIS otomatis terkonfirmasi!',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        );
      }
    });
  }

  Future<void> _generateMidtransQris() async {
    setState(() {
      _isLoadingQr = true;
      _qrError = null;
    });

    try {
      final client = Supabase.instance.client;
      final grossAmount = _parseAmountToInt(_totalAmount);

      final res = await client.functions.invoke(
        'create-midtrans-qris',
        body: {
          'orderCode': _orderId.trim(),
          'grossAmount': grossAmount,
        },
      );

      final data = res.data;
      final url = (data is Map) ? data['qr_url']?.toString() : null;

      if (!mounted) return;
      if (url != null && url.isNotEmpty) {
        setState(() {
          _qrImageUrl = url;
          _isLoadingQr = false;
        });
      } else {
        setState(() {
          _qrError = 'QRIS tidak tersedia dari Midtrans. Coba muat ulang.';
          _isLoadingQr = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _qrError = 'Gagal memuat QRIS: $e';
        _isLoadingQr = false;
      });
    }
  }

  // Salin URL gambar QRIS ke clipboard
  Future<void> _copyQrLink() async {
    if (_qrImageUrl == null || _qrImageUrl!.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _qrImageUrl!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B4E6C),
        content: Text(
          'Link QRIS berhasil disalin ke clipboard!',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  // Download gambar QRIS (.png) ke folder Download HP
  // Download gambar QRIS (.png) langsung ke Galeri HP
  Future<void> _downloadQrImage() async {
    if (_qrImageUrl == null || _qrImageUrl!.isEmpty || _isDownloadingQr) return;
    setState(() => _isDownloadingQr = true);

    try {
      final response = await http.get(Uri.parse(_qrImageUrl!));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final safeCode = _orderId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
      final fileName =
          'QRIS_${safeCode}_${DateTime.now().millisecondsSinceEpoch}';

      await Gal.putImageBytes(
        response.bodyBytes,
        name: fileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          content: Text(
            'Gambar QRIS berhasil disimpan ke Galeri!',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal menyimpan ke Galeri: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingQr = false);
      }
    }
  }

  Future<void> _checkPaymentStatusManually() async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);

    try {
      final client = Supabase.instance.client;
      final trimmedId = _orderId.trim();
      final query = client.from('orders').select('payment_status');
      final row = _looksLikeUuid(trimmedId)
          ? await query.eq('id', trimmedId).maybeSingle()
          : await query.eq('order_code', trimmedId).maybeSingle();

      if (!mounted) return;
      final isNowPaid =
          (row?['payment_status'] ?? '').toString().toLowerCase() == 'lunas';

      setState(() {
        _isCheckingStatus = false;
        if (isNowPaid) {
          _isPaid = true;
          _paymentDate = 'Hari ini, Baru saja';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              isNowPaid ? const Color(0xFF16A34A) : const Color(0xFFB45309),
          content: Text(
            isNowPaid
                ? 'Pembayaran telah lunas terverifikasi!'
                : 'Pembayaran belum masuk. Silakan selesaikan scan QRIS.',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _isPaid);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FAFD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD6EFFB),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1B4E6C),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context, _isPaid),
          ),
          title: Text(
            'Detail Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4E6C),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // ================= Kartu Ringkasan Tagihan =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD6EFFB), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B4E6C).withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'No. Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _orderId,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Layanan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _serviceName,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tagihan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        Text(
                          _totalAmount,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF338CA8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_isPaid) _buildPaidSection() else _buildUnpaidQrisSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaidSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 56,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'SUDAH DIBAYAR',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF15803D),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pembayaran Telah Diterima',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4E6C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Terima kasih! Tagihan pesananmu sebesar $_totalAmount telah lunas terverifikasi otomatis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Metode Pembayaran', 'QRIS Midtrans'),
                const SizedBox(height: 8),
                _buildReceiptRow('Status', 'Lunas'),
                const SizedBox(height: 8),
                _buildReceiptRow('Waktu Pembayaran', _paymentDate),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _isPaid),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF284470),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kembali ke Status Pesanan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildUnpaidQrisSection() {
    final hasQr = !_isLoadingQr && _qrError == null && _qrImageUrl != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6EFFB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4E6C).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'MENUNGGU PEMBAYARAN',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan QRIS untuk Membayar',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4E6C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nominal otomatis terdeteksi sesuai tagihan:\n$_totalAmount',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),

          // Bingkai QRIS Asli dari Midtrans
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1B4E6C), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QRIS',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1B4E6C),
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Powered by Midtrans',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 210,
                  height: 210,
                  child: _isLoadingQr
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF338CA8),
                          ),
                        )
                      : _qrError != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _qrError!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _generateMidtransQris,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            )
                          : Image.network(
                              _qrImageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text('Gagal memuat gambar QRIS'),
                              ),
                            ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Otomatis terverifikasi setelah dibayar',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Unduh QRIS & Salin Link QRIS
          if (hasQr) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDownloadingQr ? null : _downloadQrImage,
                    icon: _isDownloadingQr
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_rounded, size: 17),
                    label: Text(
                      'Unduh QR',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B4E6C),
                      side: const BorderSide(color: Color(0xFF338CA8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyQrLink,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(
                      'Salin Link QR',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B4E6C),
                      side: const BorderSide(color: Color(0xFF338CA8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF0284C7),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Unduh kode QR atau salin link-nya untuk diuji melalui Midtrans Sandbox QRIS Simulator.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF1E465D),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isCheckingStatus ? null : _checkPaymentStatusManually,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF284470), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCheckingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Cek Status Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF284470),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}