import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    this.paymentDate = '22 Oktober 2026 - 17.35 WIB',
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
        _orderId = args['orderId'] ?? _orderId;
        _serviceName = args['serviceName'] ?? _serviceName;
        _totalAmount = args['totalAmount'] ?? _totalAmount;
        _isPaid = args['isPaid'] ?? _isPaid;
        _paymentDate = args['paymentDate'] ?? _paymentDate;
      }
      _isInitialized = true;
    }
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Konfirmasi Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
        content: Text(
          'Apakah kamu sudah menyelesaikan pembayaran sebesar $_totalAmount melalui QRIS?',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Belum',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isPaid = true;
                _paymentDate = 'Hari ini, Baru saja';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF16A34A),
                  content: Text(
                    'Pembayaran berhasil diverifikasi!',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF338CA8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Ya, Sudah Bayar',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
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

              // ================= Tampilan Kondisional: Sudah Bayar vs Belum Bayar =================
              if (_isPaid) _buildPaidSection() else _buildUnpaidQrisSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAMPILAN JIKA SUDAH DIBAYAR ====================
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
            'Terima kasih! Tagihan pesananmu sebesar $_totalAmount telah lunas terverifikasi.',
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
                _buildReceiptRow('Metode Pembayaran', 'QRIS Instant'),
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

  // ==================== TAMPILAN JIKA BELUM DIBAYAR (QRIS) ====================
  Widget _buildUnpaidQrisSection() {
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

          // Bingkai QRIS
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
                      'Mobile Laundry ID',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Widget QR Code Visual (Bisa diganti Image.asset('assets/qris.png') jika ada gambar)
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(
                    painter: _QrisMockPainter(seed: _orderId + _totalAmount),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'NMID: ID1026001928374',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Panduan singkat pembayaran
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
                    'Buka aplikasi m-Banking atau e-Wallet (GoPay, OVO, DANA, ShopeePay), lalu scan kode QR di atas.',
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

          const SizedBox(height: 22),

          // Tombol Konfirmasi Pembayaran
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF284470),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Saya Sudah Bayar',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
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
}

// Painter QR Code unik berdasarkan Order ID & Nominal agar tampil rapi tanpa error asset
class _QrisMockPainter extends CustomPainter {
  final String seed;
  _QrisMockPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1B4E6C);
    const int grid = 21;
    final double cellSize = size.width / grid;

    void drawFinder(int startX, int startY) {
      for (int y = 0; y < 7; y++) {
        for (int x = 0; x < 7; x++) {
          final isBorder = x == 0 || x == 6 || y == 0 || y == 6;
          final isCenter = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          if (isBorder || isCenter) {
            canvas.drawRect(
              Rect.fromLTWH(
                (startX + x) * cellSize,
                (startY + y) * cellSize,
                cellSize,
                cellSize,
              ),
              paint,
            );
          }
        }
      }
    }

    drawFinder(0, 0);
    drawFinder(grid - 7, 0);
    drawFinder(0, grid - 7);

    int hash = seed.hashCode;
    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        final inTopLeft = x < 8 && y < 8;
        final inTopRight = x >= grid - 8 && y < 8;
        final inBottomLeft = x < 8 && y >= grid - 8;
        if (inTopLeft || inTopRight || inBottomLeft) continue;

        final val = (hash ^ (x * 31 + y * 17)) & 3;
        if (val == 0 || val == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}