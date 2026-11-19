import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_bottom_nav.dart';
import 'order_confirmation_page.dart';
import 'order_detail_page.dart';
import 'payment_page.dart';
import 'user_session.dart';

class _AppColors {
  static const headerBlue = Color(0xFFD6EFFB);
  static const background = Color(0xFFF3F1F5);
  static const navy = Color(0xFF1F3A6E);
  static const primary = Color(0xFF338CA8);
  static const tabBackground = Color(0xFFEDEBEF);
  static const cardBorder = Color(0xFFB9D3DF);
  static const divider = Color(0xFFDDE8EE);
  static const buttonGrey = Color(0xFFE6E6E8);
  static const iconLight = Color(0xFFB7DDF0);
}

enum OrderStatus { dibatalkan, pengantaran, pencucian, selesai }

class OrderItem {
  final dynamic rowId;
  final String id;
  final String date;
  final String service;
  final String quantity;
  final String total;
  final String rawStatus;
  final String paymentStatus;
  final OrderStatus status;
  final OrderSummary? summary;

  const OrderItem({
    required this.rowId,
    required this.id,
    required this.date,
    required this.service,
    required this.quantity,
    required this.total,
    required this.rawStatus,
    required this.paymentStatus,
    required this.status,
    this.summary,
  });

  bool get isPaid => paymentStatus.trim().toLowerCase() == 'lunas';

  bool get canCancel =>
      !isPaid && status != OrderStatus.dibatalkan && status != OrderStatus.selesai;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final dynamic rowId = map['id'];
    final String orderCode = (map['order_code'] ?? '-').toString();
    final String serviceName = (map['service_name'] ?? 'Laundry').toString();
    final String speed = (map['speed'] ?? 'Reguler').toString();
    final String treatment = (map['treatment'] ?? 'Cuci Saja').toString();
    final String detergent =
    (map['detergent_name'] ?? 'Standar / Bawa Sendiri').toString();
    final String perfume =
    (map['perfume_name'] ?? 'Standar / Bawa Sendiri').toString();
    final String pickup = (map['pickup_method'] ?? 'Antar Sendiri').toString();
    final String delivery =
    (map['delivery_method'] ?? 'Ambil Sendiri').toString();
    final String schedule = (map['pickup_schedule'] ?? '-').toString();
    final String address = (map['address'] ?? '-').toString();
    final String weightOrQty = (map['weight_or_qty'] ?? '-').toString();
    final String rawStatus = (map['status'] ?? 'Penjemputan').toString();
    final String paymentStatus =
    (map['payment_status'] ?? 'Belum Lunas').toString();

    final int totalInt = (map['total_price'] is num)
        ? (map['total_price'] as num).toInt()
        : int.tryParse((map['total_price'] ?? '0').toString()) ?? 0;

    final String formattedTotal = _formatRupiah(totalInt);

    String formattedDate = '-';
    if (map['created_at'] != null) {
      final dt = DateTime.tryParse(map['created_at'].toString())?.toLocal();
      if (dt != null) {
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        formattedDate = '$day/$month/${dt.year}, $hour.$minute WIB';
      }
    }

    final lowerStatus = rawStatus.toLowerCase();
    OrderStatus mappedStatus;
    if (lowerStatus.contains('batal')) {
      mappedStatus = OrderStatus.dibatalkan;
    } else if (lowerStatus == 'selesai') {
      mappedStatus = OrderStatus.selesai;
    } else if (lowerStatus == 'pengantaran' ||
        lowerStatus == 'menunggu pengambilan') {
      mappedStatus = OrderStatus.pengantaran;
    } else {
      mappedStatus = OrderStatus.pencucian;
    }

    return OrderItem(
      rowId: rowId,
      id: orderCode,
      date: formattedDate,
      service: '$serviceName - $speed',
      quantity: weightOrQty,
      total: formattedTotal,
      rawStatus: rawStatus,
      paymentStatus: paymentStatus,
      status: mappedStatus,
      summary: OrderSummary(
        jenisLaundry: serviceName,
        kecepatan: speed,
        pengerjaan: treatment,
        deterjen: detergent,
        pewangi: perfume,
        metode: '$pickup • $delivery',
        pickupMethod: pickup,
        deliveryMethod: delivery,
        jadwal: schedule,
        alamat: address,
        estimatedTotal: totalInt,
        biaya: [
          CostItem('Layanan ($serviceName)', formattedTotal),
          if (weightOrQty != '-') CostItem('Berat / Jumlah', weightOrQty),
        ],
        subtotal: formattedTotal,
      ),
    );
  }

  static String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join()}';
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  static const List<String> _tabs = [
    'Semua',
    'Dalam Proses',
    'Selesai',
    'Dibatalkan',
  ];

  final _supabase = Supabase.instance.client;
  List<OrderItem> _orders = [];
  bool _isLoading = true;

  int _selectedTab = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() => _isLoading = true);
    try {
      var queryBuilder = _supabase.from('orders').select();

      // Filter berdasarkan user_id akun yang sedang login
      if (UserSession.userId != null && UserSession.userId!.isNotEmpty) {
        queryBuilder = queryBuilder.eq('user_id', UserSession.userId!);
      }

      final response = await queryBuilder.order('created_at', ascending: false);
      final List<dynamic> dataList = response as List<dynamic>;

      if (!mounted) return;
      setState(() {
        _orders = dataList
            .map((row) => OrderItem.fromMap(row as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal memuat riwayat pesanan: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    }
  }

  Future<void> _openOrderDetailPage(OrderItem order) async {
    final cancelled = await Navigator.pushNamed(
      context,
      '/order-detail',
      arguments: OrderDetailArgs(
        id: order.id,
        date: order.date,
        summary: order.summary,
        rowId: order.rowId,
        rawStatus: order.rawStatus,
        isPaid: order.isPaid,
        canCancel: order.canCancel,
      ),
    );

    if (!mounted) return;
    if (cancelled == true) {
      await _fetchOrderHistory();
    }
  }

  Future<void> _openPaymentPage(OrderItem order) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          orderId: order.id,
          serviceName: order.summary?.jenisLaundry ?? order.service,
          totalAmount: order.total,
          isPaid: order.isPaid,
        ),
      ),
    );

    if (!mounted) return;
    if (result == true || !order.isPaid) {
      await _fetchOrderHistory();
    }
  }

  List<OrderItem> get _filteredOrders {
    return _orders.where((o) {
      final matchTab = switch (_selectedTab) {
        1 => o.status == OrderStatus.pengantaran ||
            o.status == OrderStatus.pencucian,
        2 => o.status == OrderStatus.selesai,
        3 => o.status == OrderStatus.dibatalkan,
        _ => true,
      };
      final matchQuery =
      o.id.toLowerCase().contains(_query.trim().toLowerCase());
      return matchTab && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: _AppColors.background,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: _AppColors.primary),
            )
                : RefreshIndicator(
              onRefresh: _fetchOrderHistory,
              color: _AppColors.primary,
              child: orders.isEmpty
                  ? ListView(
                children: [
                  SizedBox(
                    height:
                    MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Text(
                        'Pesanan tidak ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _AppColors.navy.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: orders.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
                itemBuilder: (_, i) => _OrderCard(
                  order: orders[i],
                  onPayTap: () => _openPaymentPage(orders[i]),
                  onDetailTap: () =>
                      _openOrderDetailPage(orders[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _AppColors.headerBlue,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 24,
        20,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pantau dan lihat kembali riwayat pesanan laundry kamu',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.poppins(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Cari ID Pesanan',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _AppColors.tabBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = i == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                        selected ? _AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(color: Colors.white, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        _tabs[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : _AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem order;
  final VoidCallback onPayTap;
  final VoidCallback onDetailTap;

  const _OrderCard({
    required this.order,
    required this.onPayTap,
    required this.onDetailTap,
  });

  IconData get _icon {
    switch (order.status) {
      case OrderStatus.dibatalkan:
        return Icons.highlight_off_rounded;
      case OrderStatus.pengantaran:
        return Icons.delivery_dining_outlined;
      case OrderStatus.pencucian:
        return Icons.local_laundry_service_outlined;
      case OrderStatus.selesai:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color get _chipColor {
    switch (order.status) {
      case OrderStatus.dibatalkan:
        return const Color(0xFFFF6B6B);
      case OrderStatus.pengantaran:
      case OrderStatus.pencucian:
        return const Color(0xFFD3EEFB);
      case OrderStatus.selesai:
        return const Color(0xFF8FE5B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPay = !order.isPaid && order.status != OrderStatus.dibatalkan;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(_icon, size: 38, color: _AppColors.iconLight),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.navy,
                        ),
                      ),
                      Text(
                        order.date,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isPaid
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          order.paymentStatus,
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: order.isPaid
                                ? const Color(0xFF166534)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _chipColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.rawStatus,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: order.status == OrderStatus.dibatalkan
                          ? Colors.white
                          : _AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.service,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _AppColors.navy,
                          ),
                          children: [
                            const TextSpan(text: 'Jumlah: '),
                            TextSpan(
                              text: order.quantity,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Biaya',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.total,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canPay) ...[
                  GestureDetector(
                    onTap: onPayTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: _AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Bayar Sekarang',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Material(
                  color: _AppColors.buttonGrey,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: onDetailTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      child: Text(
                        'Detail Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
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