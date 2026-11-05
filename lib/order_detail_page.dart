import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_confirmation_page.dart';

// ---------------------------------------------------------------------------
// Halaman Detail Pesanan
// Letakkan di: lib/order_detail_page.dart
// ---------------------------------------------------------------------------

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const button = Color(0xFF263F73);
  static const border = Color(0xFFB9D3DF);
}

class OrderDetailArgs {
  final String id;
  final String date;
  final OrderSummary? summary;

  const OrderDetailArgs({
    required this.id,
    required this.date,
    this.summary,
  });
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  // Data default jika dibuka tanpa argumen
  static const OrderSummary _dummySummary = OrderSummary(
    jenisLaundry: 'Kiloan',
    kecepatan: 'Reguler',
    pengerjaan: 'Cuci + Setrika',
    deterjen: 'Anti Bakteri',
    pewangi: 'Ocean Fresh',
    metode: 'Antar Jemput Driver',
    jadwal: '18 April 2027 - 08.00',
    alamat: 'Jl. Ketintang Baru No. 12, Surabaya',
    biaya: [
      CostItem('Berat (5.0 kg)', 'Rp25.000'),
      CostItem('Pengerjaan Cuci + Setrika', 'Rp5.000'),
      CostItem('Tambahan Pewangi Ocean Fresh', 'Rp2.500'),
      CostItem('Ongkir Jemput & Antar', 'Rp2.500'),
    ],
    subtotal: 'Rp35.000',
  );

  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;

    String orderId = '#LKN4wa123';
    String orderDate = '18 April 2027 08.00';
    OrderSummary s = _dummySummary;

    // Menangani argumen dari HomePage (Map) maupun dari OrderHistory (OrderDetailArgs)
    if (raw is OrderDetailArgs) {
      orderId = raw.id;
      orderDate = raw.date;
      s = raw.summary ?? _dummySummary;
    } else if (raw is Map<String, dynamic>) {
      orderId = raw['orderId']?.toString() ?? orderId;
      orderDate = raw['estimate']?.toString() ?? orderDate;
      s = OrderSummary(
        jenisLaundry: raw['serviceName']?.toString() ?? 'Kiloan',
        kecepatan: raw['treatment']?.toString() ?? 'Reguler',
        pengerjaan: raw['treatment']?.toString() ?? 'Cuci + Setrika',
        deterjen: raw['detergent']?.toString() ?? 'Anti Bakteri',
        pewangi: raw['perfume']?.toString() ?? 'Ocean Fresh',
        metode: raw['method']?.toString() ?? 'Antar Jemput Driver',
        jadwal: raw['estimate']?.toString() ?? orderDate,
        alamat: raw['address']?.toString() ?? 'Jl. Ketintang Baru No. 12, Surabaya',
        biaya: [
          CostItem(
            'Layanan & Berat (${raw['weight'] ?? '5.0 kg'})',
            raw['totalPrice']?.toString() ?? 'Rp35.000',
          ),
        ],
        subtotal: raw['totalPrice']?.toString() ?? 'Rp35.000',
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No. Pesanan $orderId',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _C.navy,
                            ),
                          ),
                          Text(
                            orderDate,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _C.navy,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9D5FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Diproses',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7E22CE),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDetailBox(s),
                  const SizedBox(height: 20),
                  _buildCostSection(s),
                ],
              ),
            ),
          ),
          _buildBottomActionButtons(context, orderId, s),
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
            onTap: () => Navigator.maybePop(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _C.navy,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Detail Pesanan',
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

  // ---- Kotak detail -------------------------------------------------------
  Widget _buildDetailBox(OrderSummary s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow('Jenis Laundry', s.jenisLaundry),
          _DetailRow('Kecepatan Layanan', s.kecepatan),
          _DetailRow('Pengerjaan', s.pengerjaan),
          _DetailRow('Deterjen', s.deterjen),
          _DetailRow('Pewangi', s.pewangi),
          _DetailRow('Metode Pengantaran', s.metode),
          _DetailRow('Jadwal Penjemputan / Siap', s.jadwal),
          _DetailRow('Alamat', s.alamat),
        ],
      ),
    );
  }

  // ---- Rincian biaya ------------------------------------------------------
  Widget _buildCostSection(OrderSummary s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rincian Biaya',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _C.navy,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.border),
          ),
          child: Column(
            children: [
              for (final item in s.biaya)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: _C.navy,
                          ),
                        ),
                      ),
                      Text(
                        item.amount,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: _C.navy,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.navy,
              ),
            ),
            Text(
              s.subtotal,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.navy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Tombol Chat Admin & Pesan Lagi -------------------------------------
  Widget _buildBottomActionButtons(
      BuildContext context,
      String orderId,
      OrderSummary s,
      ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Chat Admin (Menuju ke ChatRoomPage)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/chat-room',
                  arguments: {
                    'orderId': orderId,
                    'serviceName': s.jenisLaundry,
                    'status': 'Diproses',
                  },
                );
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                'Tanya Admin Pesanan Ini',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.button,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tombol Pesan Lagi
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/booking'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _C.button, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pesan Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.button,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Satu baris di kotak detail
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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