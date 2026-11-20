import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatusPesananPage extends StatefulWidget {
  const StatusPesananPage({super.key});

  @override
  State<StatusPesananPage> createState() => _StatusPesananPageState();
}

class _StatusPesananPageState extends State<StatusPesananPage> {
  bool _isPaid = false;
  bool _isInit = false;

  late Map<String, dynamic> _orderData;

  Future<void> _fetchLatestOrder() async {
    final String? dbId = _orderData['dbId']?.toString();
    final String? orderCode = _orderData['orderId']?.toString();
    if ((dbId == null || dbId.isEmpty) &&
        (orderCode == null || orderCode.isEmpty)) return;

    try {
      var query = Supabase.instance.client.from('orders').select();
      query = (dbId != null && dbId.isNotEmpty)
          ? query.eq('id', dbId)
          : query.eq('order_code', orderCode!);

      final row = await query.maybeSingle();
      if (row == null || !mounted) return;

      setState(() {
        _orderData['dbId'] = row['id'].toString();
        _orderData['orderId'] = (row['order_code'] ?? '-').toString();
        _orderData['serviceName'] = (row['service_name'] ?? '-').toString();
        _orderData['weight'] = (row['weight_or_qty'] ?? '-').toString();
        _orderData['treatment'] = (row['treatment'] ?? '-').toString();
        _orderData['speed'] = (row['speed'] ?? '-').toString();
        _orderData['totalPrice'] = 'Rp ${row['total_price'] ?? 0}';
        _orderData['status'] = (row['status'] ?? '-').toString();
        _orderData['estimate'] = (row['pickup_schedule'] ?? '-').toString();
        _orderData['pickupMethod'] =
            (row['pickup_method'] ?? 'Penjemputan').toString();
        _orderData['deliveryMethod'] =
            (row['delivery_method'] ?? 'Diantar Kurir').toString();
        _isPaid = (row['payment_status']?.toString().toLowerCase() == 'lunas');
        _orderData['isPaid'] = _isPaid;
      });
    } catch (_) {}
  }

  int _getCurrentStepIndex(String status) {
    switch (status) {
      case 'Pesanan Masuk':
      case 'Penjemputan':
        return 2;
      case 'Konfirmasi Harga':
        return 3;
      case 'Menunggu Pembayaran':
        return 4;
      case 'Waiting':
        return 6;
      case 'Pencucian':
        return 7;
      case 'Pengeringan':
        return 8;
      case 'Penyetrikaan':
        return 9;
      case 'Pengantaran':
      case 'Menunggu Pengambilan':
        return 10;
      case 'Selesai':
        return 11;
      default:
        return 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _orderData = Map<String, dynamic>.from(args);
      } else {
        _orderData = {};
      }

      _isPaid = _orderData['isPaid'] ?? false;
      _fetchLatestOrder();
      _isInit = true;
    }
  }

  Future<void> _openPaymentPage() async {
    final String orderId = _orderData['orderId'] ?? '-';
    final String serviceName = _orderData['serviceName'] ?? '-';
    final String weight = _orderData['weight'] ?? '-';
    final String totalAmount = _orderData['totalPrice'] ?? 'Rp 0';

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

    if (result is bool && result == true) {
      if (_orderData['dbId'] != null) {
        await Supabase.instance.client
            .from('orders')
            .update({'payment_status': 'Lunas'}).eq('id', _orderData['dbId']);
      }
      setState(() {
        _isPaid = true;
        _orderData['isPaid'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String orderId = _orderData['orderId'] ?? '-';
    final String serviceName = _orderData['serviceName'] ?? '-';
    final String weight = _orderData['weight'] ?? '-';
    final String treatment = _orderData['treatment'] ?? '-';
    final String totalAmount = _orderData['totalPrice'] ?? 'Rp 0';
    final String status = _orderData['status'] ?? '-';
    final String speed = _orderData['speed'] ?? '-';

    final String pickupMethod =
        (_orderData['pickupMethod'] ?? 'Penjemputan').toString();
    final String deliveryMethod =
        (_orderData['deliveryMethod'] ?? 'Diantar Kurir').toString();

    final bool isAntarSendiri =
        pickupMethod.toLowerCase().contains('antar sendiri');
    final bool isDiantarKurir =
        deliveryMethod.toLowerCase().contains('diantar kurir');

    final int currentStep = _getCurrentStepIndex(status);
    final bool isPriceConfirmed =
        currentStep >= 4 && !status.toLowerCase().contains('batal');

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
                    Text(
                      _orderData['estimate'] ?? '-',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  _buildTimelineItem(
                    step: '1',
                    title: 'Konfirmasi Pesanan',
                    subtitle: 'Pesanan diterima sistem',
                    isCompleted: currentStep > 1 || status == 'Selesai',
                    isCurrent: currentStep == 1,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '2',
                    title: 'Penyerahan Cucian ke Outlet',
                    subtitle: isAntarSendiri
                        ? 'Silakan antar cucian ke outlet'
                        : 'Kurir menuju lokasi penjemputan',
                    isCompleted: currentStep > 2 || status == 'Selesai',
                    isCurrent: currentStep == 2,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '3',
                    title: 'Cucian Diterima & Ditimbang',
                    subtitle: 'Pengecekan berat/jumlah & harga final',
                    isCompleted: currentStep > 3 || status == 'Selesai',
                    isCurrent: currentStep == 3,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '4',
                    title: 'Menunggu Pembayaran',
                    subtitle: _isPaid || currentStep > 4
                        ? 'Pembayaran Selesai'
                        : 'Silakan selesaikan pembayaran',
                    isCompleted: _isPaid || currentStep > 4 || status == 'Selesai',
                    isCurrent: currentStep == 4 && !_isPaid,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '5',
                    title: 'Pembayaran Terverifikasi',
                    subtitle: _isPaid || currentStep > 5
                        ? 'Terverifikasi'
                        : 'Menunggu pembayaran',
                    isCompleted: _isPaid || currentStep > 5 || status == 'Selesai',
                    isCurrent: currentStep == 5,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '6',
                    title: 'Dalam Antrean',
                    subtitle: 'Menunggu giliran mesin cuci',
                    isCompleted: currentStep > 6 || status == 'Selesai',
                    isCurrent: currentStep == 6,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '7',
                    title: 'Pencucian',
                    subtitle: 'Proses pencucian pakaian',
                    isCompleted: currentStep > 7 || status == 'Selesai',
                    isCurrent: currentStep == 7,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '8',
                    title: 'Pengeringan',
                    subtitle: 'Proses pengeringan pakaian',
                    isCompleted: currentStep > 8 || status == 'Selesai',
                    isCurrent: currentStep == 8,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '9',
                    title: 'Penyetrikaan',
                    subtitle: 'Proses setrika & lipat rapi',
                    isCompleted: currentStep > 9 || status == 'Selesai',
                    isCurrent: currentStep == 9,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '10',
                    title: 'Siap Diambil / Dikirim',
                    subtitle: isDiantarKurir
                        ? 'Pesanan sedang diantar kurir ke alamatmu'
                        : 'Pesanan siap diambil di outlet',
                    isCompleted: currentStep > 10 || status == 'Selesai',
                    isCurrent: currentStep == 10,
                    showLine: true,
                  ),
                  _buildTimelineItem(
                    step: '11',
                    title: 'Selesai',
                    subtitle: 'Pesanan telah diterima pelanggan',
                    isCompleted: status == 'Selesai',
                    isCurrent: false,
                    showLine: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Tagihan & Pembayaran hanya muncul setelah harga dikonfirmasi admin
            if (!isPriceConfirmed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.hourglass_top_rounded,
                        color: Color(0xFFB45309), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Menunggu Konfirmasi Tagihan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rincian biaya dan tombol pembayaran akan muncul otomatis setelah cucian ditimbang dan harga dikonfirmasi oleh admin.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF78350F),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isPaid
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isPaid ? 'Lunas' : 'Belum Dibayar',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _isPaid
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('No. Pesanan $orderId',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                    const Divider(height: 20),
                    _buildBillRow(
                        'Jenis Laundry',
                        serviceName == '-'
                            ? '-'
                            : (serviceName.contains('Kiloan')
                                ? 'Kiloan'
                                : 'Satuan')),
                    _buildBillRow('Kecepatan Layanan', speed),
                    _buildBillRow('Pengerjaan', treatment),
                    _buildBillRow('Berat Aktual', weight),
                    const SizedBox(height: 8),
                    const Text(
                      'Rincian Biaya',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F)),
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
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F)),
                        ),
                        Text(
                          totalAmount,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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
                color:
                    isCompleted || isCurrent ? iconColor : Colors.grey.shade200,
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
                color:
                    isCompleted ? const Color(0xFF243B55) : Colors.grey.shade300,
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
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}