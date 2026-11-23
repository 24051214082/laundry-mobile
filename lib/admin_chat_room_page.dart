import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const teal = Color(0xFF338CA8);
  static const bubbleAdmin = Color(0xFF338CA8);
  static const bubbleCustomer = Color(0xFFF1F5F9);
}

class AdminChatRoomPage extends StatefulWidget {
  const AdminChatRoomPage({super.key});

  @override
  State createState() => _AdminChatRoomPageState();
}

class _AdminChatRoomPageState extends State {
  final _supabase = Supabase.instance.client;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _initializedArgs = false;
  bool _isSending = false;
  bool _isMarkingRead = false;

  String _customerName = 'Pelanggan';
  String _activeOrderId = '';
  String _activeServiceName = 'Laundry';
  String _activeStatus = 'Diproses';

  String _filterOrderCode = 'ALL';

  var _orderCodes = [];
  final _orderMetaByCode = {};

  final List _quickReplies = [
    'Pesanan sedang diproses ya Kak',
    'Kurir segera meluncur ke lokasi',
    'Cucian sudah selesai dan siap antar',
    'Pembayaran sudah kami terima, terima kasih!',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedArgs) return;
    _initializedArgs = true;

    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map ? Map.from(rawArgs) : null;

    if (args != null) {
      final rawName = args['customerName']?.toString().trim();
      if (rawName != null && rawName.isNotEmpty) {
        _customerName = rawName;
      }

      final rawOrderId = args['orderId']?.toString().trim() ?? '';
      final rawService = args['serviceName']?.toString().trim() ?? 'Laundry';
      final rawStatus = args['status']?.toString().trim() ?? 'Diproses';

      if (rawOrderId.isNotEmpty) {
        _activeOrderId = rawOrderId;
        _activeServiceName = rawService;
        _activeStatus = rawStatus;
        _orderMetaByCode[rawOrderId] = {
          'serviceName': rawService,
          'status': rawStatus,
        };
      }

      if (args['orderCodes'] is List) {
        _orderCodes = (args['orderCodes'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (_orderCodes.isEmpty && _activeOrderId.isNotEmpty) {
        _orderCodes = [_activeOrderId];
      }

      if (args['ordersMeta'] is List) {
        for (final item in (args['ordersMeta'] as List)) {
          if (item is Map) {
            final code = (item['orderId'] ?? '').toString().trim();
            if (code.isNotEmpty) {
              _orderMetaByCode[code] = {
                'serviceName': (item['serviceName'] ?? 'Laundry').toString(),
                'status': (item['status'] ?? 'Diproses').toString(),
              };
            }
          }
        }
      }
    }

    _markCustomerMessagesAsRead();
  }

  void _selectReplyTargetOrder(String code) {
    if (!_orderMetaByCode.containsKey(code)) return;
    final meta = Map.from(_orderMetaByCode[code] as Map);
    setState(() {
      _activeOrderId = code;
      _activeServiceName =
          (meta['serviceName'] ?? _activeServiceName).toString();
      _activeStatus = (meta['status'] ?? _activeStatus).toString();
    });
  }

  Future _markCustomerMessagesAsRead() async {
    if (_isMarkingRead || _orderCodes.isEmpty) return;
    _isMarkingRead = true;
    try {
      for (final code in _orderCodes) {
        await _supabase
            .from('messages')
            .update({'is_read': true})
            .eq('order_code', code.toString())
            .eq('sender_role', 'customer')
            .eq('is_read', false);
      }
    } catch (_) {
    } finally {
      _isMarkingRead = false;
    }
  }

  Future _sendMessage([String? customText]) async {
    final text = (customText ?? _msgController.text).trim();
    if (text.isEmpty || _isSending || _activeOrderId.isEmpty) return;

    setState(() => _isSending = true);
    if (customText == null) {
      _msgController.clear();
    }

    try {
      await _supabase.from('messages').insert({
        'order_code': _activeOrderId,
        'sender_role': 'admin',
        'sender_name': 'Admin Wish You Wash',
        'message_text': text,
        'is_read': false,
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      if (customText == null) {
        _msgController.text = text;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal mengirim balasan: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(dynamic rawCreatedAt) {
    if (rawCreatedAt == null) {
      final now = TimeOfDay.now();
      return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
    final dt = DateTime.tryParse(rawCreatedAt.toString())?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _C.headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _C.navy,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: _C.teal,
              child: Text(
                _getInitials(_customerName),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _C.navy,
                    ),
                  ),
                  Text(
                    'Pelanggan • ${_orderCodes.length} Pesanan Terkait',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_orderCodes.length > 1)
            Container(
              height: 44,
              color: _C.headerBlue.withValues(alpha: 0.45),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildOrderFilterChip(
                    label: 'Semua (${_orderCodes.length})',
                    isSelected: _filterOrderCode == 'ALL',
                    onTap: () => setState(() => _filterOrderCode = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  ..._orderCodes.map((rawCode) {
                    final code = rawCode.toString();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildOrderFilterChip(
                        label: code,
                        isSelected: _filterOrderCode == code,
                        onTap: () {
                          setState(() => _filterOrderCode = code);
                          _selectReplyTargetOrder(code);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Banner Konteks Pesanan yang Sedang Ditanyakan / Dibalas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.headerBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_laundry_service_rounded,
                    color: _C.navy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Konteks Balas: $_activeOrderId',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _C.navy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9D5FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _activeStatus,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7E22CE),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _activeServiceName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_orderCodes.length > 1)
                  PopupMenuButton(
                    tooltip: 'Pilih pesanan untuk dibalas',
                    onSelected: (val) =>
                        _selectReplyTargetOrder(val.toString()),
                    itemBuilder: (context) => _orderCodes.map((rawCode) {
                      final code = rawCode.toString();
                      final meta = _orderMetaByCode[code] is Map
                          ? Map.from(_orderMetaByCode[code] as Map)
                          : {};
                      final svc = (meta['serviceName'] ?? 'Laundry').toString();
                      return PopupMenuItem(
                        value: code,
                        child: Text(
                          '$code • $svc',
                          style: GoogleFonts.poppins(fontSize: 11.5),
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Ganti Order',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: _C.navy,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: _C.navy,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Daftar Pesan Chat Gabungan Customer
          Expanded(
            child: StreamBuilder(
              stream: messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Gagal memuat pesan: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.teal),
                  );
                }

                final rawList = (snapshot.data as List);
                final seenIds = {};
                final messages = [];

                for (final e in rawList) {
                  final map = Map.from(e as Map);
                  final code = (map['order_code'] ?? '').toString().trim();
                  if (!_orderCodes.contains(code)) continue;
                  if (_filterOrderCode != 'ALL' && code != _filterOrderCode) {
                    continue;
                  }

                  final idStr = map['id']?.toString() ?? '';
                  if (idStr.isNotEmpty) {
                    if (seenIds.containsKey(idStr)) continue;
                    seenIds[idStr] = true;
                  }
                  messages.add(map);
                }

                final hasUnreadCustomer = messages.any(
                  (m) =>
                      (m as Map)['sender_role']?.toString() == 'customer' &&
                      m['is_read'] == false,
                );
                if (hasUnreadCustomer && !_isMarkingRead) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markCustomerMessagesAsRead();
                  });
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Belum ada riwayat chat dari $_customerName.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = Map.from(messages[index] as Map);
                    final bool isAdmin =
                        msg['sender_role']?.toString() == 'admin';
                    final String textContent =
                        (msg['message_text'] ?? '').toString();
                    final String timeContent = _formatTime(msg['created_at']);
                    final String msgOrderCode =
                        (msg['order_code'] ?? '').toString().trim();
                    final meta = _orderMetaByCode[msgOrderCode] is Map
                        ? Map.from(_orderMetaByCode[msgOrderCode] as Map)
                        : {};
                    final String msgService =
                        (meta['serviceName'] ?? '').toString();

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => _selectReplyTargetOrder(msgOrderCode),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin ? _C.bubbleAdmin : _C.bubbleCustomer,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                              bottomRight: Radius.circular(isAdmin ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isAdmin
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (msgOrderCode.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : _C.headerBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    msgService.isNotEmpty
                                        ? '$msgOrderCode • $msgService'
                                        : msgOrderCode,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: isAdmin ? Colors.white : _C.navy,
                                    ),
                                  ),
                                ),
                              Text(
                                textContent,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: isAdmin
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeContent,
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  color: isAdmin
                                      ? Colors.white70
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bar Balasan Cepat (Quick Replies)
          Container(
            height: 42,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _isSending
                      ? null
                      : () => _sendMessage(_quickReplies[index].toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                      ),
                    ),
                    child: Text(
                      _quickReplies[index].toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.navy,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Text Bar Bawah
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: GoogleFonts.poppins(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'Balas untuk pesanan $_activeOrderId...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : () => _sendMessage(),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: const BoxDecoration(
                      color: _C.teal,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _C.navy : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _C.navy : const Color(0xFFBAE6FD),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _C.navy,
          ),
        ),
      ),
    );
  }
}