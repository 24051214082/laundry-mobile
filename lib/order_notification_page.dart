import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_session.dart';

class OrderNotificationPage extends StatefulWidget {
  const OrderNotificationPage({super.key});

  @override
  State createState() => _OrderNotificationPageState();
}

class _OrderNotificationPageState extends State {
  bool _isLoading = true;
  List _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future _fetchNotifications() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final notifRes = await client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      final List list = List.from(notifRes);

      if (list.isEmpty) {
        final orderRes = await client
            .from('orders')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false);

        for (final order in orderRes) {
          final status = (order['status'] ?? 'Waiting').toString();
          final code = (order['order_code'] ?? '').toString();
          final service = (order['service_name'] ?? 'Laundry').toString();
          list.add({
            'id': null,
            'order_code': code,
            'title': status,
            'message': 'Status pesanan $code ($service) saat ini: $status',
            'is_read': true,
            'created_at': order['created_at'],
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future _markAsRead(Map item) async {
    final id = item['id'];
    if (id == null || item['is_read'] == true) return;

    setState(() {
      item['is_read'] = true;
    });

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true}).eq('id', id);
    } catch (_) {}
  }

  Future _markAllAsRead() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) return;

    setState(() {
      for (final item in _notifications) {
        item['is_read'] = true;
      }
    });

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
    } catch (_) {}
  }

  Map _mapStatusStyle(String rawTitle) {
    final lower = rawTitle.toLowerCase();

    if (lower.contains('jemput')) {
      return {
        'icon': Icons.electric_scooter_rounded,
        'badge': rawTitle,
        'headline': 'Permintaan penjemputan diproses',
        'badgeBg': const Color(0xFFE0F2FE),
        'badgeText': const Color(0xFF0369A1),
      };
    } else if (lower.contains('konfirmasi harga')) {
      return {
        'icon': Icons.scale_rounded,
        'badge': 'Konfirmasi Harga',
        'headline': 'Timbangan selesai, mohon konfirmasi harga',
        'badgeBg': const Color(0xFFFEF3C7),
        'badgeText': const Color(0xFFB45309),
      };
    } else if (lower.contains('menunggu pembayaran')) {
      return {
        'icon': Icons.receipt_long_rounded,
        'badge': 'Menunggu Pembayaran',
        'headline': 'Tagihan pesanan Anda telah tersedia',
        'badgeBg': const Color(0xFFFEF3C7),
        'badgeText': const Color(0xFFB45309),
      };
    } else if (lower.contains('waiting') || lower.contains('antrean')) {
      return {
        'icon': Icons.timer_outlined,
        'badge': 'Dalam Antrean',
        'headline': 'Cucian Anda sedang menunggu giliran diproses',
        'badgeBg': const Color(0xFFE2E8F0),
        'badgeText': const Color(0xFF334155),
      };
    } else if (lower.contains('cuci')) {
      return {
        'icon': Icons.local_laundry_service_rounded,
        'badge': 'Pencucian',
        'headline': 'Cucian Anda sedang dalam proses pencucian',
        'badgeBg': const Color(0xFFDDD6FE),
        'badgeText': const Color(0xFF5B21B6),
      };
    } else if (lower.contains('kering')) {
      return {
        'icon': Icons.local_laundry_service_outlined,
        'badge': 'Pengeringan',
        'headline': 'Cucian Anda sedang dalam proses pengeringan',
        'badgeBg': const Color(0xFFE0F2FE),
        'badgeText': const Color(0xFF0369A1),
      };
    } else if (lower.contains('setrika') || lower.contains('proses')) {
      return {
        'icon': Icons.iron_rounded,
        'badge': rawTitle,
        'headline': 'Cucian Anda sedang diproses oleh tim kami',
        'badgeBg': const Color(0xFFDDD6FE),
        'badgeText': const Color(0xFF5B21B6),
      };
    } else if (lower.contains('serah') || lower.contains('antar')) {
      return {
        'icon': Icons.electric_scooter_rounded,
        'badge': 'Penyerahan Pesanan',
        'headline': 'Cucian Anda siap diserahkan / diantar',
        'badgeBg': const Color(0xFFDDD6FE),
        'badgeText': const Color(0xFF5B21B6),
      };
    } else if (lower.contains('selesai')) {
      return {
        'icon': Icons.check_circle_outline_rounded,
        'badge': 'Selesai',
        'headline': 'Pesanan laundry Anda telah selesai',
        'badgeBg': const Color(0xFFDCFCE7),
        'badgeText': const Color(0xFF15803D),
      };
    } else if (lower.contains('batal')) {
      return {
        'icon': Icons.cancel_outlined,
        'badge': 'Dibatalkan',
        'headline': 'Pesanan laundry dibatalkan',
        'badgeBg': const Color(0xFFFEE2E2),
        'badgeText': const Color(0xFFB91C1C),
      };
    }

    return {
      'icon': Icons.notifications_active_outlined,
      'badge': rawTitle.isEmpty ? 'Info Pesanan' : rawTitle,
      'headline': 'Pembaruan status pesanan Anda',
      'badgeBg': const Color(0xFFDDD6FE),
      'badgeText': const Color(0xFF5B21B6),
    };
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
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');

    if (dateOnly == today) {
      return '$hh.$mm WIB';
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

    for (final item in _notifications) {
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

    final hasUnread = _notifications.any((n) => n['is_read'] == false);

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
              'Notifikasi Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
            Text(
              'Pembaruan Status Pesanan Anda Dapat Dilihat Di Sini',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF2E637E),
              ),
            ),
          ],
        ),
        actions: [
          if (hasUnread)
            IconButton(
              tooltip: 'Tandai semua dibaca',
              icon: const Icon(Icons.done_all_rounded, color: Color(0xFF1B4E6C)),
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_outlined,
                                size: 64, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada notifikasi pesanan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B4E6C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status pesananmu akan muncul otomatis di sini',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
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
                          ...todayList.map((item) => _buildItemWidget(item)),
                          const SizedBox(height: 14),
                        ],
                        if (yesterdayList.isNotEmpty) ...[
                          _buildGroupTitle('Yesterday'),
                          const SizedBox(height: 10),
                          ...yesterdayList
                              .map((item) => _buildItemWidget(item)),
                          const SizedBox(height: 14),
                        ],
                        if (earlierList.isNotEmpty) ...[
                          _buildGroupTitle('Sebelumnya'),
                          const SizedBox(height: 10),
                          ...earlierList.map((item) => _buildItemWidget(item)),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildItemWidget(Map item) {
    final rawTitle = (item['title'] ?? '').toString();
    final message = (item['message'] ?? '').toString();
    final orderCode = (item['order_code'] ?? '').toString();
    final isUnread = item['is_read'] == false;
    final dt = _parseLocalTime(item['created_at']);
    final style = _mapStatusStyle(rawTitle);

    final headline = orderCode.isNotEmpty
        ? '${style['headline']} ($orderCode)'
        : style['headline'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _markAsRead(item),
        child: _buildNotificationCard(
          icon: style['icon'] as IconData,
          badgeText: style['badge'] as String,
          badgeColor: style['badgeBg'] as Color,
          badgeTextColor: style['badgeText'] as Color,
          title: headline,
          subtitle: message.isNotEmpty
              ? message
              : 'Ketuk untuk melihat detail status pesanan Anda',
          dateText: _formatDateLabel(dt),
          hasDot: isUnread,
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