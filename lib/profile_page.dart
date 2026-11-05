import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bottom_nav.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const button = Color(0xFF263F73);
  static const tealAccent = Color(0xFF338CA8);
  static const textSub = Color(0xFF64748B);
  static const bgLight = Color(0xFFF8FAFC);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock data profil pelanggan (siap dihubungkan ke session / database)
  final Map<String, dynamic> _userData = {
    'name': 'Zea Althafunissa',
    'phone': '+62 812-3456-7890',
    'email': 'zea.althaf@gmail.com',
    'points': 450,
    'totalOrders': 18,
    'vouchers': 3,
    'avatarUrl':
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  };

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Keluar Akun?',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Apakah kamu yakin ingin keluar dari akun Wish You Wash?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _C.textSub,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.headerBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==================== Header Title ====================
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Saya',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _C.navy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Atur preferensi & informasi akunmu',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF2E637E),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _C.navy.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: _C.navy,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ==================== Konten Lembar Putih ====================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _C.bgLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    children: [
                      // 1. Kartu Utama Profil
                      _buildProfileCard(),
                      const SizedBox(height: 16),

                      // 2. Bar Loyalty Points / Membership
                      _buildLoyaltyBanner(),
                      const SizedBox(height: 16),

                      // 3. Grid Statistik Ringkas
                      _buildQuickStats(),
                      const SizedBox(height: 22),

                      // 4. Kelompok Menu Akun & Aktivitas
                      _buildSectionHeader('Akun & Preferensi'),
                      const SizedBox(height: 10),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Alamat Pengantaran',
                          subtitle: 'Jl. Ketintang Baru No. 12, Surabaya',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Metode Pembayaran',
                          subtitle: 'QRIS, Transfer Bank & E-Wallet',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifikasi & Pengingat',
                          subtitle: 'Status cuci, promo & pengantaran',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // 5. Kelompok Menu Bantuan & Info
                      _buildSectionHeader('Bantuan & Keamanan'),
                      const SizedBox(height: 10),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.headset_mic_outlined,
                          title: 'Pusat Bantuan (FAQ)',
                          subtitle: 'Kendala cucian & cara pemesanan',
                          onTap: () => Navigator.pushNamed(context, '/chat'),
                        ),
                        _MenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Syarat & Kebijakan Privasi',
                          subtitle: 'Wish You Wash v1.0.0',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // 6. Tombol Logout
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutConfirmation(context),
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                          label: Text(
                            'Keluar dari Akun',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFFECACA),
                              width: 1.4,
                            ),
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Wish You Wash Laundry • Versi 1.0.0',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget Bagian & Kartu Profil
  // ---------------------------------------------------------------------------

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.headerBlue, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _C.navy.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(_userData['avatarUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: _C.tealAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _userData['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _C.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Color(0xFF0284C7),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _userData['phone'],
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: _C.textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _userData['email'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F3A6E), Color(0xFF263F73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFFACC15),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member Silver',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_userData['points']} Wash Points',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFFBAE6FD),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.tealAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Tukar Poin',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Total Order',
            value: '${_userData['totalOrders']}',
            icon: Icons.local_laundry_service_outlined,
            color: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            label: 'Kupon Diskon',
            value: '${_userData['vouchers']}',
            icon: Icons.confirmation_number_outlined,
            color: const Color(0xFF7E22CE),
            bgColor: const Color(0xFFF3E8FF),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.navy,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  color: _C.textSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _C.navy,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          indent: 52,
          endIndent: 16,
          color: Color(0xFFF1F5F9),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(20) : Radius.zero,
              bottom: index == items.length - 1
                  ? const Radius.circular(20)
                  : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 20, color: _C.navy),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _C.navy,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: _C.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}