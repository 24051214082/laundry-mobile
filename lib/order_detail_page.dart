import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_confirmation_page.dart';

// ---------------------------------------------------------------------------
// Halaman Detail Pesanan
// Letakkan di: lib/order_detail_page.dart
//
// Dibuka dari halaman Riwayat (tombol "Detail Pesanan"):
//
//   Navigator.pushNamed(
//     context,
//     '/order-detail',
//     arguments: OrderDetailArgs(id: 'LD001', date: '22 Oktober 2026 17.20', summary: ...),
//   );
//
// Kalau dibuka tanpa arguments (untuk testing), memakai data contoh wireframe.
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

  // Data contoh sesuai wireframe.
  static const OrderSummary _dummySummary = OrderSummary(
    jenisLaundry: 'Kiloan',
    kecepatan: 'Express',
    pengerjaan: 'Cuci + Setrika',
    deterjen: 'Deterjen A',
    pewangi: 'Pewangi A',
    metode: 'Penjemputan',
    jadwal: '22 Oktober 2026 - 08.00',
    alamat: 'xxxxxxx',
    biaya: [
      CostItem('Berat minimum', 'Rp20.000'),
      CostItem('Berat Tambahan', 'Rp3.000'),
      CostItem('Biaya Express', 'Rpxxxxxx'),
      CostItem('Cuci + Setrika', 'Rpxxxxxx'),
      CostItem('Tambahan Deterjen', 'Rp1.000'),
      CostItem('Tambahan Pewangi', 'Rp1.000'),
    ],
    subtotal: 'Rp2xxxx',
  );

  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    final args = raw is OrderDetailArgs
        ? raw
        : const OrderDetailArgs(id: 'LD001', date: '22 Oktober 2026 17.20');
    final s = args.summary ?? _dummySummary;

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
                  Text(
                    'No. Pesanan ${args.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.navy,
                    ),
                  ),
                  Text(
                    args.date,
                    style: GoogleFonts.poppins(fontSize: 11, color: _C.navy),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailBox(s),
                  const SizedBox(height: 22),
                  _buildCostSection(s),
                ],
              ),
            ),
          ),
          _buildBottomButton(context),
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
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _C.navy),
            ),
          ),
          const SizedBox(width: 4),
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
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
          _DetailRow('Jadwal Penjemputan', s.jadwal),
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _C.border),
          ),
          child: Column(
            children: [
              for (final item in s.biaya)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: _C.navy),
                        ),
                      ),
                      Text(
                        item.amount,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: _C.navy),
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.navy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Tombol Pesan Lagi --------------------------------------------------
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/booking'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _C.button,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Pesan Lagi',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Satu baris di kotak detail: label tebal, nilai di bawahnya.
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