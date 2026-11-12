import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_bottom_nav.dart'; // sesuaikan path folder

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const Color _navy = Color(0xFF1B4E6C);
  static const Color _bg = Color(0xFFD8F1FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _sectionTitle('Menu Utama'),
                  const SizedBox(height: 12),
                  _buildMenuGrid(context),
                  const SizedBox(height: 24),
                  _buildRecentOrdersHeader(),
                  const SizedBox(height: 12),
                  _buildOrderItem(
                    code: 'L0042',
                    name: 'Nancy',
                    service: 'Laundry Kiloan • 5 kg',
                    status: 'Menunggu Timbangan',
                    statusColor: const Color(0xFF0284C7),
                    statusBg: const Color(0xFFE0F2FE),
                  ),
                  _buildOrderItem(
                    code: 'L0041',
                    name: 'Budi',
                    service: 'Cuci Setrika • 3 kg',
                    status: 'Diproses',
                    statusColor: const Color(0xFFD97706),
                    statusBg: const Color(0xFFFEF3C7),
                  ),
                  _buildOrderItem(
                    code: 'L0040',
                    name: 'Sinta',
                    service: 'Dry Cleaning • 2 pcs',
                    status: 'Selesai',
                    statusColor: const Color(0xFF16A34A),
                    statusBg: const Color(0xFFDCFCE7),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  // ---------------------------------------------------------------- HEADER
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2C6B8E),
                ),
              ),
              Text(
                'Admin Nency',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola operasional laundry hari ini!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF326D8C),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/admin-notification');
          },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF2C6B8E),
                size: 24,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/admin-profile'),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------- SUMMARY CARD
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryItem('Menunggu', '12', Icons.hourglass_top_rounded,
                  const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
              _divider(),
              _summaryItem('Diproses', '8', Icons.local_laundry_service_rounded,
                  const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              _divider(),
              _summaryItem('Selesai', '15', Icons.check_circle_rounded,
                  const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 56,
        width: 1,
        color: const Color(0xFFE2E8F0),
      );

  Widget _summaryItem(
    String title,
    String count,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _navy,
              height: 1.1,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ MENU GRID
  Widget _buildMenuGrid(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 128, // tinggi tetap, tidak ikut lebar layar
      ),
      children: [
        _menuCard(
          title: 'Manajemen Pesanan',
          subtitle: 'Konfirmasi & update status',
          icon: Icons.local_laundry_service_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () {
            // TODO: Navigasi Manajemen Pesanan
          },
        ),
        _menuCard(
          title: 'Rekap Transaksi',
          subtitle: 'Pantau pendapatan harian',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF16A34A),
          onTap: () => Navigator.pushNamed(context, '/rekapitulasi-transaksi'),
        ),
        _menuCard(
          title: 'Data Customer',
          subtitle: 'Informasi kontak pelanggan',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => Navigator.pushNamed(context, '/customer-data'),
        ),
        _menuCard(
          title: 'Kelola Layanan',
          subtitle: 'Atur tarif & paket laundry',
          icon: Icons.dry_cleaning_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => Navigator.pushNamed(context, '/manage-services'),
        ),
      ],
    );
  }

  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(radius: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------- RECENT ORDERS
  Widget _buildRecentOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle('Pesanan Masuk Terbaru'),
        GestureDetector(
          onTap: () {
            // TODO: Navigasi ke daftar pesanan
          },
          child: Text(
            'Lihat Semua',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0284C7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String code,
    required String name,
    required String service,
    required String status,
    required Color statusColor,
    required Color statusBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardDecoration(radius: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_laundry_service_rounded,
                size: 20, color: Color(0xFF0284C7)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name • #$code',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                Text(
                  service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- HELPERS
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _navy,
      ),
    );
  }

  BoxDecoration _cardDecoration({required double radius}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: _navy.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}