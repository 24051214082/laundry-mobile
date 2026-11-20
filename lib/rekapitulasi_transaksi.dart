import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_bottom_nav.dart';

class RekapitulasiTransaksiPage extends StatefulWidget {
  const RekapitulasiTransaksiPage({super.key});

  @override
  State<RekapitulasiTransaksiPage> createState() =>
      _RekapitulasiTransaksiPageState();
}

class _RekapitulasiTransaksiPageState extends State<RekapitulasiTransaksiPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List _allPaidOrders = [];
  String _searchQuery = '';

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _startDate = DateTime(now.year, now.month - 5, 1);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _fetchTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> rows = response as List<dynamic>;

      final validOrders = rows.where((raw) {
        final row = raw as Map<String, dynamic>;
        final status = (row['status'] ?? '').toString().toLowerCase();
        final payStatus =
            (row['payment_status'] ?? '').toString().toLowerCase();
        if (status.contains('batal')) return false;
        return payStatus == 'lunas' || status == 'selesai';
      }).map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        final dt = DateTime.tryParse((map['created_at'] ?? '').toString())
            ?.toLocal();
        map['_parsedDate'] = dt;
        map['_numericTotal'] = (map['total_price'] is num)
            ? (map['total_price'] as num).toInt()
            : int.tryParse((map['total_price'] ?? '0').toString()) ?? 0;
        return map;
      }).toList();

      if (!mounted) return;
      setState(() {
        _allPaidOrders = validOrders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            'Gagal memuat rekapitulasi: $e',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
  }

  List get _filteredTransactions {
    return _allPaidOrders.where((order) {
      final DateTime? dt = order['_parsedDate'] as DateTime?;

      if (_startDate != null && dt != null && dt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && dt != null && dt.isAfter(_endDate!)) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final code = (order['order_code'] ?? '').toString().toLowerCase();
        final cust = (order['customer_name'] ?? '').toString().toLowerCase();
        if (!code.contains(_searchQuery) && !cust.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get _totalPendapatan {
    int sum = 0;
    for (final order in _filteredTransactions) {
      sum += (order['_numericTotal'] as int? ?? 0);
    }
    return sum;
  }

  List get _monthlyChartPoints {
    final now = _endDate ?? DateTime.now();
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    final List<DateTime> months = List.generate(6, (i) {
      return DateTime(now.year, now.month - (5 - i), 1);
    });

    final Map<String, int> monthlyTotals = {
      for (final m in months) '${m.year}-${m.month}': 0,
    };

    for (final order in _filteredTransactions) {
      final DateTime? dt = order['_parsedDate'] as DateTime?;
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month}';
      if (monthlyTotals.containsKey(key)) {
        monthlyTotals[key] =
            (monthlyTotals[key] ?? 0) + (order['_numericTotal'] as int? ?? 0);
      }
    }

    return months.map((m) {
      final key = '${m.year}-${m.month}';
      return {
        'label': shortMonths[m.month - 1],
        'value': monthlyTotals[key] ?? 0,
      };
    }).toList();
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate =
              DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final initial = _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        if (_startDate != null && _startDate!.isAfter(_endDate!)) {
          _startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        }
      });
    }
  }

  String _formatShortDate(DateTime? dt) {
    if (dt == null) return 'Semua';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  String _formatRupiah(int amount) {
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

  String _formatCompactK(int amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    if (amount >= 1000) {
      return 'Rp ${(amount / 1000).round()}k';
    }
    return 'Rp $amount';
  }

  void _showTransactionDetail(Map<String, dynamic> order) {
    final code = (order['order_code'] ?? '-').toString();
    final cust = (order['customer_name'] ?? 'Pelanggan').toString();
    final service = (order['service_name'] ?? '-').toString();
    final qty = (order['weight_or_qty'] ?? '-').toString();
    final speed = (order['speed'] ?? '-').toString();
    final treatment = (order['treatment'] ?? '-').toString();
    final pickup = (order['pickup_method'] ?? '-').toString();
    final delivery = (order['delivery_method'] ?? '-').toString();
    final dt = order['_parsedDate'] as DateTime?;
    final total = _formatRupiah(order['_numericTotal'] as int? ?? 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detail Transaksi ($code)',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Pelanggan', cust),
            _detailRow('Tanggal', _formatShortDate(dt)),
            _detailRow('Layanan', '$service ($qty)'),
            _detailRow('Kecepatan', speed),
            _detailRow('Pengerjaan', treatment),
            _detailRow('Metode', '$pickup • $delivery'),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Dibayar',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                ),
                Text(
                  total,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B4E6C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B4E6C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;
    final chartPoints = _monthlyChartPoints;
    final maxChartVal = chartPoints.isEmpty
        ? 100000
        : chartPoints
            .map((e) => e['value'] as int)
            .reduce((a, b) => a > b ? a : b);
    final safeMax = maxChartVal <= 0 ? 100000 : maxChartVal;

    return Scaffold(
      backgroundColor: const Color(0xFFD8F1FD),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTransactions,
          color: const Color(0xFF1B4E6C),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Pencarian dengan Tombol Kembali
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD8F1FD),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/admin-home');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Color(0xFF1B4E6C),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rekapitulasi Transaksi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1B4E6C),
                                    ),
                                  ),
                                  Text(
                                    'Admin Laundry',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF326D8C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _fetchTransactions,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.refresh_rounded,
                                    color: Color(0xFF1B4E6C),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(
                                    context, '/admin-profile'),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Kolom Pencarian
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF1B4E6C).withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF1B4E6C),
                          ),
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search,
                                color: Color(0xFF94A3B8), size: 20),
                            hintText: 'Cari ID Pesanan atau Nama Customer',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Periode Transaksi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4E6C).withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 18, color: Color(0xFF1B4E6C)),
                                const SizedBox(width: 8),
                                Text(
                                  'PERIODE TRANSAKSI',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B4E6C),
                                  ),
                                ),
                              ],
                            ),
                            if (_startDate != null || _endDate != null)
                              GestureDetector(
                                onTap: () => setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                }),
                                child: Text(
                                  'Reset',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF338CA8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pilih rentang tanggal transaksi',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dari Tanggal',
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: const Color(0xFF64748B))),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: _pickStartDate,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatShortDate(_startDate),
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: _startDate != null
                                                  ? const Color(0xFF1B4E6C)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const Icon(
                                              Icons.calendar_month_outlined,
                                              size: 16,
                                              color: Color(0xFF338CA8)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sampai Tanggal',
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: const Color(0xFF64748B))),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: _pickEndDate,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatShortDate(_endDate),
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: _endDate != null
                                                  ? const Color(0xFF1B4E6C)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const Icon(
                                              Icons.calendar_month_outlined,
                                              size: 16,
                                              color: Color(0xFF338CA8)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Card Ringkasan (Total Pendapatan & Jumlah Transaksi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF93C5FD).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Pendapatan',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1B4E6C))),
                                  const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 18,
                                      color: Color(0xFF1B4E6C)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isLoading
                                    ? 'Memuat...'
                                    : _formatRupiah(_totalPendapatan),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B4E6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF93C5FD).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Jumlah Transaksi',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1B4E6C))),
                                  const Icon(Icons.receipt_long_outlined,
                                      size: 18, color: Color(0xFF1B4E6C)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isLoading
                                    ? '...'
                                    : '${transactions.length} order',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B4E6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Grafik Pendapatan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4E6C).withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GRAFIK PENDAPATAN',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B4E6C))),
                            Text('Bulanan',
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 130,
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _formatCompactK(safeMax),
                                  _formatCompactK((safeMax * 0.75).round()),
                                  _formatCompactK((safeMax * 0.5).round()),
                                  _formatCompactK((safeMax * 0.25).round()),
                                  'Rp 0',
                                ]
                                    .map((val) => Row(
                                          children: [
                                            SizedBox(
                                              width: 44,
                                              child: Text(val,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 8,
                                                      color: const Color(
                                                          0xFF94A3B8))),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                                child: Container(
                                                    height: 1,
                                                    color: const Color(
                                                        0xFFF1F5F9))),
                                          ],
                                        ))
                                    .toList(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 52, right: 8, top: 6, bottom: 6),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 118),
                                  painter: _RevenueChartPainter(
                                    values: chartPoints
                                        .map((e) => (e['value'] as int)
                                            .toDouble())
                                        .toList(),
                                    maxValue: safeMax.toDouble(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: chartPoints
                                .map((pt) => Text(
                                      pt['label'].toString(),
                                      style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: const Color(0xFF64748B)),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Daftar Transaksi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('DAFTAR TRANSAKSI',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B4E6C))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${transactions.length} Transaksi',
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF64748B))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF1B4E6C)),
                          ),
                        )
                      else if (transactions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Tidak ada transaksi yang sesuai',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        )
                      else
                        ...transactions.map((order) {
                          final dt = order['_parsedDate'] as DateTime?;
                          final total =
                              _formatRupiah(order['_numericTotal'] as int? ?? 0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildTransactionItem(
                              orderId:
                                  (order['order_code'] ?? '-').toString(),
                              name: (order['customer_name'] ?? 'Pelanggan')
                                  .toString(),
                              date: _formatShortDate(dt),
                              price: total,
                              onTap: () => _showTransactionDetail(order),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

  Widget _buildTransactionItem({
    required String orderId,
    required String name,
    required String date,
    required String price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4E6C).withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_outlined,
                  color: Color(0xFF0284C7), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(orderId,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Lunas',
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: const Color(0xFF475569)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: const Color(0xFF94A3B8))),
                      const SizedBox(width: 6),
                      Text(date,
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4E6C))),
                const SizedBox(height: 2),
                Text(
                  'Detail >',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;

  _RevenueChartPainter({
    required this.values,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotFill = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;

    final dotBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = <Offset>[];
    if (values.length == 1) {
      final y = size.height - (values[0] / maxValue) * size.height;
      points.add(Offset(size.width / 2, y));
    } else {
      final dx = size.width / (values.length - 1);
      for (int i = 0; i < values.length; i++) {
        final x = dx * i;
        final y = size.height - (values[i] / maxValue) * size.height;
        points.add(Offset(x, y));
      }
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF38BDF8).withOpacity(0.32),
            const Color(0xFF38BDF8).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);
    }

    for (final pt in points) {
      canvas.drawCircle(pt, 4.5, dotFill);
      canvas.drawCircle(pt, 4.5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.maxValue != maxValue;
  }
}