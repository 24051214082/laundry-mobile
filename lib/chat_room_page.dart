
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController _msgController =
  TextEditingController();

  // Daftar pesan percakapan
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
      'Halo Kak Zea! Ada yang bisa kami bantu terkait pesanan laundry-nya?',
      'time': '09:15',
    },
  ];

  // Fungsi mengirim pesan
  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;

    final now = TimeOfDay.now();

    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'isUser': true,
        'text': _msgController.text.trim(),
        'time': formattedTime,
      });

      _msgController.clear();
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menerima argumen dari Order Detail atau Chat List
    final args =
    ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>?;

    final String orderId =
        args?['orderId']?.toString() ?? '#LKN4wa123';

    final String serviceName =
        args?['serviceName']?.toString() ?? 'Laundry Kiloan 5 kg';

    final String status =
        args?['status']?.toString() ?? 'Diproses';

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
                  color: Colors.black.withOpacity(0.04),
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
                            orderId,
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
                              status,
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
                        serviceName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Lihat Nota',
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                final bool isUser = msg['isUser'] == true;

                final String textContent =
                (msg['text'] ?? '').toString();

                final String timeContent =
                (msg['time'] ?? '').toString();

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width * 0.76,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? _C.bubbleUser
                          : _C.bubbleAdmin,
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
                          color: Colors.black.withOpacity(0.03),
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
                        hintText:
                        'Tanyakan sesuatu tentang pesanan ini...',
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
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: const BoxDecoration(
                      color: Color(0xFF338CA8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
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
