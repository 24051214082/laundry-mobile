import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderNotificationPage extends StatelessWidget {
  const OrderNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6EFFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4E6C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            Text(
              'Pembaruan Status Pesanan Anda Dapat Dilihat Di Sini',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF2E637E),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Today
            _buildGroupTitle('Today'),
            const SizedBox(height: 10),
            _buildNotificationCard(
              icon: Icons.electric_scooter_rounded,
              badgeText: 'Proses Pengantaran',
              badgeColor: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              title: 'Cucian Anda telah selesai diproses',
              subtitle: 'Kurir sedang mengantarkan cucian ke lokasi Anda. Mohon pa...',
              dateText: 'xx/xx/xxxx',
              hasDot: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.iron_rounded,
              badgeText: 'Penyetrikaan',
              badgeColor: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              title: 'Cucian memasuki tahap penyelesaian',
              subtitle: 'Cucian Anda sedang disetrika dan dikemas agar siap untuk di...',
              dateText: 'xx/xx/xxxx',
              hasDot: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.local_laundry_service_outlined,
              badgeText: 'Pengeringan',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Cucian Anda sedang dalam proses pengeringan',
              subtitle: 'Cucian telah melewati tahap pencucian dan sedang dikeri...',
              dateText: 'xx/xx/xxxx',
              hasDot: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.local_laundry_service_rounded,
              badgeText: 'Pencucian',
              badgeColor: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              title: 'Cucian Anda sedang dalam proses pencucian',
              subtitle: 'Proses pencucian sedang berlangsung sesuai dengan laya...',
              dateText: 'xx/xx/xxxx',
              hasDot: true,
            ),

            const SizedBox(height: 24),

            // Group Yesterday
            _buildGroupTitle('Yesterday'),
            const SizedBox(height: 10),
            _buildNotificationCard(
              icon: Icons.timer_outlined,
              badgeText: 'Dalam Antrean',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Cucian Anda sedang menunggu giliran untuk diproses',
              subtitle: 'Pesanan Anda telah dikonfirmasi dan sedang berada dala...',
              dateText: 'xx/xx/xxxx',
              hasDot: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.check_circle_outline_rounded,
              badgeText: 'Pembayaran Terverifikasi',
              badgeColor: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              title: 'Pembayaran Anda berhasil diverifikasi',
              subtitle: 'Pembayaran telah dikonfirmasi. Pesanan laundry Anda akan...',
              dateText: 'xx/xx/xxxx',
              hasDot: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.receipt_long_rounded,
              badgeText: 'Menunggu Pembayaran',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Tagihan pesanan Anda telah tersedia',
              subtitle: 'Silakan lakukan pembayaran untuk melanjutkan pesanan la...',
              dateText: 'xx/xx/xxxx',
              hasDot: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.electric_scooter_rounded,
              badgeText: 'Proses Penjemputan',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Permintaan penjemputan telah diterima',
              subtitle: 'Kurir sedang dalam perjalanan untuk menjemput cucian Anda',
              dateText: 'xx/xx/xxxx',
              hasDot: false,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String title,
    required String subtitle,
    required String dateText,
    required bool hasDot,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          dateText,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        if (hasDot) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}