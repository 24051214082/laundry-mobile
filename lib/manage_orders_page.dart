import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_confirmation_page.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class AdminOrderModel {
  final String id;
  final String customerName;
  final String orderDate;
  final OrderSummary summary;
  String status;
  String finalPrice;
  bool isPriceLocked;

  AdminOrderModel({
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.summary,
    required this.status,
    required this.finalPrice,
    this.isPriceLocked = false,
  });
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  // Filter utama yang dipilih di navbar
  String _activeFilter = 'Semua';

  // Controller untuk kotak pencarian (search bar)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _statusSequence = [
    'Penjemputan',
    'Konfirmasi Harga',
    'Menunggu Pembayaran',
    'Waiting',
    'Pencucian',
    'Pengeringan',
    'Penyetrikaan',
    'Pengantaran',
    'Menunggu Pengambilan',
    'Selesai',
  ];

  final List<AdminOrderModel> _orders = [
    AdminOrderModel(
      id: '#LKN4wa123',
      customerName: 'cust a',
      orderDate: '6 November 2026, 09:00 WIB',
      status: 'Penjemputan',
      finalPrice: 'Rp35.000',
      isPriceLocked: false,
      summary: const OrderSummary(
        jenisLaundry: 'Laundry Kiloan',
        kecepatan: 'Reguler',
        pengerjaan: 'Cuci + Setrika',
        deterjen: 'Rinso Gentle',
        pewangi: 'Molto Floral',
        metode: 'Jemput: Penjemputan • Kirim: Diantar Kurir',
        jadwal: '6 November 2026, 09:00 WIB',
        alamat: 'Jl. Ketintang Madya No. 45, Surabaya',
        biaya: [
          CostItem('Tarif minimum kiloan (7kg)', 'Rp20.000'),
          CostItem('Layanan Cuci + Setrika', 'Rp5.000'),
          CostItem('Deterjen (Rinso Gentle)', 'Rp1.000'),
          CostItem('Pewangi (Molto Floral)', 'Rp1.000'),
        ],
        subtotal: 'Rp35.000',
      ),
    ),
    AdminOrderModel(
      id: '#LKN4wa456',
      customerName: 'cust b',
      orderDate: '6 November 2026, 10:15 WIB',
      status: 'Konfirmasi Harga',
      finalPrice: 'Rp20.000',
      isPriceLocked: false,
      summary: const OrderSummary(
        jenisLaundry: 'Satuan: Jaket Jeans',
        kecepatan: 'Reguler',
        pengerjaan: 'Cuci Saja',
        deterjen: 'Standar / Bawa Sendiri',
        pewangi: 'Downy Mystique',
        metode: 'Jemput: Antar Sendiri • Kirim: Ambil Sendiri',
        jadwal: 'Pelanggan antar langsung ke outlet',
        alamat: 'Antar ke outlet: Jl. Ketintang Baru No. 12, Wonokromo, Surabaya',
        biaya: [
          CostItem('Satuan (Jaket Jeans)', 'Mulai Rp20.000'),
          CostItem('Pewangi (Downy Mystique)', 'Rp1.000'),
        ],
        subtotal: 'Mulai Rp21.000',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Logika pencocokan filter kategori dan kotak pencarian (ID Pesanan / Nama Pelanggan)
  List<AdminOrderModel> get _filteredOrders {
    List<AdminOrderModel> results = _orders;

    // Filter berdasarkan Navbar Kategori
    if (_activeFilter == 'Diproses') {
      results = results.where((o) => o.status == 'Pencucian' || o.status == 'Pengeringan' || o.status == 'Penyetrikaan').toList();
    } else if (_activeFilter == 'Penyerahan Pesanan') {
      results = results.where((o) => o.status == 'Pengantaran' || o.status == 'Menunggu Pengambilan').toList();
    } else if (_activeFilter != 'Semua') {
      results = results.where((o) => o.status == _activeFilter).toList();
    }

    // Filter berdasarkan Input Search (ID Pesanan atau Nama Customer)
    if (_searchQuery.isNotEmpty) {
      results = results.where((o) =>
      o.id.toLowerCase().contains(_searchQuery) ||
          o.customerName.toLowerCase().contains(_searchQuery)).toList();
    }

    return results;
  }

  void _advanceStatus(AdminOrderModel order) {
    if (order.status == 'Penyetrikaan') {
      setState(() {
        bool isDelivery = order.summary.metode.toLowerCase().contains('diantar kurir') ||
            order.summary.metode.toLowerCase().contains('kurir');
        if (isDelivery) {
          order.status = 'Pengantaran';
        } else {
          order.status = 'Menunggu Pengambilan';
        }
        order.isPriceLocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F3A6E),
          duration: const Duration(seconds: 1),
          content: Text(
            'Status ${order.id} diperbarui menjadi: "${order.status}"',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
      return;
    }

    if (order.status == 'Pengantaran' || order.status == 'Menunggu Pengambilan') {
      setState(() {
        order.status = 'Selesai';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 1),
          content: Text(
            'Pesanan ${order.id} telah diselesaikan sepenuhnya!',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
      return;
    }

    int currentIndex = _statusSequence.indexOf(order.status);
    if (currentIndex != -1 && currentIndex < _statusSequence.length - 1) {
      setState(() {
        order.status = _statusSequence[currentIndex + 1];
        if (_statusSequence.indexOf(order.status) >= 2) {
          order.isPriceLocked = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F3A6E),
          duration: const Duration(seconds: 1),
          content: Text(
            'Status ${order.id} diperbarui menjadi: "${order.status}"',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showConfirmPriceDialog(AdminOrderModel order) {
    final TextEditingController priceController = TextEditingController(text: order.finalPrice);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Harga (${order.id})',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1F3A6E)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan harga final. Setelah dikonfirmasi, harga akan dikunci dan pesanan dilanjutkan ke tahap pembayaran (tidak bisa diubah lagi).',
                style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Harga Final (Rp)',
                  labelStyle: GoogleFonts.poppins(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F3A6E)),
              onPressed: () {
                setState(() {
                  order.finalPrice = priceController.text;
                  order.isPriceLocked = true;
                  order.status = 'Menunggu Pembayaran';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF16A34A),
                    duration: const Duration(seconds: 1),
                    content: Text(
                      'Harga dikonfirmasi (${order.finalPrice}) dan dikunci.',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                    ),
                  ),
                );
              },
              child: Text('Konfirmasi & Kunci Harga', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Pop-up Detail Pesanan ketika tombol "Detail Pesanan" diklik
  void _showDetailDialog(AdminOrderModel order) {
    bool isPickUp = order.summary.metode.toLowerCase().contains('penjemputan');
    bool showPickUpSection = isPickUp && order.status == 'Penjemputan';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            'Detail Pesanan (${order.id})',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1F3A6E)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pelanggan: ${order.customerName}', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Text('Tanggal: ${order.orderDate}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                  const Divider(height: 16),

                  if (showPickUpSection) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Penjemputan', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF92400E))),
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
                  Text('Rincian Biaya:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1F3A6E))),
                  const SizedBox(height: 4),
                  ...order.summary.biaya.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      item.toString(),
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Harga Final:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(order.finalPrice, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1F3A6E))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup', style: GoogleFonts.poppins(color: const Color(0xFF1F3A6E))),
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F3A6E), size: 20),
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
      ),
      body: Column(
        children: [
          // Kotak Pencarian (Search Bar) di bagian atas seperti referensi
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            color: const Color(0xFFD6EFFB).withOpacity(0.4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari ID Pesanan atau Nama Cust...',
                hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1F3A6E), size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1F3A6E)),
            ),
          ),

          // Navbar Filter yang Dikelompokkan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFD6EFFB).withOpacity(0.4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Semua',
                  'Penjemputan',
                  'Konfirmasi Harga',
                  'Menunggu Pembayaran',
                  'Waiting',
                  'Diproses',
                  'Penyerahan Pesanan',
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : const Color(0xFF1F3A6E),
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
            child: _filteredOrders.isEmpty
                ? Center(
              child: Text(
                'Tidak ada pesanan yang sesuai',
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
              ),
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
        ],
      ),
    );
  }

  // Desain kartu ringkas mirip halaman riwayat pelanggan dengan tombol Detail Pesanan
  Widget _buildAdminOrderCard(AdminOrderModel order) {
    String buttonText = 'Lanjut Tahap Berikutnya ➔';
    if (order.status == 'Penjemputan') {
      buttonText = 'Selesai';
    } else if (order.status == 'Menunggu Pembayaran') {
      buttonText = 'Konfirmasi Pembayaran ➔';
    } else if (order.status == 'Pengantaran' || order.status == 'Menunggu Pengambilan') {
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
          // 1. Bagian Atas: ID Pesanan, Tanggal, dan Status
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
                      style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // 2. Bagian Tengah: Nama Layanan, Pelanggan, & Total Biaya
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
                        style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Biaya',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
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

          // 3. Bagian Bawah: Tombol "Detail Pesanan" & Aksi Admin
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _showDetailDialog(order),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    'Detail Pesanan',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                  ),
                ),

                Row(
                  children: [
                    if (!order.isPriceLocked && order.status == 'Konfirmasi Harga')
                      TextButton.icon(
                        onPressed: () => _showConfirmPriceDialog(order),
                        icon: const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF263F73)),
                        label: Text('Kunci Harga', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF263F73))),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      ),

                    const SizedBox(width: 6),

                    if (order.status != 'Selesai')
                      ElevatedButton(
                        onPressed: (!order.isPriceLocked && order.status == 'Konfirmasi Harga')
                            ? null
                            : () => _advanceStatus(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3A6E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Selesai 100%',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green.shade800),
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
              style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade600),
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