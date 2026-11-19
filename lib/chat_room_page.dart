import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const button = Color(0xFF263F73);
  static const bubbleUser = Color(0xFF338CA8);
  static const bubbleAdmin = Color(0xFFF1F5F9);
}

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _initializedArgs = false;
  bool _isSending = false;
  bool _isMarkingRead = false;

  String _orderId = '#LKN4wa123';
  String _serviceName = 'Laundry Kiloan 5 kg';
  String _status = 'Diproses';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedArgs) return;
    _initializedArgs = true;

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final rawOrderId = args['orderId']?.toString().trim();
      if (rawOrderId != null && rawOrderId.isNotEmpty) {
        _orderId = rawOrderId;
      }
      final rawService = args['serviceName']?.toString().trim();
      if (rawService != null && rawService.isNotEmpty) {
        _serviceName = rawService;
      }
      final rawStatus = args['status']?.toString().trim();
      if (rawStatus != null && rawStatus.isNotEmpty) {
        _status = rawStatus;
      }
    }

    _markAdminMessagesAsRead();
  }

  String get _currentUserName {
    try {
      final dynamic session = UserSession;
      final name = (session.userName ??
          session.fullName ??
          session.name ??
          session.email ??
          'Customer')
          .toString()
          .trim();
      return name.isEmpty ? 'Customer' : name;
    } catch (_) {
      return 'Customer';
    }
  }

  Future<void> _markAdminMessagesAsRead() async {
    if (_isMarkingRead) return;
    _isMarkingRead = true;
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('order_code', _orderId)
          .eq('sender_role', 'admin')
          .eq('is_read', false);
    } catch (_) {
    } finally {
      _isMarkingRead = false;
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _msgController.clear();

    try {
      await _supabase.from('messages').insert({
        'order_code': _orderId,
        'sender_role': 'customer',
        'sender_name': _currentUserName,
        'message_text': text,
        'is_read': false,
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      _msgController.text = text;
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
        .eq('order_code', _orderId)
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
          // Banner Ringkasan Pesanan
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
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
                            _orderId,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
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
                              _status,
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
                        _serviceName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/status-pesanan',
                      arguments: {
                        'orderId': _orderId,
                        'serviceName': _serviceName,
                        'status': _status,
                        'weight': '5.0 kg',
                        'treatment': 'Cuci + Setrika',
                        'perfume': 'Ocean Fresh',
                        'detergent': 'Anti Bakteri',
                        'method': 'Antar Jemput Driver',
                        'address': 'Jl. Ketintang Baru No. 12, Surabaya',
                        'totalPrice': 'Rp 35.000',
                        'estimate': '18 April 2027, 08.00',
                        'image': 'assets/laundrykiloan.PNG',
                      },
                    );
                  },
                  child: Text(
                    'Status Pesanan',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF338CA8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Pesan Chat
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
                    child: CircularProgressIndicator(color: Color(0xFF338CA8)),
                  );
                }

                final rawList = (snapshot.data as List);
                final seenIds = <String>{};
                final List messages = [];

                for (final e in rawList) {
                  final map = Map<String, dynamic>.from(e as Map);
                  final idStr = map['id']?.toString() ?? '';
                  if (idStr.isNotEmpty) {
                    if (seenIds.contains(idStr)) continue;
                    seenIds.add(idStr);
                  }
                  messages.add(map);
                }

                final hasUnreadAdmin = messages.any(
                      (m) =>
                  m['sender_role']?.toString() == 'admin' &&
                      m['is_read'] == false,
                );
                if (hasUnreadAdmin && !_isMarkingRead) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markAdminMessagesAsRead();
                  });
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Belum ada pesan untuk pesanan $_orderId.\nMulai chat dengan admin di bawah ini.',
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
                    final msg = messages[index];
                    final bool isUser =
                        msg['sender_role']?.toString() == 'customer';
                    final String textContent =
                    (msg['message_text'] ?? '').toString();
                    final String timeContent = _formatTime(msg['created_at']);

                    return Align(
                      alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.76,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? _C.bubbleUser : _C.bubbleAdmin,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(
                              isUser ? 16 : 4,
                            ),
                            bottomRight: Radius.circular(
                              isUser ? 4 : 16,
                            ),
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
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
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
                  },
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
                top: BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: GoogleFonts.poppins(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan sesuatu tentang pesanan ini...',
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
                  onTap: _isSending ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: const BoxDecoration(
                      color: Color(0xFF338CA8),
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