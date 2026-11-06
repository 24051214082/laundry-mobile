import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8F1FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Admin & Notifikasi
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo,',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF2C6B8E),
                          ),
                        ),
                        Text(
                          'Admin Nency',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        Text(
                          'Kelola operasional laundry hari ini!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF326D8C),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Tombol Notifikasi
                        Stack(
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
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // Avatar Profil
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Card Ringkasan Pesanan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4E6C).withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B4E6C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              title: 'Menunggu',
                              count: '12',
                              icon: Icons.hourglass_top_rounded,
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              title: 'Diproses',
                              count: '8',
                              icon: Icons.local_laundry_service_rounded,
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              title: 'Selesai',
                              count: '15',
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Menu Fitur (2x2 Grid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.88,
                  children: [
                    _buildAdminMenuCard(
                      title: 'Manajeme Pesanan',
                      subtitle: 'Konfirmasi & update status',
                      iconData: Icons.local_laundry_service_outlined,
                      onTap: () {
                        // TODO: Navigasi Manajemen Pesanan
                      },
                    ),
                    _buildAdminMenuCard(
                      title: 'Rekap Transaksi',
                      subtitle: 'Pantau pendapatan harian',
                      iconData: Icons.bar_chart_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/rekapitulasi-transaksi');
                      },
                    ),
                    _buildAdminMenuCard(
                      title: 'Data Customer',
                      subtitle: 'Informasi kontak pelanggan',
                      iconData: Icons.people_alt_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/customer-data');
                      },
                    ),
                    _buildAdminMenuCard(
                      title: 'Kelola Layanan',
                      subtitle: 'Atur tarif & paket laundry',
                      iconData: Icons.dry_cleaning_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/manage-services');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section Pesanan Masuk Terbaru
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Masuk Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4E6C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No. L0042',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                'Nancy',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B4E6C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layanan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  'Lundry Kiloan 5 kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Menunggu Timbangan',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF60A5FA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar Custom
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(1, Icons.assignment_outlined, 'Pesanan'),
            _buildNavItem(2, Icons.bar_chart_rounded, 'Laporan'),
            _buildNavItem(3, Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String count,
    required IconData icon,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminMenuCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4E6C).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Atas: Latar Belakang Biru Penuh dengan Ikon Besar
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B9EE1),
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Bagian Bawah: Teks Judul, Subtitle & Tombol Panah
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4E6C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B9EE1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });

        // Navigasi footer dari AdminHomePage
        if (index == 0) {
          // Sedang di Beranda Admin
        } else if (index == 1) {
          // TODO: Arahkan ke halaman Pesanan
        } else if (index == 2) {
          // Ikon Laporan diklik -> Buka Rekapitulasi Transaksi
          Navigator.pushNamed(context, '/rekapitulasi-transaksi');
        } else if (index == 3) {
          // TODO: Arahkan ke halaman Profil
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
            size: 24,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}