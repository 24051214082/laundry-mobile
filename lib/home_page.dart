import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bottom_nav.dart';
import 'status_pesanan.dart';
import 'user_profile_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map? activeOrderData;
  bool _isLoadingOrder = true;

  // State dinamis untuk Katalog Layanan dari tabel 'services'
  List _services = [];
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveOrder();
    _fetchServices();
  }

  Future<void> _fetchActiveOrder() async {
    setState(() => _isLoadingOrder = true);
    try {
      var query = Supabase.instance.client
          .from('orders')
          .select()
          .neq('status', 'Selesai')
          .neq('status', 'Dibatalkan');

      if (UserSession.userId != null && UserSession.userId!.isNotEmpty) {
        query = query.eq('user_id', UserSession.userId!);
      }

      final row = await query
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;

      if (row == null) {
        setState(() {
          activeOrderData = null;
          _isLoadingOrder = false;
        });
        return;
      }

      final serviceName = (row['service_name'] ?? 'Laundry').toString();
      final assetImg = _resolveServiceAsset(serviceName);

      setState(() {
        activeOrderData = {
          'dbId': row['id'].toString(),
          'orderId': (row['order_code'] ?? '-').toString(),
          'serviceName': serviceName,
          'weight': (row['weight_or_qty'] ?? '-').toString(),
          'treatment': (row['treatment'] ?? '-').toString(),
          'perfume': (row['perfume_name'] ?? '-').toString(),
          'detergent': (row['detergent_name'] ?? '-').toString(),
          'method':
          '${row['pickup_method'] ?? '-'} • ${row['delivery_method'] ?? '-'}',
          'address': (row['address'] ?? '-').toString(),
          'totalPrice': 'Rp ${row['total_price'] ?? 0}',
          'status': (row['status'] ?? 'Diproses').toString(),
          'estimate': (row['pickup_schedule'] ?? '-').toString(),
          'image': assetImg,
        };
        _isLoadingOrder = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingOrder = false);
    }
  }

  // Ambil daftar layanan & harga dinamis dari tabel 'services'
  Future<void> _fetchServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final response = await Supabase.instance.client
          .from('services')
          .select('id, name, price, unit, subtitle')
          .order('name', ascending: true);

      if (!mounted) return;

      setState(() {
        _services = List.from(response);
        _isLoadingServices = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingServices = false);
      }
    }
  }

  // Pemetaan gambar lokal berdasarkan nama layanan di database
  String _resolveServiceAsset(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('kiloan')) {
      return 'assets/laundrykiloan.PNG';
    } else if (lower.contains('bed cover') || lower.contains('bedcover')) {
      return 'assets/laundrybedcover.PNG';
    } else if (lower.contains('boneka')) {
      return 'assets/laundryboneka.PNG';
    }
    return 'assets/laundrysatuan2.png';
  }

  // Format angka harga ke format Rupiah (contoh: 15000 -> Rp 15.000/pcs)
  String _formatServicePrice(dynamic rawPrice, dynamic rawUnit) {
    final int price = int.tryParse(rawPrice.toString()) ?? 0;
    final formattedNumber = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    final unit = (rawUnit ?? '').toString().trim();
    if (unit.isNotEmpty) {
      return 'Rp $formattedNumber/$unit';
    }
    return 'Rp $formattedNumber';
  }

  void _navigateToStatusPesanan() {
    if (activeOrderData == null) return;
    Navigator.pushNamed(
      context,
      '/status-pesanan',
      arguments: activeOrderData,
    ).then((_) => _fetchActiveOrder());
  }

  void _navigateToBooking(String serviceName) {
    Navigator.pushNamed(
      context,
      '/booking',
      arguments: serviceName,
    ).then((_) {
      _fetchActiveOrder();
      _fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _fetchActiveOrder(),
              _fetchServices(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profil & Sapaan
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo,',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1E465D),
                            ),
                          ),
                          Row(
                            children: [
                              ListenableBuilder(
                                listenable: UserProfileStore.instance,
                                builder: (context, _) => Text(
                                  UserProfileStore.instance.name.split(' ').first,
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B4E6C),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.favorite,
                                color: Color(0xFF9333EA),
                                size: 26,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Saatnya pakaian bersih lagi!',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
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
                              Navigator.pushNamed(
                                  context, '/order-notification');
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1B4E6C)
                                            .withOpacity(0.08),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Color(0xFF1B4E6C),
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
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Avatar Profil
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  const Color(0xFF1B4E6C).withOpacity(0.12),
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

                // Card Pesanan Aktif
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToStatusPesanan,
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
                                  colors: [
                                    Color(0xFFE0F2FE),
                                    Color(0xFFBAE6FD)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.asset(
                                activeOrderData?['image'] ??
                                    'assets/laundrykiloan.PNG',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          activeOrderData?['status'] ??
                                              'Tidak Ada',
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
                                    activeOrderData?['orderId'] ?? '-',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    activeOrderData != null
                                        ? '${activeOrderData!['serviceName']} (${activeOrderData!['weight']})'
                                        : 'Belum ada pesanan aktif',
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
                                    activeOrderData?['estimate'] ?? '-',
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

                // Sub-header Katalog Layanan
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Layanan Laundry',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B4E6C),
                        ),
                      ),
                      GestureDetector(
                        onTap: _fetchServices,
                        child: Text(
                          'Refresh',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF338CA8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid Katalog Layanan Dinamis dari Supabase ('services')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isLoadingServices
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF338CA8),
                      ),
                    ),
                  )
                      : _services.isEmpty
                      ? Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Belum ada layanan tersedia.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  )
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _services.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 256,
                    ),
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      final name =
                      (service['name'] ?? 'Layanan').toString();
                      final subtitle =
                      (service['subtitle'] ?? '').toString();
                      final formattedPrice = _formatServicePrice(
                        service['price'],
                        service['unit'],
                      );
                      final assetPath = _resolveServiceAsset(name);

                      return _buildServiceCard(
                        title: name,
                        desc: subtitle,
                        price: formattedPrice,
                        imagePath: assetPath,
                        onTap: () => _navigateToBooking(name),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background Frame Pastel dengan Gambar Besar Langsung di Tengah
            Container(
              width: double.infinity,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEBF7FD), Color(0xFFD8EEFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_laundry_service_rounded,
                      size: 36,
                      color: Color(0xFF338CA8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Judul Layanan
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            const SizedBox(height: 2),

            // Deskripsi
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.2,
                color: const Color(0xFF64748B),
                height: 1.2,
              ),
            ),

            const Spacer(),

            // Start From & Harga
            Text(
              'Start from',
              style: GoogleFonts.poppins(
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tombol "Pesan Sekarang"
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