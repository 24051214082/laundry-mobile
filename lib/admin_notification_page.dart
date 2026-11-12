import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNotificationPage extends StatelessWidget {
  const AdminNotificationPage({super.key});

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
              'Notifikasi Admin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            Text(
              'Pembaruan aktivitas & pesanan masuk dapat dilihat di sini',
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
              icon: Icons.shopping_bag_outlined,
              badgeText: 'Pesanan Baru',
              badgeColor: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              title: 'Pesanan baru masuk dari Zea (#LKN4wa124)',
              subtitle: 'Layanan Laundry Kiloan (Express) membutuhkan konfirmasi...',
              dateText: '10.30 WIB',
              hasDot: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.payments_outlined,
              badgeText: 'Perlu Verifikasi',
              badgeColor: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              title: 'Bukti pembayaran baru diunggah',
              subtitle: 'Pelanggan a.n. Zea mengunggah bukti transfer sebesar Rp 25.000...',
              dateText: '09.15 WIB',
              hasDot: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.electric_scooter_rounded,
              badgeText: 'Penjemputan Selesai',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Kurir telah tiba membawa cucian pelanggan',
              subtitle: 'Cucian #LKN4wa123 siap ditimbang dan masuk proses pencucian...',
              dateText: '08.45 WIB',
              hasDot: false,
            ),

            const SizedBox(height: 24),

            // Group Yesterday
            _buildGroupTitle('Yesterday'),
            const SizedBox(height: 10),
            _buildNotificationCard(
              icon: Icons.check_circle_outline_rounded,
              badgeText: 'Pesanan Selesai',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Pesanan #LKN4wa120 telah diterima pelanggan',
              subtitle: 'Status pesanan otomatis ditutup. Pendapatan tercatat di laporan...',
              dateText: 'Kemarin',
              hasDot: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.person_add_alt_1_outlined,
              badgeText: 'Pelanggan Baru',
              badgeColor: const Color(0xFFE2E8F0),
              badgeTextColor: const Color(0xFF334155),
              title: 'Akun pelanggan baru terdaftar',
              subtitle: 'Zea (zea@gmail.com) baru saja mendaftar di aplikasi...',
              dateText: 'Kemarin',
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