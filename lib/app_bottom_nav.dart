import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Footer navigasi bersama untuk semua halaman utama.
///
/// Pemakaian di Scaffold:
///   bottomNavigationBar: const AppBottomNav(currentIndex: 0),
///
/// Index: 0 = Beranda, 1 = Chat, 2 = Riwayat, 3 = Profil
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  // Route tujuan tiap tab (sesuai routes di main.dart).
  // null = halaman belum tersedia, tap tidak melakukan apa-apa.
  static const List<String?> _routes = [
    '/home', // Beranda
    null, // Chat (TODO: isi '/chat' jika halamannya sudah ada)
    '/order-history', // Riwayat
    null, // Profil (TODO: isi route Profil jika sudah ada)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          final route = _routes[index];
          if (route == null) return;
          Navigator.pushReplacementNamed(context, route);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF338CA8),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}