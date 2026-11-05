import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bottom_nav.dart';
import 'order_confirmation_page.dart';
import 'order_detail_page.dart';

// ---------------------------------------------------------------------------
// Halaman Riwayat Pesanan
// Letakkan di: lib/order_history_page.dart
// Footer memakai widget bersama AppBottomNav (lib/app_bottom_nav.dart).
// ---------------------------------------------------------------------------

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
  final String id;
  final String date;
  final String service;
  final String quantity;
  final String total;
  final OrderStatus status;
  final OrderSummary? summary; // rincian untuk halaman Detail Pesanan

  const OrderItem({
    required this.id,
    required this.date,
    required this.service,
    required this.quantity,
    required this.total,
    required this.status,
    this.summary,
  });
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

  // Data dummy, nanti bisa diganti dengan data dari API / database.
  final List<OrderItem> _orders = const [
    OrderItem(
      id: 'LKN4wa126',
      date: 'xx/xx/xxxx, 00.00 WIB',
      service: 'Laundry Boneka - Besar',
      quantity: '1 Pc',
      total: 'Rp2xxxx',
      status: OrderStatus.dibatalkan,
      summary: OrderSummary(
        jenisLaundry: 'Satuan',
        kecepatan: 'Reguler',
        pengerjaan: 'Cuci saja',
        deterjen: 'Tanpa deterjen',
        pewangi: 'Tanpa pewangi',
        metode: 'Antar Sendiri',
        jadwal: '22 Oktober 2026 - 08.00',
        alamat: 'xxxxxxx',
        biaya: [
          CostItem('Harga per barang', 'Dikonfirmasi admin'),
        ],
        subtotal: 'Rp2xxxx',
      ),
    ),
    OrderItem(
      id: 'LKN4wa125',
      date: 'xx/xx/xxxx, 00.00 WIB',
      service: 'Laundry Kiloan - Express',
      quantity: '7 Kg',
      total: 'Rp2xxxx',
      status: OrderStatus.pengantaran,
      summary: OrderSummary(
        jenisLaundry: 'Kiloan',
        kecepatan: 'Express',
        pengerjaan: 'Cuci + Setrika',
        deterjen: 'Deterjen A',
        pewangi: 'Pewangi A',
        metode: 'Penjemputan',
        jadwal: '22 Oktober 2026 - 08.00',
        alamat: 'xxxxxxx',
        biaya: [
          CostItem('Berat minimum', 'Rp20.000'),
          CostItem('Berat Tambahan', 'Rp3.000'),
          CostItem('Biaya Express', 'Rpxxxxxx'),
          CostItem('Cuci + Setrika', 'Rpxxxxxx'),
          CostItem('Tambahan Deterjen', 'Rp1.000'),
          CostItem('Tambahan Pewangi', 'Rp1.000'),
        ],
        subtotal: 'Rp2xxxx',
      ),
    ),
    OrderItem(
      id: 'LKN4wa124',
      date: 'xx/xx/xxxx, 00.00 WIB',
      service: 'Laundry Bedcover - Kecil',
      quantity: '2 Pcs',
      total: 'Rp3xxxx',
      status: OrderStatus.pencucian,
      summary: OrderSummary(
        jenisLaundry: 'Satuan',
        kecepatan: 'Reguler',
        pengerjaan: 'Cuci + Setrika',
        deterjen: 'Deterjen B',
        pewangi: 'Tanpa pewangi',
        metode: 'Penjemputan',
        jadwal: '22 Oktober 2026 - 08.00',
        alamat: 'xxxxxxx',
        biaya: [
          CostItem('Harga per barang', 'Dikonfirmasi admin'),
          CostItem('Cuci + Setrika', 'Rpxxxxxx'),
          CostItem('Tambahan Deterjen', 'Rp1.000'),
        ],
        subtotal: 'Rp3xxxx',
      ),
    ),
    OrderItem(
      id: 'LKN4wa123',
      date: 'xx/xx/xxxx, 00.00 WIB',
      service: 'Laundry Satuan - Reguler',
      quantity: '1 Pc',
      total: 'Rp1xxxx',
      status: OrderStatus.selesai,
      summary: OrderSummary(
        jenisLaundry: 'Satuan',
        kecepatan: 'Reguler',
        pengerjaan: 'Cuci saja',
        deterjen: 'Tanpa deterjen',
        pewangi: 'Tanpa pewangi',
        metode: 'Antar Sendiri',
        jadwal: '22 Oktober 2026 - 08.00',
        alamat: 'xxxxxxx',
        biaya: [
          CostItem('Harga per barang', 'Dikonfirmasi admin'),
        ],
        subtotal: 'Rp1xxxx',
      ),
    ),
  ];

  int _selectedTab = 0;
  String _query = '';

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
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          'Pesanan tidak ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _AppColors.navy.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
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
          // Search bar
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
          // Tab filter
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
                        color: selected ? _AppColors.primary : Colors.transparent,
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

// ---------------------------------------------------------------------------
// Kartu pesanan
// ---------------------------------------------------------------------------
class _OrderCard extends StatelessWidget {
  final OrderItem order;

  const _OrderCard({required this.order});

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

  String get _label {
    switch (order.status) {
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
      case OrderStatus.pengantaran:
        return 'Pengantaran';
      case OrderStatus.pencucian:
        return 'Pencucian';
      case OrderStatus.selesai:
        return 'Selesai';
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
          // Baris atas: ikon, ID, tanggal, status
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
                    _label,
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
          // Baris tengah: layanan & total
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
          // Tombol detail
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/order-detail',
                    arguments: OrderDetailArgs(
                      id: order.id,
                      date: order.date,
                      summary: order.summary,
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: _AppColors.buttonGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
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
          ),
        ],
      ),
    );
  }
}