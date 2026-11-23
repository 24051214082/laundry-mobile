import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_bottom_nav.dart';
import 'user_session.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const teal = Color(0xFF338CA8);
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State createState() => _ChatListPageState();
}

class _ChatListPageState extends State {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  var _userOrders = [];
  String _lastMessage = 'Ketuk untuk mulai chat dengan Admin Wish You Wash';
  String _lastMessageTime = '';
  String _lastOrderCode = '';
  bool _isAdminLast = false;
  int _unreadAdminCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomerChatSummary();
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

  Future _loadCustomerChatSummary() async {
    setState(() => _isLoading = true);
    try {
      final uid = (UserSession.userId ?? '').trim();
      final userName = (UserSession.name ?? '').trim().toLowerCase();

      // 1. Ambil semua pesanan milik customer ini
      final ordersRes = await _supabase
          .from('orders')
          .select()
          .order('order_code', ascending: false);

      final myOrders = [];
      final myCodes = [];

      for (final row in ordersRes) {
        final map = Map.from(row as Map);
        final rowUid = (map['user_id'] ?? '').toString().trim();
        final rowCust = (map['customer_name'] ?? '').toString().trim().toLowerCase();

        final isMine = (uid.isNotEmpty && rowUid == uid) ||
            (userName.isNotEmpty &&
                userName != 'customer' &&
                rowCust == userName);

        if (!isMine) continue;

        final code = (map['order_code'] ?? '').toString().trim();
        if (code.isEmpty) continue;

        final svc = (map['service_name'] ?? 'Laundry').toString();
        final spd = (map['speed'] ?? '').toString();
        final status = (map['status'] ?? 'Diproses').toString();

        myCodes.add(code);
        myOrders.add({
          'orderId': code,
          'serviceName': spd.isNotEmpty ? '$svc - $spd' : svc,
          'status': status,
        });
      }

      // 2. Ambil riwayat pesan milik pesanan customer ini
      String lastMsg = 'Ketuk untuk mulai chat dengan Admin Wish You Wash';
      String lastTime = '';
      String lastCode = myOrders.isNotEmpty
          ? (myOrders.first as Map)['orderId'].toString()
          : '';
      bool adminLast = false;
      int unreadCount = 0;

      if (myCodes.isNotEmpty) {
        final msgRes = await _supabase
            .from('messages')
            .select()
            .order('created_at', ascending: false);

        bool foundLatest = false;
        for (final row in msgRes) {
          final m = Map.from(row as Map);
          final code = (m['order_code'] ?? '').toString().trim();
          if (!myCodes.contains(code)) continue;

          if (!foundLatest) {
            foundLatest = true;
            lastMsg = (m['message_text'] ?? '').toString();
            lastTime = _formatTime(m['created_at']);
            lastCode = code;
            adminLast = m['sender_role']?.toString() == 'admin';
          }

          if (m['sender_role']?.toString() == 'admin' &&
              m['is_read'] == false) {
            unreadCount++;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _userOrders = myOrders;
        _lastMessage = lastMsg;
        _lastMessageTime = lastTime;
        _lastOrderCode = lastCode;
        _isAdminLast = adminLast;
        _unreadAdminCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future _openUnifiedChatRoom([Map? selectedOrder]) async {
    Map targetOrder = {};
    if (selectedOrder != null) {
      targetOrder = Map.from(selectedOrder);
    } else if (_userOrders.isNotEmpty) {
      final found = _userOrders.firstWhere(
        (o) => (o as Map)['orderId'] == _lastOrderCode,
        orElse: () => _userOrders.first,
      );
      targetOrder = Map.from(found as Map);
    }

    await Navigator.pushNamed(
      context,
      '/chat-room',
      arguments: {
        'orderId': (targetOrder['orderId'] ?? '').toString(),
        'serviceName': (targetOrder['serviceName'] ?? 'Layanan Laundry').toString(),
        'status': (targetOrder['status'] ?? 'Diproses').toString(),
        'allOrders': _userOrders,
      },
    );

    if (mounted) {
      _loadCustomerChatSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickOrders = _userOrders.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
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
                    'Pesan & Bantuan',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _C.navy,
                    ),
                  ),
                  Text(
                    'Hubungi admin & pilih pesanan yang ingin ditanyakan',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF2E637E),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten Utama
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _C.teal),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCustomerChatSummary,
                    color: _C.teal,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: [
                        // 1. SATU KARTU UTAMA: CHAT ADMIN WISH YOU WASH
                        Text(
                          'Ruang Obrolan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.navy,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _openUnifiedChatRoom(),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _unreadAdminCount > 0
                                    ? const Color(0xFF7DD3FC)
                                    : const Color(0xFFE2E8F0),
                                width: _unreadAdminCount > 0 ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: _C.headerBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.support_agent_rounded,
                                        color: _C.navy,
                                        size: 28,
                                      ),
                                    ),
                                    Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF22C55E),
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
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Admin Wish You Wash',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: _C.navy,
                                              ),
                                            ),
                                          ),
                                          if (_lastMessageTime.isNotEmpty)
                                            Text(
                                              _lastMessageTime,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight:
                                                    _unreadAdminCount > 0
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                color: _unreadAdminCount > 0
                                                    ? _C.teal
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      if (_lastOrderCode.isNotEmpty)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _C.headerBlue,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Terakhir dibahas: $_lastOrderCode',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: _C.navy,
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${_isAdminLast ? 'Admin: ' : ''}$_lastMessage',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight:
                                                    _unreadAdminCount > 0
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                color: _unreadAdminCount > 0
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                          if (_unreadAdminCount > 0) ...[
                                            const SizedBox(width: 8),
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
                                                _unreadAdminCount.toString(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. PINTASAN CEPAT: TANYAKAN PESANAN TERTENTU
                        if (quickOrders.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tanyakan Pesanan Tertentu',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _C.navy,
                                ),
                              ),
                              Text(
                                '${_userOrders.length} Total Pesanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _C.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pilih pesanan di bawah untuk langsung menanyakannya ke admin:',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...quickOrders.map((rawOrder) {
                            final order = Map.from(rawOrder as Map);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _openUnifiedChatRoom(order),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: _C.headerBlue,
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: const Icon(
                                          Icons.local_laundry_service_rounded,
                                          color: _C.navy,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order['orderId'].toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: _C.navy,
                                              ),
                                            ),
                                            Text(
                                              order['serviceName'].toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Tanya Admin',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: _C.navy,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}