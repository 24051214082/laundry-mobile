import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_confirmation_page.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class AdminOrderModel {
  final String dbId;
  final String? userId;
  final String id;
  final String customerName;
  final String orderDate;
  final String pickupMethod;
  final String deliveryMethod;
  final OrderSummary summary;
  String status;
  String finalPrice;
  int numericPrice;
  bool isPriceLocked;

  AdminOrderModel({
    required this.dbId,
    this.userId,
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.pickupMethod,
    required this.deliveryMethod,
    required this.summary,
    required this.status,
    required this.finalPrice,
    required this.numericPrice,
    this.isPriceLocked = false,
  });

  factory AdminOrderModel.fromMap(Map<String, dynamic> map) {
    final String orderCode = (map['order_code'] ?? '-').toString();
    final String custName = (map['customer_name'] ?? 'Pelanggan').toString();
    final String serviceName = (map['service_name'] ?? 'Laundry').toString();
    final String speed = (map['speed'] ?? 'Reguler').toString();
    final String treatment = (map['treatment'] ?? 'Cuci Saja').toString();
    final String detergent =
        (map['detergent_name'] ?? 'Standar / Bawa Sendiri').toString();
    final String perfume =
        (map['perfume_name'] ?? 'Standar / Bawa Sendiri').toString();
    final String pickup = (map['pickup_method'] ?? 'Penjemputan').toString();
    final String delivery =
        (map['delivery_method'] ?? 'Diantar Kurir').toString();
    final String schedule = (map['pickup_schedule'] ?? '-').toString();
    final String address = (map['address'] ?? '-').toString();
    final String weightOrQty = (map['weight_or_qty'] ?? '').toString();

    final String defaultStatus =
        pickup.toLowerCase().contains('antar sendiri')
            ? 'Pesanan Masuk'
            : 'Penjemputan';
    final String status = (map['status'] ?? defaultStatus).toString();

    final int totalInt = (map['total_price'] is num)
        ? (map['total_price'] as num).toInt()
        : int.tryParse((map['total_price'] ?? '0').toString()) ?? 0;

    final String formattedPrice = _formatRupiah(totalInt);

    String formattedDate = '-';
    if (map['created_at'] != null) {
      final dt = DateTime.tryParse(map['created_at'].toString())?.toLocal();
      if (dt != null) {
        const months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        formattedDate =
            '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute WIB';
      }
    }

    final bool locked = status != 'Penjemputan' &&
        status != 'Pesanan Masuk' &&
        status != 'Konfirmasi Harga';

    return AdminOrderModel(
      dbId: map['id'].toString(),
      userId: map['user_id']?.toString(),
      id: orderCode,
      customerName: custName,
      orderDate: formattedDate,
      pickupMethod: pickup,
      deliveryMethod: delivery,
      status: status,
      finalPrice: formattedPrice,
      numericPrice: totalInt,
      isPriceLocked: locked,
      summary: OrderSummary(
        jenisLaundry:
            weightOrQty.isNotEmpty ? '$serviceName ($weightOrQty)' : serviceName,
        kecepatan: speed,
        pengerjaan: treatment,
        deterjen: detergent,
        pewangi: perfume,
        metode: 'Jemput: $pickup • Kirim: $delivery',
        jadwal: schedule,
        alamat: address,
        biaya: [
          CostItem('Layanan ($serviceName)', formattedPrice),
          if (weightOrQty.isNotEmpty) CostItem('Berat / Jumlah', weightOrQty),
        ],
        subtotal: formattedPrice,
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

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final _supabase = Supabase.instance.client;

  String _activeFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isLoading = true;
  List<AdminOrderModel> _orders = [];

  // Urutan tahap proses di outlet
  final List<String> _mainSequence = [
    'Konfirmasi Harga',
    'Menunggu Pembayaran',
    'Waiting',
    'Pencucian',
    'Pengeringan',
    'Penyetrikaan',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> dataList = response as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _orders = dataList
            .map((row) => AdminOrderModel.fromMap(row as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            'Gagal memuat pesanan: $e',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _sendStatusNotification(
      AdminOrderModel order, String newStatus) async {
    try {
      await _supabase.from('notifications').insert({
        if (order.userId != null) 'user_id': order.userId,
        'order_code': order.id,
        'title': newStatus,
        'message':
            'Status pesanan ${order.id} (${order.summary.jenisLaundry}) diperbarui menjadi $newStatus.',
        'is_read': false,
      });
    } catch (_) {}
  }

  List<AdminOrderModel> get _filteredOrders {
    List<AdminOrderModel> results = _orders;

    if (_activeFilter == 'Diproses') {
      results = results
          .where((o) =>
              o.status == 'Pencucian' ||
              o.status == 'Pengeringan' ||
              o.status == 'Penyetrikaan')
          .toList();
    } else if (_activeFilter != 'Semua') {
      results = results.where((o) => o.status == _activeFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      results = results
          .where((o) =>
              o.id.toLowerCase().contains(_searchQuery) ||
              o.customerName.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return results;
  }

  Future<void> _advanceStatus(AdminOrderModel order) async {
    String nextStatus = order.status;

    if (order.status == 'Penjemputan' || order.status == 'Pesanan Masuk') {
      nextStatus = 'Konfirmasi Harga';
    } else if (order.status == 'Penyetrikaan') {
      final bool isDelivery =
          order.deliveryMethod.toLowerCase().contains('diantar kurir');
      nextStatus = isDelivery ? 'Pengantaran' : 'Menunggu Pengambilan';
    } else if (order.status == 'Pengantaran' ||
        order.status == 'Menunggu Pengambilan') {
      nextStatus = 'Selesai';
    } else {
      final int idx = _mainSequence.indexOf(order.status);
      if (idx != -1 && idx < _mainSequence.length - 1) {
        nextStatus = _mainSequence[idx + 1];
      } else {
        return;
      }
    }

    final Map<String, dynamic> updatePayload = {'status': nextStatus};
    if (order.status == 'Menunggu Pembayaran') {
      updatePayload['payment_status'] = 'Lunas';
    }

    try {
      await _supabase
          .from('orders')
          .update(updatePayload)
          .eq('id', order.dbId);

      await _sendStatusNotification(order, nextStatus);

      if (!mounted) return;
      setState(() {
        order.status = nextStatus;
        if (order.status != 'Penjemputan' &&
            order.status != 'Pesanan Masuk' &&
            order.status != 'Konfirmasi Harga') {
          order.isPriceLocked = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: nextStatus == 'Selesai'
              ? const Color(0xFF16A34A)
              : const Color(0xFF1F3A6E),
          duration: const Duration(seconds: 1),
          content: Text(
            nextStatus == 'Selesai'
                ? 'Pesanan ${order.id} telah diselesaikan sepenuhnya!'
                : 'Status ${order.id} diperbarui menjadi: "$nextStatus"',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            'Gagal memperbarui status: $e',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showConfirmPriceDialog(AdminOrderModel order) {
    final TextEditingController priceController = TextEditingController(
        text: order.numericPrice > 0 ? order.numericPrice.toString() : '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Harga (${order.id})',
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F3A6E)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan harga final (angka saja, misal: 35000). Setelah dikonfirmasi, harga dikunci dan pesanan dilanjutkan ke tahap pembayaran.',
                style: GoogleFonts.poppins(
                    fontSize: 11.5, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Final (Rp)',
                  hintText: 'Contoh: 35000',
                  labelStyle: GoogleFonts.poppins(fontSize: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3A6E)),
              onPressed: () async {
                final digitsOnly =
                    priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                final int parsedPrice = int.tryParse(digitsOnly) ?? 0;

                if (parsedPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: Text(
                        'Masukkan nominal harga yang valid!',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await _supabase.from('orders').update({
                    'total_price': parsedPrice,
                    'status': 'Menunggu Pembayaran',
                  }).eq('id', order.dbId);

                  await _sendStatusNotification(order, 'Menunggu Pembayaran');

                  if (!mounted) return;
                  Navigator.pop(dialogContext);

                  setState(() {
                    order.numericPrice = parsedPrice;
                    order.finalPrice =
                        AdminOrderModel._formatRupiah(parsedPrice);
                    order.isPriceLocked = true;
                    order.status = 'Menunggu Pembayaran';
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF16A34A),
                      duration: const Duration(seconds: 1),
                      content: Text(
                        'Harga dikonfirmasi (${order.finalPrice}) dan dikunci.',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: Text(
                        'Gagal menyimpan harga: $e',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              child: Text('Konfirmasi & Kunci Harga',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(AdminOrderModel order) {
    bool isPickUp = order.pickupMethod.toLowerCase().contains('penjemputan');
    bool showPickUpSection = isPickUp && order.status == 'Penjemputan';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            'Detail Pesanan (${order.id})',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F3A6E)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pelanggan: ${order.customerName}',
                      style: GoogleFonts.poppins(
                          fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Text('Tanggal: ${order.orderDate}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey.shade600)),
                  const Divider(height: 16),
                  if (showPickUpSection) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Penjemputan',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E))),
                          _buildInfoRow('Jadwal', order.summary.jadwal),
                          _buildInfoRow('Alamat', order.summary.alamat),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _buildInfoRow('Layanan', order.summary.jenisLaundry),
                  _buildInfoRow('Kecepatan', order.summary.kecepatan),
                  _buildInfoRow('Pengerjaan', order.summary.pengerjaan),
                  _buildInfoRow('Deterjen', order.summary.deterjen),
                  _buildInfoRow('Pewangi', order.summary.pewangi),
                  _buildInfoRow('Metode', order.summary.metode),
                  const Divider(height: 16),
                  Text('Rincian Biaya:',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F3A6E))),
                  const SizedBox(height: 4),
                  ...order.summary.biaya.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          item.toString(),
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade700),
                        ),
                      )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Harga Final:',
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(order.finalPrice,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F3A6E))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup',
                  style: GoogleFonts.poppins(color: const Color(0xFF1F3A6E))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6EFFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1F3A6E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manajemen Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F3A6E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1F3A6E)),
            tooltip: 'Muat Ulang',
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            color: const Color(0xFFD6EFFB).withOpacity(0.4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari ID Pesanan atau Nama Cust...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12.5, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF1F3A6E), size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF1F3A6E)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFD6EFFB).withOpacity(0.4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Semua',
                  'Penjemputan',
                  'Pesanan Masuk',
                  'Konfirmasi Harga',
                  'Menunggu Pembayaran',
                  'Waiting',
                  'Diproses',
                  'Pengantaran',
                  'Menunggu Pengambilan',
                  'Selesai'
                ].map((filter) {
                  final isSelected = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1F3A6E),
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color:
                            isSelected ? Colors.white : const Color(0xFF1F3A6E),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _activeFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1F3A6E)),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    color: const Color(0xFF1F3A6E),
                    child: _filteredOrders.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Text(
                                    'Tidak ada pesanan yang sesuai',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return _buildAdminOrderCard(order);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOrderCard(AdminOrderModel order) {
    String buttonText = 'Lanjut Tahap Berikutnya ➔';
    if (order.status == 'Penjemputan') {
      buttonText = 'Selesai Jemput ➔';
    } else if (order.status == 'Pesanan Masuk') {
      buttonText = 'Cucian Diterima ➔';
    } else if (order.status == 'Menunggu Pembayaran') {
      buttonText = 'Konfirmasi Pembayaran ➔';
    } else if (order.status == 'Pengantaran' ||
        order.status == 'Menunggu Pengambilan') {
      buttonText = 'Selesai';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F3A6E).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F3A6E),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      order.orderDate,
                      style: GoogleFonts.poppins(
                          fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EEF3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F3A6E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.summary.jenisLaundry,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F3A6E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pelanggan: ${order.customerName}',
                        style: GoogleFonts.poppins(
                            fontSize: 11.5, color: Colors.grey.shade600),
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
                          fontSize: 10, color: Colors.grey.shade600),
                    ),
                    Text(
                      order.finalPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F3A6E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _showDetailDialog(order),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    'Detail Pesanan',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155)),
                  ),
                ),
                Row(
                  children: [
                    if (!order.isPriceLocked &&
                        order.status == 'Konfirmasi Harga')
                      TextButton.icon(
                        onPressed: () => _showConfirmPriceDialog(order),
                        icon: const Icon(Icons.check_circle_outline,
                            size: 14, color: Color(0xFF263F73)),
                        label: Text('Kunci Harga',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: const Color(0xFF263F73))),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    const SizedBox(width: 6),
                    if (order.status != 'Selesai')
                      ElevatedButton(
                        onPressed: (!order.isPriceLocked &&
                                order.status == 'Konfirmasi Harga')
                            ? null
                            : () => _advanceStatus(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3A6E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Selesai 100%',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade800),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 10.5, color: Colors.grey.shade600),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F3A6E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}