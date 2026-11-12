import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data dummy daftar pesan masuk dari pelanggan
  final List _chatList = [
    {
      'customerName': 'Zea',
      'orderId': '#LKN4wa123',
      'serviceName': 'Laundry Kiloan 5 kg',
      'status': 'Diproses',
      'lastMessage': 'Halo Min, pesanan #LKN4wa123 saya kira-kira selesai jam berapa ya?',
      'time': '09:14',
      'unreadCount': 1,
    },
    {
      'customerName': 'Nency',
      'orderId': '#LKN4wa122',
      'serviceName': 'Bed Cover + Setrika',
      'status': 'Penjemputan',
      'lastMessage': 'Baik kak, ditunggu kurirnya ya. Pakaian sudah siap di depan.',
      'time': '08:40',
      'unreadCount': 2,
    },
    {
      'customerName': 'Alya Putri',
      'orderId': '#LKN4wa119',
      'serviceName': 'Laundry Satuan (Jas)',
      'status': 'Selesai',
      'lastMessage': 'Terima kasih banyak min, jasnya wangi dan rapi banget!',
      'time': 'Kemarin',
      'unreadCount': 0,
    },
    {
      'customerName': 'Rizky Pratama',
      'orderId': '#LKN4wa115',
      'serviceName': 'Laundry Kiloan 3 kg',
      'status': 'Selesai',
      'lastMessage': 'Oke siap min, pembayaran sudah saya transfer.',
      'time': '10 Nov',
      'unreadCount': 0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter pencarian nama pelanggan atau ID pesanan
    final filteredChats = _chatList.where((chat) {
      final name = chat['customerName'].toString().toLowerCase();
      final orderId = chat['orderId'].toString().toLowerCase();
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredChats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                final int unread = chat['unreadCount'] ?? 0;

                return InkWell(
                  onTap: () {
                    // Lempar data pelanggan & pesanan ke AdminChatRoomPage
                    Navigator.pushNamed(
                      context,
                      '/admin-chat-room',
                      arguments: {
                        'customerName': chat['customerName'],
                        'orderId': chat['orderId'],
                        'serviceName': chat['serviceName'],
                        'status': chat['status'],
                      },
                    );
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
                          color: Colors.black.withValues(alpha: 0.03),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    chat['customerName'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _C.navy,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _C.headerBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      chat['orderId'],
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
                                chat['lastMessage'],
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              chat['time'],
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
        ],
      ),
      // Tetap menampilkan Bottom Nav Admin dengan tab Chat aktif (index: 1)
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}