import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variabel penampung data pesanan aktif
  Map<String, dynamic> activeOrderData = {
    'orderId': '#LKN4wa123',
    'serviceName': 'Laundry Kiloan',
    'weight': '5.0 kg',
    'treatment': 'Cuci + Setrika',
    'perfume': 'Ocean Fresh',
    'detergent': 'Anti Bakteri',
    'method': 'Antar Jemput Driver',
    'address': 'Jl. Ketintang Baru No. 12, Surabaya',
    'totalPrice': 'Rp 35.000',
    'status': 'Diproses',
    'estimate': '18 April 2027, 08.00',
    'image': 'assets/laundrykiloan.PNG',
  };

  void _navigateToDetail() {
    Navigator.pushNamed(
      context,
      '/order-detail',
      arguments: activeOrderData,
    );
  }

  void _navigateToBooking(String serviceName) {
    Navigator.pushNamed(
      context,
      '/booking',
      arguments: serviceName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFFB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== Header Profil & Sapaan ====================
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo,',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1E465D),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Zea',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B4E6C),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFF9333EA),
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Saatnya pakaian bersih lagi!',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF2E637E),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Tombol Notifikasi
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/order-notification');
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1B4E6C).withOpacity(0.08),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF1B4E6C),
                                  size: 23,
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
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Avatar Profil
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B4E6C).withOpacity(0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==================== Card Pesanan Aktif ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToDetail,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B4E6C).withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              activeOrderData['image'] ?? 'assets/laundrykiloan.PNG',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.local_laundry_service_rounded,
                                size: 42,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pesanan Aktif',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1B4E6C),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        activeOrderData['status'] ?? 'Diproses',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF7E22CE),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  activeOrderData['orderId'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${activeOrderData['serviceName']} ${activeOrderData['weight']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Estimasi selesai',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  activeOrderData['estimate'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: Color(0xFF1B4E6C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================== Sub-header Katalog Layanan ====================
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Layanan Laundry',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4E6C),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Lihat Semua',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF338CA8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== Grid Katalog Layanan ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                  children: [
                    _buildServiceCard(
                      title: 'Laundry Kiloan',
                      desc: 'Bersih, wangi, dan rapi setiap hari.',
                      price: 'Rp 3.000/kg',
                      imagePath: 'assets/laundrykiloan.PNG',
                      onTap: () => _navigateToBooking('Laundry Kiloan'),
                    ),
                    _buildServiceCard(
                      title: 'Laundry Satuan',
                      desc: 'Untuk pakaian khusus dan delicate.',
                      price: 'Rp 15.000/pcs',
                      imagePath: 'assets/laundrysatuan2.png',
                      onTap: () => _navigateToBooking('Laundry Satuan'),
                    ),
                    _buildServiceCard(
                      title: 'Bed Cover',
                      desc: 'Selimut bersih, tidur nyenyak sampai pagi.',
                      price: 'Rp 25.000',
                      imagePath: 'assets/laundrybedcover.PNG',
                      onTap: () => _navigateToBooking('Bed Cover'),
                    ),
                    _buildServiceCard(
                      title: 'Boneka',
                      desc: 'Si kesayangan kembali wangi dan fluffy!',
                      price: 'Rp 15.000',
                      imagePath: 'assets/laundryboneka.PNG',
                      onTap: () => _navigateToBooking('Boneka'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String desc,
    required String price,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4E6C).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEBF7FD),
                    Color(0xFFD8EEFB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.dry_cleaning_rounded,
                      size: 42,
                      color: Color(0xFF338CA8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: const Color(0xFF64748B),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start from',
              style: GoogleFonts.poppins(
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF338CA8),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pesan Sekarang',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}