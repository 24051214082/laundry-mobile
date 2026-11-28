import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const teal = Color(0xFF338CA8);
  static const bubbleUser = Color(0xFF338CA8);
  static const bubbleAdmin = Color(0xFFF1F5F9);
}

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State {
  final _supabase = Supabase.instance.client;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _pollTimer;
  bool _initializedArgs = false;
  bool _isLoadingMessages = true;
  bool _isSending = false;
  bool _isMarkingRead = false;
  bool _isFetching = false;

  String _activeOrderId = '';
  String _activeServiceName = 'Layanan Laundry';
  String _activeStatus = 'Diproses';
  String _resolvedCustomerName = '';

  var _allOrders = [];
  final _orderMetaByCode = {};
  var _messages = [];

  final List _quickQuestions = [
    'Halo Admin, bagaimana status pesanan ini?',
    'Kapan estimasi cucian selesai?',
    'Apakah sudah siap diantar?',
    'Saya ingin konfirmasi pembayaran',
  ];

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) _fetchMessages(initialLoad: false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedArgs) return;
    _initializedArgs = true;

    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map ? Map.from(rawArgs) : null;

    if (args != null) {
      final rawOrderId = args['orderId']?.toString().trim() ?? '';
      final rawService =
          args['serviceName']?.toString().trim() ?? 'Layanan Laundry';
      final rawStatus = args['status']?.toString().trim() ?? 'Diproses';

      if (rawOrderId.isNotEmpty) {
        _activeOrderId = rawOrderId;
        _activeServiceName = rawService;
        _activeStatus = rawStatus;
        _orderMetaByCode[rawOrderId] = {
          'orderId': rawOrderId,
          'serviceName': rawService,
          'status': rawStatus,
        };
      }

      if (args['allOrders'] is List) {
        _allOrders = List.from(args['allOrders'] as List);
        for (final item in _allOrders) {
          if (item is Map) {
            final code = (item['orderId'] ?? '').toString().trim();
            if (code.isNotEmpty) {
              _orderMetaByCode[code] = Map.from(item);
            }
          }
        }
      }
    }

    _bootstrapCustomerData();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future _syncCustomerOrders() async {
    try {
      final uid = (UserSession.userId ?? '').trim();
      final userName = _resolvedCustomerName.trim().toLowerCase();

      final ordersRes = await _supabase
          .from('orders')
          .select()
          .order('order_code', ascending: false);

      final loaded = [];
      for (final row in ordersRes) {
        final map = Map.from(row as Map);
        final rowUid = (map['user_id'] ?? '').toString().trim();
        final rowCust =
            (map['customer_name'] ?? '').toString().trim().toLowerCase();

        final isMine = (uid.isNotEmpty && rowUid == uid) ||
            (userName.isNotEmpty &&
                userName != 'customer' &&
                userName != 'pelanggan' &&
                rowCust == userName);

        if (!isMine) continue;

        final code = (map['order_code'] ?? '').toString().trim();
        if (code.isEmpty) continue;

        final svc = (map['service_name'] ?? 'Laundry').toString();
        final spd = (map['speed'] ?? '').toString();
        final meta = {
          'orderId': code,
          'serviceName': spd.isNotEmpty ? '$svc - $spd' : svc,
          'status': (map['status'] ?? 'Diproses').toString(),
        };
        loaded.add(meta);
        _orderMetaByCode[code] = meta;
      }

      if (mounted && loaded.isNotEmpty) {
        _allOrders = loaded;
        if (_activeOrderId.isEmpty) {
          final first = Map.from(loaded.first as Map);
          _activeOrderId = first['orderId'].toString();
          _activeServiceName = first['serviceName'].toString();
          _activeStatus = first['status'].toString();
        }
      }
    } catch (_) {}
  }

  Future _bootstrapCustomerData() async {
    await _resolveCustomerName();
    await _syncCustomerOrders();
    await _fetchMessages(initialLoad: true);
    _markAdminMessagesAsRead();
  }

  Future _fetchMessages({bool initialLoad = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      if (_orderMetaByCode.isEmpty) {
        await _syncCustomerOrders();
      }

      final rawList = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: true);

      final seenIds = {};
      final filtered = [];

      for (final e in rawList) {
        final map = Map.from(e as Map);
        final code = (map['order_code'] ?? '').toString().trim();
        if (code.isEmpty) continue;

        final isKnownOrder = _orderMetaByCode.containsKey(code);
        final isSameSender = _resolvedCustomerName.isNotEmpty &&
            (map['sender_name'] ?? '').toString().trim().toLowerCase() ==
                _resolvedCustomerName.trim().toLowerCase();

        if (!isKnownOrder && !isSameSender) continue;

        final idStr = map['id']?.toString() ?? '';
        if (idStr.isNotEmpty) {
          if (seenIds.containsKey(idStr)) continue;
          seenIds[idStr] = true;
        }
        filtered.add(map);
      }

      if (!mounted) return;
      final bool hasNewMessage = filtered.length > _messages.length;

      setState(() {
        _messages = filtered;
        if (initialLoad) _isLoadingMessages = false;
      });

      if (hasNewMessage || initialLoad) {
        _scrollToBottom();
      }

      final hasUnreadAdmin = filtered.any(
        (m) =>
            (m as Map)['sender_role']?.toString().trim().toLowerCase() ==
                'admin' &&
            m['is_read'] == false,
      );
      if (hasUnreadAdmin && !_isMarkingRead) {
        _markAdminMessagesAsRead();
      }
    } catch (_) {
      if (mounted && initialLoad) {
        setState(() => _isLoadingMessages = false);
      }
    } finally {
      _isFetching = false;
    }
  }

  Future _resolveCustomerName() async {
    final sessionName = (UserSession.name ?? '').trim();
    if (sessionName.isNotEmpty &&
        sessionName.toLowerCase() != 'customer' &&
        sessionName.toLowerCase() != 'pelanggan') {
      _resolvedCustomerName = sessionName;
      return;
    }

    try {
      final uid = (UserSession.userId ?? '').trim();
      if (uid.isNotEmpty) {
        final userRow = await _supabase
            .from('users')
            .select('name, full_name, username, email')
            .eq('id', uid)
            .maybeSingle();
        if (userRow != null) {
          final uName = (userRow['name'] ??
                  userRow['full_name'] ??
                  userRow['username'] ??
                  '')
              .toString()
              .trim();
          if (uName.isNotEmpty) {
            _resolvedCustomerName = uName;
            return;
          }
        }
      }
    } catch (_) {}

    if (_resolvedCustomerName.isEmpty) {
      final email = (UserSession.email ?? '').trim();
      _resolvedCustomerName =
          email.contains('@') ? email.split('@').first : 'Pelanggan';
    }
  }

  Future _markAdminMessagesAsRead() async {
    if (_isMarkingRead || _orderMetaByCode.isEmpty) return;
    _isMarkingRead = true;
    try {
      for (final code in _orderMetaByCode.keys) {
        await _supabase
            .from('messages')
            .update({'is_read': true})
            .eq('order_code', code.toString())
            .eq('sender_role', 'admin')
            .eq('is_read', false);
      }
    } catch (_) {
    } finally {
      _isMarkingRead = false;
    }
  }

  void _selectOrderContext(Map orderMap) {
    setState(() {
      _activeOrderId = (orderMap['orderId'] ?? _activeOrderId).toString();
      _activeServiceName =
          (orderMap['serviceName'] ?? _activeServiceName).toString();
      _activeStatus = (orderMap['status'] ?? _activeStatus).toString();
    });
  }

  Future _confirmAndDeleteMessage(Map msg) async {
    final msgId = msg['id'];
    if (msgId == null) return;

    final bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hapus Pesan Ini?',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _C.navy,
          ),
        ),
        content: Text(
          'Pesan akan dihapus permanen di layar Anda dan Admin (2 arah).',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus Pesan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _supabase.from('messages').delete().eq('id', msgId);
      setState(() {
        _messages.removeWhere((m) => (m as Map)['id'] == msgId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal menghapus pesan: $e',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    }
  }

  void _showOrderPickerSheet() {
    if (_allOrders.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pilih Pesanan yang Ditanyakan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                ),
                Text(
                  'Pesan berikutnya akan ditandai dengan kode pesanan ini',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _allOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final order = Map.from(_allOrders[index] as Map);
                      final code = order['orderId'].toString();
                      final isSelected = code == _activeOrderId;

                      return InkWell(
                        onTap: () {
                          _selectOrderContext(order);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _C.headerBlue.withValues(alpha: 0.6)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? _C.teal
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_laundry_service_rounded,
                                color: _C.navy,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      code,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: _C.navy,
                                      ),
                                    ),
                                    Text(
                                      order['serviceName'].toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9D5FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order['status'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7E22CE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _sendMessage([String? customText]) async {
    final text = (customText ?? _msgController.text).trim();
    if (text.isEmpty || _isSending || _activeOrderId.isEmpty) return;

    setState(() => _isSending = true);
    if (customText == null) {
      _msgController.clear();
    }

    if (_resolvedCustomerName.isEmpty) {
      await _resolveCustomerName();
    }

    try {
      await _supabase.from('messages').insert({
        'order_code': _activeOrderId,
        'sender_role': 'customer',
        'sender_name': _resolvedCustomerName,
        'message_text': text,
        'is_read': false,
      });

      await _fetchMessages(initialLoad: false);
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
            'Gagal mengirim pesan: $e',
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
          0.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  DateTime? _parseLocalDate(dynamic rawCreatedAt) {
    if (rawCreatedAt == null) return DateTime.now();
    return DateTime.tryParse(rawCreatedAt.toString())?.toLocal();
  }

  String _formatTime(dynamic rawCreatedAt) {
    final dt = _parseLocalDate(rawCreatedAt);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(dt.year, dt.month, dt.day);

    if (_isSameDay(target, today)) return 'Hari ini';
    if (_isSameDay(target, yesterday)) return 'Kemarin';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversedMessages = _messages.reversed.toList();

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
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: _C.navy,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Wish You Wash',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                ),
                Text(
                  'Online • Membalas cepat',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                            _activeOrderId.isEmpty
                                ? 'Pilih Pesanan'
                                : 'Menanyakan: $_activeOrderId',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _C.navy,
                            ),
                          ),
                          if (_activeOrderId.isNotEmpty) ...[
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
                        ],
                      ),
                      Text(
                        _activeServiceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_allOrders.length > 1)
                  GestureDetector(
                    onTap: _showOrderPickerSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Ganti Pesanan',
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

          // Daftar Pesan + Pembatas Tanggal di Tengah Layar
          Expanded(
            child: _isLoadingMessages
                ? const Center(
                    child: CircularProgressIndicator(color: _C.teal),
                  )
                : reversedMessages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Belum ada percakapan.\nPilih pesanan di atas lalu kirim pertanyaan ke Admin.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: reversedMessages.length,
                        itemBuilder: (context, index) {
                          final msg = Map.from(reversedMessages[index] as Map);
                          final roleStr = (msg['sender_role'] ?? '')
                              .toString()
                              .trim()
                              .toLowerCase();
                          final bool isUser = roleStr == 'customer';

                          final String textContent =
                              (msg['message_text'] ?? '').toString();
                          final DateTime? currentDt =
                              _parseLocalDate(msg['created_at']);
                          final String timeContent =
                              _formatTime(msg['created_at']);
                          final String msgOrderCode =
                              (msg['order_code'] ?? '').toString().trim();
                          final meta = _orderMetaByCode[msgOrderCode] is Map
                              ? Map.from(_orderMetaByCode[msgOrderCode] as Map)
                              : {};
                          final String msgService =
                              (meta['serviceName'] ?? '').toString();

                          // Tampilkan pembatas tanggal di atas pesan pertama hari itu
                          bool showDateHeader = false;
                          if (currentDt != null) {
                            if (index == reversedMessages.length - 1) {
                              showDateHeader = true;
                            } else {
                              final olderMsg = Map.from(
                                  reversedMessages[index + 1] as Map);
                              final DateTime? olderDt =
                                  _parseLocalDate(olderMsg['created_at']);
                              if (olderDt == null ||
                                  !_isSameDay(currentDt, olderDt)) {
                                showDateHeader = true;
                              }
                            }
                          }

                          final bubbleWidget = Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                  14, 10, 10, 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? _C.bubbleUser
                                    : _C.bubbleAdmin,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft:
                                      Radius.circular(isUser ? 16 : 4),
                                  bottomRight:
                                      Radius.circular(isUser ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (msgOrderCode.isNotEmpty)
                                        Flexible(
                                          child: InkWell(
                                            onTap: () {
                                              if (meta.isNotEmpty) {
                                                _selectOrderContext(meta);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isUser
                                                    ? Colors.white
                                                        .withValues(alpha: 0.18)
                                                    : _C.headerBlue,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                msgService.isNotEmpty
                                                    ? '$msgOrderCode • $msgService'
                                                    : msgOrderCode,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isUser
                                                      ? Colors.white
                                                      : _C.navy,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isUser) ...[
                                        const SizedBox(width: 6),
                                        PopupMenuButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Opsi pesan',
                                          onSelected: (val) {
                                            if (val == 'delete') {
                                              _confirmAndDeleteMessage(msg);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            PopupMenuItem(
                                              value: 'delete',
                                              height: 36,
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 16,
                                                    color: Colors.redAccent,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Hapus 2 Arah',
                                                    style:
                                                        GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          child: const Padding(
                                            padding: EdgeInsets.all(2),
                                            child: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    textContent,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: isUser
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeContent,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      color: isUser
                                          ? Colors.white70
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (showDateHeader && currentDt != null) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildDateSeparator(
                                    _formatDateHeader(currentDt)),
                                bubbleWidget,
                              ],
                            );
                          }

                          return bubbleWidget;
                        },
                      ),
          ),

          Container(
            height: 42,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _quickQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _isSending
                      ? null
                      : () => _sendMessage(_quickQuestions[index].toString()),
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
                      _quickQuestions[index].toString(),
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
                        hintText: _activeOrderId.isEmpty
                            ? 'Tulis pesan untuk admin...'
                            : 'Tanyakan tentang $_activeOrderId...',
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
}