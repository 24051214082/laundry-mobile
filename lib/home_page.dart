import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bottom_nav.dart';
import 'user_profile_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _activeOrders = [];
  int _currentOrderIndex = 0;
  late final PageController _orderPageController;
  bool _isLoadingOrder = true;

  // State dinamis untuk Katalog Layanan dari tabel 'services'
  var _services = [];
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _orderPageController = PageController();
    _fetchActiveOrders();
    _fetchServices();
  }

  @override
  void dispose() {
    _orderPageController.dispose();
    super.dispose();
  }

  void _goToOrderIndex(int index) {
    final total = _activeOrders.length;
    if (total <= 1) return;
    final int target = ((index % total) + total) % total;
    setState(() => _currentOrderIndex = target);
    if (_orderPageController.hasClients) {
      _orderPageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _fetchActiveOrders() async {
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

      final rows = await query.order('created_at', ascending: false);

      if (!mounted) return;

      final parsedOrders = [];
      for (final item in (rows as List)) {
        final row = Map<String, dynamic>.from(item as Map);
        final serviceName = (row['service_name'] ?? 'Laundry').toString();
        final assetImg = _resolveServiceAsset(serviceName);
        final rawPaymentStatus =
        (row['payment_status'] ?? '').toString().toLowerCase();

        parsedOrders.add({
          'dbId': row['id'].toString(),
          'orderId': (row['order_code'] ?? '-').toString(),
          'serviceName': serviceName,
          'weight': (row['weight_or_qty'] ?? '-').toString(),
          'treatment': (row['treatment'] ?? '-').toString(),
          'speed': (row['speed'] ?? '-').toString(),
          'perfume': (row['perfume_name'] ?? '-').toString(),
          'detergent': (row['detergent_name'] ?? '-').toString(),
          'pickupMethod': (row['pickup_method'] ?? 'Penjemputan').toString(),
          'deliveryMethod':
          (row['delivery_method'] ?? 'Diantar Kurir').toString(),
          'method':
          '${row['pickup_method'] ?? '-'} • ${row['delivery_method'] ?? '-'}',
          'address': (row['address'] ?? '-').toString(),
          'totalPrice': 'Rp ${row['total_price'] ?? 0}',
          'status': (row['status'] ?? 'Diproses').toString(),
          'estimate': (row['pickup_schedule'] ?? '-').toString(),
          'isPaid': rawPaymentStatus == 'lunas',
          'image': assetImg,
        });
      }

      int nextIndex = 0;
      if (parsedOrders.isNotEmpty) {
        if (_currentOrderIndex < 0) {
          nextIndex = 0;
        } else if (_currentOrderIndex >= parsedOrders.length) {
          nextIndex = parsedOrders.length - 1;
        } else {
          nextIndex = _currentOrderIndex;
        }
      }

      if (_orderPageController.hasClients &&
          _orderPageController.page?.round() != nextIndex) {
        _orderPageController.jumpToPage(nextIndex);
      }

      setState(() {
        _activeOrders = parsedOrders;
        _currentOrderIndex = nextIndex;
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

  void _navigateToStatusPesanan(Map<String, dynamic> order) {
    Navigator.pushNamed(
      context,
      '/status-pesanan',
      arguments: order,
    ).then((_) => _fetchActiveOrders());
  }

  void _navigateToBooking(String serviceName) {
    Navigator.pushNamed(
      context,
      '/booking',
      arguments: serviceName,
    ).then((_) {
      _fetchActiveOrders();
      _fetchServices();
    });
  }

  Widget _buildStepNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 15,
          color: const Color(0xFF0284C7),
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard({
    Map<String, dynamic>? order,
    String? positionLabel,
    bool showStepControls = false,
    bool isEmptyState = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEmptyState
            ? () => _navigateToBooking('Laundry Kiloan')
            : () => _navigateToStatusPesanan(order!),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B4E6C).withOpacity(0.09),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 78,
                height: 78,
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
                  order?['image']?.toString() ?? 'assets/laundrykiloan.PNG',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_laundry_service_rounded,
                    size: 40,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Pesanan Aktif',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B4E6C),
                                  ),
                                ),
                              ),
                              if (positionLabel != null) ...[
                                const SizedBox(width: 6),
                                if (showStepControls) ...[
                                  _buildStepNavButton(
                                    icon: Icons.chevron_left_rounded,
                                    onTap: () =>
                                        _goToOrderIndex(_currentOrderIndex - 1),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    positionLabel,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                                if (showStepControls) ...[
                                  const SizedBox(width: 4),
                                  _buildStepNavButton(
                                    icon: Icons.chevron_right_rounded,
                                    onTap: () =>
                                        _goToOrderIndex(_currentOrderIndex + 1),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEmptyState
                                ? 'Tidak Ada'
                                : (order?['status']?.toString() ?? 'Diproses'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7E22CE),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isEmptyState ? '-' : (order?['orderId']?.toString() ?? '-'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isEmptyState
                          ? 'Belum ada pesanan aktif'
                          : '${order!['serviceName']} (${order['weight']})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEmptyState
                          ? 'Ketuk untuk mulai pesan laundry'
                          : 'Estimasi selesai',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.2,
                      ),
                    ),
                    if (!isEmptyState)
                      Text(
                        order?['estimate']?.toString() ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0284C7),
                          height: 1.25,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 30,
                height: 30,
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
    );
  }

  Widget _buildActiveOrdersSection() {
    if (_isLoadingOrder && _activeOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          height: 144,
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
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF338CA8)),
          ),
        ),
      );
    }

    if (_activeOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SizedBox(
          height: 144,
          child: _buildActiveOrderCard(isEmptyState: true),
        ),
      );
    }

    final bool hasMultiple = _activeOrders.length > 1;

    return Column(
      children: [
        SizedBox(
          height: 144,
          child: PageView.builder(
            controller: _orderPageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _activeOrders.length,
            onPageChanged: (index) {
              setState(() => _currentOrderIndex = index);
            },
            itemBuilder: (context, index) {
              final order =
              Map<String, dynamic>.from(_activeOrders[index] as Map);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: _buildActiveOrderCard(
                  order: order,
                  positionLabel:
                  hasMultiple ? '${index + 1}/${_activeOrders.length}' : null,
                  showStepControls: hasMultiple,
                ),
              );
            },
          ),
        ),
        if (hasMultiple) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_activeOrders.length, (index) {
              final bool isActive = index == _currentOrderIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _goToOrderIndex(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 4,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF1B4E6C)
                          : const Color(0xFF1B4E6C).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _fetchActiveOrders(),
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
                                  UserProfileStore.instance.name
                                      .split(' ')
                                      .first,
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
                                context,
                                '/order-notification',
                              );
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
                                  color: const Color(0xFF1B4E6C)
                                      .withOpacity(0.12),
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

                // Card Pesanan Aktif (Swipeable Carousel + Klik Panah/Dot)
                _buildActiveOrdersSection(),

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