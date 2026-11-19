import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_bottom_nav.dart';
import 'user_session.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const textSub = Color(0xFF64748B);
  static const primaryBlue = Color(0xFF338CA8);
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _supabase = Supabase.instance.client;
  var _chatThreads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatThreads();
  }

  String _formatTime(dynamic rawCreatedAt) {
    if (rawCreatedAt == null) return '';
    final dt = DateTime.tryParse(rawCreatedAt.toString())?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final isSameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isSameDay) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadChatThreads() async {
    setState(() => _isLoading = true);
    try {
      final orderMeta = {};

      if (UserSession.userId != null && UserSession.userId!.isNotEmpty) {
        final ordersRes = await _supabase
            .from('orders')
            .select('order_code, service_name, speed, status')
            .eq('user_id', UserSession.userId!)
            .order('created_at', ascending: false);

        for (final row in (ordersRes as List)) {
          final map = Map<String, dynamic>.from(row as Map);
          final code = (map['order_code'] ?? '').toString().trim();
          if (code.isEmpty) continue;
          final svc = (map['service_name'] ?? 'Laundry').toString();
          final spd = (map['speed'] ?? '').toString();
          orderMeta[code] = {
            'orderId': code,
            'serviceName': spd.isNotEmpty ? '$svc - $spd' : svc,
            'status': (map['status'] ?? 'Diproses').toString(),
          };
        }
      }

      final msgRes = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: false);

      final groupedMessages = {};
      for (final row in (msgRes as List)) {
        final map = Map<String, dynamic>.from(row as Map);
        final code = (map['order_code'] ?? '').toString().trim();
        if (code.isEmpty) continue;
        if (orderMeta.isNotEmpty && !orderMeta.containsKey(code)) {
          continue;
        }
        if (!groupedMessages.containsKey(code)) {
          groupedMessages[code] = [];
        }
        (groupedMessages[code] as List).add(map);
      }

      final allCodes = <String>{
        ...groupedMessages.keys.map((k) => k.toString()),
        ...orderMeta.keys.map((k) => k.toString()),
      };

      final threads = [];
      for (final code in allCodes) {
        final meta = orderMeta[code] is Map
            ? Map<String, dynamic>.from(orderMeta[code] as Map)
            : {
          'orderId': code,
          'serviceName': 'Layanan Laundry',
          'status': 'Diproses',
        };

        final msgs =
        groupedMessages[code] is List ? (groupedMessages[code] as List) : [];

        final latest = msgs.isNotEmpty
            ? Map<String, dynamic>.from(msgs.first as Map)
            : null;

        int unreadCount = 0;
        for (final item in msgs) {
          final m = Map<String, dynamic>.from(item as Map);
          if (m['sender_role']?.toString() == 'admin' &&
              m['is_read'] == false) {
            unreadCount++;
          }
        }

        threads.add({
          'orderId': code,
          'serviceName': (meta['serviceName'] ?? 'Layanan Laundry').toString(),
          'status': (meta['status'] ?? 'Diproses').toString(),
          'lastMessage': latest != null
              ? (latest['message_text'] ?? '').toString()
              : 'Ketuk untuk mulai chat dengan admin',
          'time': latest != null ? _formatTime(latest['created_at']) : '',
          'unread': unreadCount,
        });
      }

      if (!mounted) return;
      setState(() {
        _chatThreads = threads;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal memuat percakapan: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.headerBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Pesan & Bantuan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _C.navy,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Percakapan Pesanan',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.navy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_chatThreads.length} Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: _C.primaryBlue),
              )
                  : RefreshIndicator(
                onRefresh: _loadChatThreads,
                color: _C.primaryBlue,
                child: _chatThreads.isEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height:
                      MediaQuery.of(context).size.height * 0.4,
                      child: Center(
                        child: Text(
                          'Belum ada percakapan pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: _C.textSub,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: _chatThreads.length,
                  separatorBuilder: (context, index) =>
                  const Divider(
                    height: 16,
                    color: Color(0xFFF1F5F9),
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final thread = Map<String, dynamic>.from(
                      _chatThreads[index] as Map,
                    );
                    final int unreadCount =
                        (thread['unread'] as int?) ?? 0;
                    final String orderId =
                    (thread['orderId'] ?? '').toString();
                    final String serviceName =
                    (thread['serviceName'] ?? '').toString();
                    final String lastMessage =
                    (thread['lastMessage'] ?? '').toString();
                    final String time =
                    (thread['time'] ?? '').toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          '/chat-room',
                          arguments: thread,
                        );
                        if (mounted) {
                          _loadChatThreads();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Avatar Icon Laundry
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius:
                                    BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .local_laundry_service_rounded,
                                    color: Color(0xFF0284C7),
                                    size: 26,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color:
                                        const Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),

                            // Rincian Chat
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        orderId,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight:
                                          FontWeight.w700,
                                          color: _C.navy,
                                        ),
                                      ),
                                      Text(
                                        time,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          color: _C.textSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    serviceName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _C.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: unreadCount > 0
                                          ? const Color(0xFF1E293B)
                                          : _C.textSub,
                                      fontWeight: unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}