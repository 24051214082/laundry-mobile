import 'dart:async';
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
  State createState() => _AdminChatListPageState();
}

class _AdminChatListPageState extends State {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  Timer? _refreshTimer;
  String _searchQuery = '';
  var _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminChats(showLoader: true);
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _loadAdminChats(showLoader: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
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

  bool _isGenericName(String name) {
    final lower = name.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'customer' ||
        lower == 'pelanggan' ||
        lower == 'user';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Future _loadAdminChats({bool showLoader = false}) async {
    if (showLoader && mounted) setState(() => _isLoading = true);
    try {
      final userNameById = {};
      try {
        final usersRes = await _supabase
            .from('users')
            .select('id, name, full_name, username, email');
        for (final row in usersRes) {
          final u = Map.from(row as Map);
          final uid = (u['id'] ?? '').toString().trim();
          if (uid.isEmpty) continue;
          final rawName =
              (u['name'] ?? u['full_name'] ?? u['username'] ?? '')
                  .toString()
                  .trim();
          if (!_isGenericName(rawName)) {
            userNameById[uid] = rawName;
          } else {
            final email = (u['email'] ?? '').toString().trim();
            if (email.contains('@')) {
              userNameById[uid] = email.split('@').first;
            }
          }
        }
      } catch (_) {}

      final orderInfoByCode = {};
      try {
        final ordersRes = await _supabase.from('orders').select(
            'order_code, service_name, speed, status, customer_name, user_id');

        for (final row in ordersRes) {
          final map = Map.from(row as Map);
          final code = (map['order_code'] ?? '').toString().trim();
          if (code.isEmpty) continue;

          final uid = (map['user_id'] ?? '').toString().trim();
          String cName = (map['customer_name'] ?? '').toString().trim();
          if (_isGenericName(cName) && uid.isNotEmpty) {
            cName = (userNameById[uid] ?? '').toString();
          }

          final svc = (map['service_name'] ?? 'Laundry').toString();
          final spd = (map['speed'] ?? '').toString();
          orderInfoByCode[code] = {
            'userId': uid,
            'customerName': cName,
            'serviceName': spd.isNotEmpty ? '$svc - $spd' : svc,
            'status': (map['status'] ?? 'Diproses').toString(),
          };
        }
      } catch (_) {}

      final msgRes = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: false);

      final customerGroups = {};

      for (final row in msgRes) {
        final m = Map.from(row as Map);
        final code = (m['order_code'] ?? '').toString().trim();
        if (code.isEmpty) continue;

        final orderMeta = orderInfoByCode[code] is Map
            ? Map.from(orderInfoByCode[code] as Map)
            : {};
        final uid = (orderMeta['userId'] ?? '').toString().trim();

        String customerName = (orderMeta['customerName'] ?? '').toString().trim();
        if (_isGenericName(customerName) &&
            m['sender_role']?.toString() == 'customer') {
          final sName = (m['sender_name'] ?? '').toString().trim();
          if (!_isGenericName(sName)) {
            customerName = sName;
          }
        }
        if (_isGenericName(customerName)) {
          customerName = 'Pelanggan';
        }

        final String customerKey = uid.isNotEmpty
            ? 'uid:$uid'
            : 'name:${customerName.toLowerCase()}';

        if (!customerGroups.containsKey(customerKey)) {
          customerGroups[customerKey] = {
            'customerKey': customerKey,
            'userId': uid,
            'customerName': customerName,
            'latestOrderCode': code,
            'latestServiceName':
                (orderMeta['serviceName'] ?? 'Laundry').toString(),
            'latestStatus': (orderMeta['status'] ?? 'Diproses').toString(),
            'lastMessage': (m['message_text'] ?? '').toString(),
            'lastSenderRole': (m['sender_role'] ?? '').toString(),
            'time': _formatTime(m['created_at']),
            'unreadCount': 0,
            'orderCodes': [],
            'ordersMeta': [],
          };
        }

        final group = customerGroups[customerKey] as Map;

        if (_isGenericName(group['customerName'].toString()) &&
            !_isGenericName(customerName)) {
          group['customerName'] = customerName;
        }

        final codes = group['orderCodes'] as List;
        if (!codes.contains(code)) {
          codes.add(code);
          (group['ordersMeta'] as List).add({
            'orderId': code,
            'serviceName':
                (orderMeta['serviceName'] ?? 'Laundry').toString(),
            'status': (orderMeta['status'] ?? 'Diproses').toString(),
          });
        }

        if (m['sender_role']?.toString() == 'customer' &&
            m['is_read'] == false) {
          group['unreadCount'] = ((group['unreadCount'] as int?) ?? 0) + 1;
        }
      }

      if (!mounted) return;
      setState(() {
        _chatList = customerGroups.values.toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (showLoader) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = _chatList.where((item) {
      final chat = Map.from(item as Map);
      final name = (chat['customerName'] ?? '').toString().toLowerCase();
      final codes = (chat['orderCodes'] as List).join(' ').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || codes.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
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
                  Row(
                    children: [
                      Expanded(
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
                              '1 ruang obrolan per pelanggan beserta konteks pesanannya',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: const Color(0xFF2E637E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_chatList.length} Pelanggan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _C.navy,
                            ),
                          ),
                        ),
                    ],
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
                        hintText: 'Cari nama pelanggan atau kode pesanan...',
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _C.teal),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadAdminChats(showLoader: false),
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
                              final chat =
                                  Map.from(filteredChats[index] as Map);
                              final int unread =
                                  (chat['unreadCount'] as int?) ?? 0;
                              final String customerName =
                                  chat['customerName'].toString();
                              final orderCodes = chat['orderCodes'] as List;
                              final String latestOrderCode =
                                  chat['latestOrderCode'].toString();
                              final bool isAdminLast =
                                  chat['lastSenderRole'] == 'admin';

                              return InkWell(
                                onTap: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    '/admin-chat-room',
                                    arguments: {
                                      'customerName': customerName,
                                      'userId': chat['userId'],
                                      'orderId': latestOrderCode,
                                      'serviceName': chat['latestServiceName'],
                                      'status': chat['latestStatus'],
                                      'orderCodes': orderCodes,
                                      'ordersMeta': chat['ordersMeta'],
                                    },
                                  );
                                  if (mounted) {
                                    _loadAdminChats(showLoader: false);
                                  }
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: unread > 0
                                          ? const Color(0xFF7DD3FC)
                                          : const Color(0xFFE2E8F0),
                                      width: unread > 0 ? 1.4 : 1,
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
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            const Color(0xFF338CA8),
                                        child: Text(
                                          _getInitials(customerName),
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    customerName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _C.navy,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _C.headerBlue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    orderCodes.length > 1
                                                        ? '$latestOrderCode (+${orderCodes.length - 1})'
                                                        : latestOrderCode,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _C.navy,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              chat['latestServiceName']
                                                  .toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                                color: _C.teal,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${isAdminLast ? 'Anda: ' : ''}${chat['lastMessage']}',
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}