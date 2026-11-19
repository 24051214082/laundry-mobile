import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_bottom_nav.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const teal = Color(0xFF338CA8);
}

class AdminChatListPage extends StatefulWidget {
  const AdminChatListPage({super.key});

  @override
  State<AdminChatListPage> createState() => _AdminChatListPageState();
}

class _AdminChatListPageState extends State<AdminChatListPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  var _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminChats();
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

  Future<void> _loadAdminChats() async {
    setState(() => _isLoading = true);
    try {
      final orderInfoByCode = {};
      try {
        final ordersRes = await _supabase
            .from('orders')
            .select('order_code, service_name, speed, status, customer_name');

        for (final row in (ordersRes as List)) {
          final map = Map<String, dynamic>.from(row as Map);
          final code = (map['order_code'] ?? '').toString().trim();
          if (code.isEmpty) continue;
          final svc = (map['service_name'] ?? 'Laundry').toString();
          final spd = (map['speed'] ?? '').toString();
          orderInfoByCode[code] = {
            'customerName': (map['customer_name'] ?? '').toString().trim(),
            'serviceName': spd.isNotEmpty ? '$svc - $spd' : svc,
            'status': (map['status'] ?? 'Diproses').toString(),
          };
        }
      } catch (_) {}

      final msgRes = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: false);

      final grouped = {};
      for (final row in (msgRes as List)) {
        final map = Map<String, dynamic>.from(row as Map);
        final code = (map['order_code'] ?? '').toString().trim();
        if (code.isEmpty) continue;
        if (!grouped.containsKey(code)) {
          grouped[code] = [];
        }
        (grouped[code] as List).add(map);
      }

      final threads = [];
      for (final entry in grouped.entries) {
        final code = entry.key.toString();
        final msgs = (entry.value as List);
        if (msgs.isEmpty) continue;

        final latest = Map<String, dynamic>.from(msgs.first as Map);
        String customerName = '';

        for (final item in msgs) {
          final m = Map<String, dynamic>.from(item as Map);
          if (m['sender_role']?.toString() == 'customer') {
            final sName = (m['sender_name'] ?? '').toString().trim();
            if (sName.isNotEmpty) {
              customerName = sName;
              break;
            }
          }
        }

        final orderMeta = orderInfoByCode[code] is Map
            ? Map<String, dynamic>.from(orderInfoByCode[code] as Map)
            : {};

        if (customerName.isEmpty) {
          customerName = (orderMeta['customerName'] ?? '').toString().trim();
        }
        if (customerName.isEmpty) {
          customerName = 'Pelanggan';
        }

        int unreadCount = 0;
        for (final item in msgs) {
          final m = Map<String, dynamic>.from(item as Map);
          if (m['sender_role']?.toString() == 'customer' &&
              m['is_read'] == false) {
            unreadCount++;
          }
        }

        threads.add({
          'customerName': customerName,
          'orderId': code,
          'serviceName':
          (orderMeta['serviceName'] ?? 'Laundry Kiloan').toString(),
          'status': (orderMeta['status'] ?? 'Diproses').toString(),
          'lastMessage': (latest['message_text'] ?? '').toString(),
          'time': _formatTime(latest['created_at']),
          'unreadCount': unreadCount,
        });
      }

      if (!mounted) return;
      setState(() {
        _chatList = threads;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal memuat pesan pelanggan: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter pencarian nama pelanggan atau ID pesanan
    final filteredChats = _chatList.where((item) {
      final chat = Map<String, dynamic>.from(item as Map);
      final name = (chat['customerName'] ?? '').toString().toLowerCase();
      final orderId = (chat['orderId'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || orderId.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header & Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: _C.headerBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesan Pelanggan',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _C.navy,
                    ),
                  ),
                  Text(
                    'Kelola percakapan dan pertanyaan pesanan customer',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF2E637E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.poppins(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'Cari nama pelanggan atau ID pesanan...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _C.navy,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daftar Kartu Percakapan
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: _C.teal),
            )
                : RefreshIndicator(
              onRefresh: _loadAdminChats,
              color: _C.teal,
              child: filteredChats.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height:
                    MediaQuery.of(context).size.height * 0.35,
                    child: Center(
                      child: Text(
                        'Belum ada pesan pelanggan',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: filteredChats.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final chat = Map<String, dynamic>.from(
                    filteredChats[index] as Map,
                  );
                  final int unread =
                      (chat['unreadCount'] as int?) ?? 0;

                  return InkWell(
                    onTap: () async {
                      // Lempar data pelanggan & pesanan ke AdminChatRoomPage
                      await Navigator.pushNamed(
                        context,
                        '/admin-chat-room',
                        arguments: {
                          'customerName': chat['customerName'],
                          'orderId': chat['orderId'],
                          'serviceName': chat['serviceName'],
                          'status': chat['status'],
                        },
                      );
                      if (mounted) {
                        _loadAdminChats();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: unread > 0
                              ? const Color(0xFFBAE6FD)
                              : const Color(0xFFF1F5F9),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar Pelanggan
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFF4285F4),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info Nama, Badge Order, dan Cuplikan Pesan
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      chat['customerName']
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _C.navy,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _C.headerBlue,
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        chat['orderId'].toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: _C.navy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chat['lastMessage'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: unread > 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: unread > 0
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Waktu & Badge Belum Dibaca
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              Text(
                                chat['time'].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: unread > 0
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: unread > 0
                                      ? _C.teal
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (unread > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: _C.teal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unread.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 18),
                            ],
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
      // Tetap menampilkan Bottom Nav Admin dengan tab Chat aktif (index: 1)
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}