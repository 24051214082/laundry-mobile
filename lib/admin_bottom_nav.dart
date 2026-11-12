import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom navigation bar bersama untuk semua halaman admin.
/// Cukup panggil: bottomNavigationBar: const AdminBottomNav(currentIndex: X)
class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  /// Warna menu aktif (biru). Ubah di sini kalau mau ganti.
  static const Color activeColor = Color(0xFF0284C7);
  static const Color inactiveColor = Color(0xFF94A3B8);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin-home');
        break;
      case 1:
        // TODO: ganti dengan route halaman Pesanan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Pesanan belum tersedia')),
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/rekapitulasi-transaksi');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4E6C).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              _item(context, 0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              _item(context, 1, Icons.assignment_outlined, Icons.assignment_rounded, 'Pesanan'),
              _item(context, 2, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Laporan'),
              _item(context, 3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(context, index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}