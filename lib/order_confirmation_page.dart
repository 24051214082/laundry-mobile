import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Halaman Konfirmasi Pesanan
// Letakkan di: lib/order_confirmation_page.dart
//
// Cara membuka dari halaman "Buat Pesanan" (tombol Lanjutkan):
//
//   Navigator.pushNamed(
//     context,
//     '/order-confirmation',
//     arguments: OrderSummary(
//       jenisLaundry: 'Kiloan',
//       kecepatan: 'Express',
//       pengerjaan: 'Cuci + Setrika',
//       deterjen: 'Deterjen A',
//       pewangi: 'Pewangi A',
//       metode: 'Penjemputan',
//       jadwal: '22 Oktober 2026 - 08.00',
//       alamat: 'Jl. Contoh No. 1',
//       biaya: [
//         CostItem('Tarif minimum kiloan (7kg)', 'Rp20.000'),
//         CostItem('Biaya Express', 'Rp5.000'),
//       ],
//       subtotal: 'Rp25.000',
//     ),
//   );
//
// Kalau dibuka tanpa arguments (misalnya untuk testing), halaman memakai
// data contoh sesuai wireframe.
// ---------------------------------------------------------------------------

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
  final String jadwal;
  final String alamat;
  final List<CostItem> biaya;
  final String subtotal;

  const OrderSummary({
    required this.jenisLaundry,
    required this.kecepatan,
    required this.pengerjaan,
    required this.deterjen,
    required this.pewangi,
    required this.metode,
    required this.jadwal,
    required this.alamat,
    required this.biaya,
    required this.subtotal,
  });

  /// Data contoh sesuai wireframe.
  static const OrderSummary dummy = OrderSummary(
    jenisLaundry: 'Kiloan',
    kecepatan: 'Express',
    pengerjaan: 'Cuci + Setrika',
    deterjen: 'Deterjen A',
    pewangi: 'Pewangi A',
    metode: 'Penjemputan',
    jadwal: '22 Oktober 2026 - 08.00',
    alamat: 'xxxxxxx',
    biaya: [
      CostItem('Tarif minimum kiloan (7kg)', 'Rp20.000'),
      CostItem('Biaya Express', 'Rpxxxxxx'),
      CostItem('Cuci + Setrika', 'Rpxxxxxx'),
      CostItem('Tambahan Deterjen', 'Rp1.000'),
      CostItem('Tambahan Pewangi', 'Rp1.000'),
    ],
    subtotal: 'Rp2xxxx',
  );
}

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

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
                  const SizedBox(height: 24),
                  _buildCostSection(summary),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
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
        ),
      ],
    );
  }

  // ---- Estimasi biaya -----------------------------------------------------
  Widget _buildCostSection(OrderSummary s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimasi Biaya',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _C.navy,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
              'Estimasi Subtotal',
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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _C.infoBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 26, color: _C.infoIcon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total tagihan akan dikonfirmasi setelah cucian ditimbang '
                  'oleh pihak laundry',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: _C.navy),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Tombol bawah -------------------------------------------------------
  Widget _buildBottomButtons(BuildContext context) {
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
              onPressed: () => Navigator.maybePop(context),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pesanan berhasil dikonfirmasi',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                );
                // TODO: simpan pesanan ke data/riwayat bila sudah ada backend.
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.button,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
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