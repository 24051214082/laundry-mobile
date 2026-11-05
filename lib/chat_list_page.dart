
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bottom_nav.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const textSub = Color(0xFF64748B);
  static const primaryBlue = Color(0xFF338CA8);
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar dummy percakapan berdasarkan transaksi laundry
    final List<Map<String, dynamic>> chatThreads = [
      {
        'orderId': '#LKN4wa123',
        'serviceName': 'Laundry Kiloan 5 kg',
        'status': 'Diproses',
        'lastMessage':
        'Halo Kak Zea! Ada yang bisa kami bantu terkait pesanan laundry-nya?',
        'time': '09:15',
        'unread': 1,
      },
      {
        'orderId': '#LD001',
        'serviceName': 'Bed Cover King Size',
        'status': 'Selesai',
        'lastMessage':
        'Terima kasih kak, cucian sudah diantar driver ya!',
        'time': 'Kemarin',
        'unread': 0,
      },
      {
        'orderId': '#LK089',
        'serviceName': 'Laundry Satuan (Jas & Kemeja)',
        'status': 'Selesai',
        'lastMessage':
        'Pewanginya mau pakai Ocean Fresh atau Lavender kak?',
        'time': '12 Okt',
        'unread': 0,
      },
    ];

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
                      '${chatThreads.length} Pesanan',
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
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: chatThreads.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 16,
                  color: Color(0xFFF1F5F9),
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final thread = chatThreads[index];
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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat-room',
                        arguments: thread,
                      );
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
                                  Icons.local_laundry_service_rounded,
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
                                      color: const Color(0xFFEF4444),
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
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      orderId,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
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
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
