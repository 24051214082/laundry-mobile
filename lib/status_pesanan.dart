import 'package:flutter/material.dart';
import 'payment_page.dart';

class StatusPesananPage extends StatefulWidget {
  const StatusPesananPage({super.key});

  @override
  State<StatusPesananPage> createState() => _StatusPesananPageState();
}

class _StatusPesananPageState extends State<StatusPesananPage> {
  bool _isPaid = false;
  bool _isInit = false;

  late Map<String, dynamic> _orderData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _orderData =
          (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
              {
                'orderId': '#LKN4wa123',
                'serviceName': 'Laundry Kiloan',
                'weight': '5.0 kg',
                'treatment': 'Cuci + Setrika',
                'totalPrice': 'Rp 35.000',
                'status': 'Diproses',
                'estimate': '18 April 2027, 08.00',
                'isPaid': false,
              };

      _isPaid = _orderData['isPaid'] ?? false;
      _isInit = true;
    }
  }

  Future<void> _openPaymentPage() async {
    final String orderId = _orderData['orderId'] ?? '#LKN4wa123';
    final String serviceName = _orderData['serviceName'] ?? 'Laundry Kiloan';
    final String weight = _orderData['weight'] ?? '5.0 kg';
    final String totalAmount = _orderData['totalPrice'] ?? 'Rp 35.000';

    // Langsung navigasi ke PaymentPage sambil mengirim detail tagihan & status bayar
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          orderId: orderId,
          serviceName: '$serviceName ($weight)',
          totalAmount: totalAmount,
          isPaid: _isPaid,
        ),
      ),
    );

    // Jika pelanggan menyelesaikan pembayaran di PaymentPage, update state halaman ini
    if (result is bool && result == true) {
      setState(() {
        _isPaid = true;
        _orderData['isPaid'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String orderId = _orderData['orderId'] ?? '#LKN4wa123';
    final String serviceName = _orderData['serviceName'] ?? 'Laundry Kiloan';
    final String weight = _orderData['weight'] ?? '5.0 kg';
    final String treatment = _orderData['treatment'] ?? 'Cuci + Setrika';
    final String totalAmount = _orderData['totalPrice'] ?? 'Rp 35.000';
    final String status = _orderData['status'] ?? 'Diproses';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3EEF3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Status Pesanan',
          style: TextStyle(
            color: Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header No Pesanan & Badge Dinamis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. Pesanan $orderId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '22 Oktober 2026 17.20',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE6F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Progres Pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progres Pesanan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Timeline Item 1 - 11 (Step 4 & 5 menyesuaikan status bayar)
                  _buildTimelineItem(step: '1', title: 'Konfirmasi Pesanan', subtitle: '22 Oktober 2026 - 17.35', isCompleted: true, isCurrent: false, showLine: true),
                  _buildTimelineItem(step: '2', title: 'Menunggu Penjemputan', subtitle: '22 Oktober 2026 - 17.35', isCompleted: true, isCurrent: false, showLine: true),
                  _buildTimelineItem(step: '3', title: 'Cucian Dijemput dan Ditimbang', subtitle: '22 Oktober 2026 - 17.35', isCompleted: true, isCurrent: false, showLine: true),
                  _buildTimelineItem(
                    step: '4',
                    title: 'Menunggu Pembayaran',
                    subtitle: _isPaid ? 'Pembayaran Selesai' : 'Silakan selesaikan pembayaran',
                    isCompleted: _isPaid,
                    isCurrent: !_isPaid,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '5',
                    title: 'Pembayaran Terverifikasi',
                    subtitle: _isPaid ? 'Terverifikasi Otomatis' : 'Menunggu pembayaran',
                    isCompleted: _isPaid,
                    isCurrent: false,
                    showLine: true,
                  ),
                  _buildTimelineItem(step: '6', title: 'Dalam Antrean', subtitle: '22 Oktober 2026 - 17.35', isCompleted: _isPaid, isCurrent: false, showLine: true),
                  _buildTimelineItem(step: '7', title: 'Pencucian', subtitle: '22 Oktober 2026 - 17.35', isCompleted: false, isCurrent: _isPaid, showLine: true),
                  _buildTimelineItem(step: '8', title: 'Pengeringan', subtitle: '22 Oktober 2026 - 17.35', isCompleted: false, isCurrent: false, showLine: true),
                  _buildTimelineItem(step: '9', title: 'Penyetrikaan', subtitle: '22 Oktober 2026 - 17.35', isCompleted: false, isCurrent: false, showLine: true),
                  _buildTimelineItem(step: '10', title: 'Siap Diambil/Dikirim', subtitle: '22 Oktober 2026 - 17.35', isCompleted: false, isCurrent: false, showLine: true),
                  _buildTimelineItem(step: '11', title: 'Selesai', subtitle: '22 Oktober 2026 - 17.35', isCompleted: false, isCurrent: false, showLine: false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Tagihan Cucian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tagihan Cucian',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isPaid ? 'Lunas' : 'Belum Dibayar',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('No. Pesanan $orderId', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const Divider(height: 20),

                  _buildBillRow('Jenis Laundry', serviceName.contains('Kiloan') ? 'Kiloan' : 'Satuan'),
                  _buildBillRow('Kecepatan Layanan', 'Reguler'),
                  _buildBillRow('Pengerjaan', treatment),
                  _buildBillRow('Berat Aktual', weight),
                  const SizedBox(height: 8),

                  const Text(
                    'Rincian Biaya',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                  ),
                  const SizedBox(height: 8),

                  _buildBillRow('Biaya Layanan', totalAmount),
                  _buildBillRow('Tambahan Deterjen', 'Rp 0'),
                  _buildBillRow('Tambahan Pewangi', 'Rp 0'),

                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                      ),
                      Text(
                        totalAmount,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Cek Detail Pembayaran
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF243B55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _openPaymentPage,
                      child: const Text(
                        'Cek Detail Pembayaran',
                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String step,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool showLine,
  }) {
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      iconColor = const Color(0xFF243B55);
    } else if (isCurrent) {
      iconColor = const Color(0xFF6C5CE7);
    } else {
      iconColor = Colors.grey.shade400;
    }

    if (isCompleted || isCurrent) {
      textColor = const Color(0xFF1E3A5F);
    } else {
      textColor = Colors.grey.shade500;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent ? iconColor : Colors.grey.shade200,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                  step,
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrent ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? const Color(0xFF243B55) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}