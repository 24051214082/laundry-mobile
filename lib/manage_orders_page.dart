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

  // Logika pencocokan filter kategori terkelompok
  List<AdminOrderModel> get _filteredOrders {
    if (_activeFilter == 'Semua') return _orders;
    if (_activeFilter == 'Diproses') {
      return _orders.where((o) => o.status == 'Pencucian' || o.status == 'Pengeringan' || o.status == 'Penyetrikaan').toList();
    }
    if (_activeFilter == 'Penyerahan Pesanan') {
      return _orders.where((o) => o.status == 'Pengantaran' || o.status == 'Menunggu Pengambilan').toList();
    }
    return _orders.where((o) => o.status == _activeFilter).toList();
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
          // Navbar Filter yang Dikelompokkan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  'Diproses', // Kelompok: Pencucian, Pengeringan, Penyetrikaan
                  'Penyerahan Pesanan', // Kelompok: Pengantaran, Menunggu Pengambilan
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
                'Tidak ada pesanan dengan filter "$_activeFilter"',
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

  Widget _buildAdminOrderCard(AdminOrderModel order) {
    bool isPickUp = order.summary.metode.toLowerCase().contains('penjemputan');
    bool showPickUpSection = isPickUp && order.status == 'Penjemputan';

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9D3DF), width: 1),
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
          Row(
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
                  borderRadius: BorderRadius.circular(8),
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
          const Divider(height: 16, thickness: 0.8),

          Text(
            order.customerName,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F3A6E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            order.summary.jenisLaundry,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF263F73),
            ),
          ),
          const SizedBox(height: 10),

          if (showPickUpSection) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded, size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Text(
                        'Penjemputan',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF92400E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow('Jadwal', order.summary.jadwal),
                  _buildInfoRow('Alamat', order.summary.alamat),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Kecepatan', order.summary.kecepatan),
                _buildInfoRow('Pengerjaan', order.summary.pengerjaan),
                _buildInfoRow('Deterjen', order.summary.deterjen),
                _buildInfoRow('Pewangi', order.summary.pewangi),
                _buildInfoRow('Metode', order.summary.metode),
                if (!isPickUp) _buildInfoRow('Alamat / Outlet', order.summary.alamat),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Harga Final: ',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade700),
                  ),
                  Text(
                    order.finalPrice,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1F3A6E)),
                  ),
                  const SizedBox(width: 6),
                  if (order.isPriceLocked)
                    const Icon(Icons.lock_rounded, size: 14, color: Colors.green)
                  else
                    const Icon(Icons.lock_open_rounded, size: 14, color: Colors.orange),
                ],
              ),
              if (!order.isPriceLocked)
                TextButton.icon(
                  onPressed: () => _showConfirmPriceDialog(order),
                  icon: const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF263F73)),
                  label: Text('Konfirmasi & Kunci Harga', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF263F73))),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                )
              else
                Text(
                  'Harga Dikunci (Terkunci)',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const Divider(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.status == 'Selesai' ? 'Pesanan Selesai' : 'Tahap Berikutnya:',
                style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
              ),
              if (order.status != 'Selesai')
                ElevatedButton(
                  onPressed: (!order.isPriceLocked && order.status == 'Konfirmasi Harga')
                      ? null
                      : () => _advanceStatus(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263F73),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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