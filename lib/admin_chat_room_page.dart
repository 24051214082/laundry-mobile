import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const bubbleAdmin = Color(0xFF338CA8);
  static const bubbleCustomer = Color(0xFFF1F5F9);
}

class AdminChatRoomPage extends StatefulWidget {
  const AdminChatRoomPage({super.key});

  @override
  State<AdminChatRoomPage> createState() => _AdminChatRoomPageState();
}

class _AdminChatRoomPageState extends State<AdminChatRoomPage> {
  final TextEditingController _msgController = TextEditingController();

  // Daftar pesan percakapan (isAdmin: true = kanan/admin, false = kiri/customer)
  final List _messages = [
    {
      'isAdmin': false,
      'text': 'Halo Min, pesanan #LKN4wa123 saya kira-kira selesai jam berapa ya?',
      'time': '09:14',
    },
    {
      'isAdmin': true,
      'text': 'Halo Kak Zea! Saat ini cuciannya sedang tahap penyetrikaan ya, estimasi selesai jam 11.00 WIB.',
      'time': '09:15',
    },
  ];

  // Template balasan cepat untuk Admin
  final List _quickReplies = [
    'Pesanan sedang diproses ya Kak',
    'Kurir segera meluncur ke lokasi',
    'Cucian sudah selesai dan siap antar',
    'Pembayaran sudah kami terima, terima kasih!',
  ];

  void _sendMessage([String? customText]) {
    final text = (customText ?? _msgController.text).trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'isAdmin': true,
        'text': text,
        'time': formattedTime,
      });
      if (customText == null) {
        _msgController.clear();
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menerima argumen dari Chat List Admin atau Detail Pesanan
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String customerName =
        args?['customerName']?.toString() ?? 'Zea';
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
            const CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFF4285F4),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                ),
                Text(
                  'Pelanggan • Aktif',
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
          // Banner Ringkasan Pesanan Pelanggan
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
                  onPressed: () {
                    // Navigasi ke detail pesanan admin jika diperlukan
                  },
                  child: Text(
                    'Detail Order',
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
                final bool isAdmin = msg['isAdmin'] == true;
                final String textContent = (msg['text'] ?? '').toString();
                final String timeContent = (msg['time'] ?? '').toString();

                return Align(
                  alignment:
                      isAdmin ? Alignment.centerRight : Alignment.centerLeft,
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
                  onTap: () => _sendMessage(_quickReplies[index]),
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
                      _quickReplies[index],
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
                        hintText: 'Balas pesan pelanggan...',
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
                  onTap: () => _sendMessage(),
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