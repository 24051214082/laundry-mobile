import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State {
  bool _isLoading = true;
  List _adminNotifs = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminNotifications();
  }

  Future _fetchAdminNotifications() async {
    setState(() => _isLoading = true);

    try {
      final ordersRes = await Supabase.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false)
          .limit(30);

      final List items = [];

      for (final order in ordersRes) {
        final code = (order['order_code'] ?? '-').toString();
        final custName = (order['customer_name'] ?? 'Pelanggan').toString();
        final service = (order['service_name'] ?? 'Layanan Laundry').toString();
        final status = (order['status'] ?? 'Waiting').toString();
        final paymentStatus =
            (order['payment_status'] ?? 'Belum Lunas').toString();
        final paymentMethod = (order['payment_method'] ?? '').toString();
        final createdAt = order['created_at'];

        final lowerStatus = status.toLowerCase();
        final isNewOrPending = lowerStatus == 'waiting' ||
            lowerStatus.contains('jemput') ||
            lowerStatus.contains('konfirmasi');

        IconData icon;
        String badgeText;
        Color badgeBg;
        Color badgeTextColor;
        String title;
        String subtitle;
        bool hasDot = false;

        if (lowerStatus == 'selesai') {
          icon = Icons.check_circle_outline_rounded;
          badgeText = 'Pesanan Selesai';
          badgeBg = const Color(0xFFDCFCE7);
          badgeTextColor = const Color(0xFF15803D);
          title = 'Pesanan $code ($custName) telah selesai';
          subtitle = 'Layanan $service selesai diproses ($paymentStatus).';
        } else if (lowerStatus == 'dibatalkan') {
          icon = Icons.cancel_outlined;
          badgeText = 'Pesanan Dibatalkan';
          badgeBg = const Color(0xFFFEE2E2);
          badgeTextColor = const Color(0xFFB91C1C);
          title = 'Pesanan $code dari $custName dibatalkan';
          subtitle = 'Layanan $service dibatalkan.';
        } else if (paymentStatus.toLowerCase() == 'lunas' && isNewOrPending) {
          icon = Icons.payments_outlined;
          badgeText = 'Pembayaran Lunas';
          badgeBg = const Color(0xFFDDD6FE);
          badgeTextColor = const Color(0xFF5B21B6);
          title = 'Pembayaran masuk dari $custName ($code)';
          subtitle =
              'Layanan $service telah dibayar${paymentMethod.isNotEmpty ? ' via $paymentMethod' : ''}. Siap diproses.';
          hasDot = true;
        } else if (isNewOrPending) {
          icon = Icons.shopping_bag_outlined;
          badgeText = 'Pesanan Baru';
          badgeBg = const Color(0xFFDDD6FE);
          badgeTextColor = const Color(0xFF5B21B6);
          title = 'Pesanan baru masuk dari $custName ($code)';
          subtitle =
              'Layanan $service ($status • $paymentStatus) membutuhkan tindak lanjut admin.';
          hasDot = true;
        } else {
          icon = Icons.local_laundry_service_rounded;
          badgeText = status;
          badgeBg = const Color(0xFFE0F2FE);
          badgeTextColor = const Color(0xFF0369A1);
          title = 'Pesanan $code ($custName) tahap $status';
          subtitle =
              'Layanan $service sedang dalam tahap $status ($paymentStatus).';
        }

        items.add({
          'icon': icon,
          'badgeText': badgeText,
          'badgeBg': badgeBg,
          'badgeTextColor': badgeTextColor,
          'title': title,
          'subtitle': subtitle,
          'created_at': createdAt,
          'hasDot': hasDot,
        });
      }

      if (!mounted) return;
      setState(() {
        _adminNotifs = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  DateTime? _parseLocalTime(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDateLabel(DateTime? dt) {
    if (dt == null) return '-';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dt.year, dt.month, dt.day);

    if (dateOnly == today) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh.$mm WIB';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    }
    final dd = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$dd/$mo/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final List todayList = [];
    final List yesterdayList = [];
    final List earlierList = [];

    for (final item in _adminNotifs) {
      final dt = _parseLocalTime(item['created_at']);
      if (dt == null) {
        earlierList.add(item);
      } else {
        final d = DateTime(dt.year, dt.month, dt.day);
        if (d == todayStart) {
          todayList.add(item);
        } else if (d == yesterdayStart) {
          yesterdayList.add(item);
        } else {
          earlierList.add(item);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6EFFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4E6C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi Admin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            Text(
              'Pembaruan aktivitas & pesanan masuk dapat dilihat di sini',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF2E637E),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAdminNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _adminNotifs.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_none_rounded,
                                size: 64, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada aktivitas pesanan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B4E6C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todayList.isNotEmpty) ...[
                          _buildGroupTitle('Today'),
                          const SizedBox(height: 10),
                          ...todayList
                              .map((item) => _buildCardItem(context, item)),
                          const SizedBox(height: 14),
                        ],
                        if (yesterdayList.isNotEmpty) ...[
                          _buildGroupTitle('Yesterday'),
                          const SizedBox(height: 10),
                          ...yesterdayList
                              .map((item) => _buildCardItem(context, item)),
                          const SizedBox(height: 14),
                        ],
                        if (earlierList.isNotEmpty) ...[
                          _buildGroupTitle('Sebelumnya'),
                          const SizedBox(height: 10),
                          ...earlierList
                              .map((item) => _buildCardItem(context, item)),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, Map item) {
    final dt = _parseLocalTime(item['created_at']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/manage-orders'),
        child: _buildNotificationCard(
          icon: item['icon'] as IconData,
          badgeText: item['badgeText'] as String,
          badgeColor: item['badgeBg'] as Color,
          badgeTextColor: item['badgeTextColor'] as Color,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          dateText: _formatDateLabel(dt),
          hasDot: item['hasDot'] as bool,
        ),
      ),
    );
  }

  Widget _buildGroupTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String title,
    required String subtitle,
    required String dateText,
    required bool hasDot,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasDot ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDot ? const Color(0xFF93C5FD) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        Text(
                          dateText,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        if (hasDot) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
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