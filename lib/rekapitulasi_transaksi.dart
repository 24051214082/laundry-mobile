import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RekapitulasiTransaksiPage extends StatefulWidget {
  const RekapitulasiTransaksiPage({super.key});

  @override
  State<RekapitulasiTransaksiPage> createState() => _RekapitulasiTransaksiPageState();
}

class _RekapitulasiTransaksiPageState extends State<RekapitulasiTransaksiPage> {
  int _currentIndex = 2; // Default aktif di menu Laporan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8F1FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Pencarian dengan Tombol Kembali
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFD8F1FD),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Tombol Kembali
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF1B4E6C),
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rekapitulasi Transaksi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B4E6C),
                                  ),
                                ),
                                Text(
                                  'Admin Laundry',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF326D8C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Notifikasi & Profil / Ikon Kanan
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF1B4E6C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Kolom Pencarian
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B4E6C).withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          hintText: 'Cari ID Pesanan atau Nama Customer',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Periode Transaksi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4E6C).withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF1B4E6C)),
                          const SizedBox(width: 8),
                          Text(
                            'PERIODE TRANSAKSI',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pilih tanggal atau bulan',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dari Tanggal', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('xx/xx/xxxx', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                                      const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF338CA8)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sampai Tanggal', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('xx/xx/xxxx', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                                      const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF338CA8)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Card Ringkasan (Total Pendapatan & Jumlah Transaksi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF93C5FD).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Pendapatan', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1B4E6C))),
                                const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF1B4E6C)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('RpXXX.xxx', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1B4E6C))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF93C5FD).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Jumlah Transaksi', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1B4E6C))),
                                const Icon(Icons.receipt_long_outlined, size: 18, color: Color(0xFF1B4E6C)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('X order', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1B4E6C))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Grafik Pendapatan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4E6C).withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('GRAFIK PENDAPATAN', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1B4E6C))),
                          Text('Harian', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Mockup visual grafik garis sederhana
                      SizedBox(
                        height: 130,
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: ['Rp 110k', 'Rp 90k', 'Rp 70k', 'Rp 50k', 'Rp 30k']
                                  .map((val) => Row(
                                children: [
                                  Text(val, style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xFF94A3B8))),
                                  const SizedBox(width: 8),
                                  Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
                                ],
                              ))
                                  .toList(),
                            ),
                            Center(
                              child: Icon(Icons.show_chart_rounded, size: 100, color: const Color(0xFF38BDF8).withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['12 Oct', '13 Oct', '14 Oct', '15 Oct', '16 Oct', '17 Oct']
                            .map((date) => Text(date, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B))))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Daftar Transaksi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DAFTAR TRANSAKSI', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1B4E6C))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('X Transaksi', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTransactionItem(orderId: 'LKN4wa123', name: 'Customer Z', date: 'xx/xx/xxxx', price: 'RpXX.xxx'),
                    const SizedBox(height: 8),
                    _buildTransactionItem(orderId: 'LKN4wa122', name: 'Customer N', date: 'xx/xx/xxxx', price: 'RpXX.xxx'),
                    const SizedBox(height: 8),
                    _buildTransactionItem(orderId: 'LKN4wa121', name: 'Customer A', date: 'xx/xx/xxxx', price: 'RpXX.xxx'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(1, Icons.assignment_outlined, 'Pesanan'),
            _buildNavItem(2, Icons.bar_chart_rounded, 'Laporan'),
            _buildNavItem(3, Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String orderId,
    required String name,
    required String date,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4E6C).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_outlined, color: Color(0xFF0284C7), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(orderId, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1B4E6C))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Lunas', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(name, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF475569))),
                    const SizedBox(width: 6),
                    Text('•', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                    const SizedBox(width: 6),
                    Text(date, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1B4E6C))),
              const SizedBox(height: 2),
              Text(
                'Detail >',
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF0284C7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });

        // Navigasi footer antar halaman
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/admin-home');
        } else if (index == 1) {
          // Tambahkan rute pesanan jika sudah ada nanti
        } else if (index == 2) {
          // Sedang di halaman laporan
        } else if (index == 3) {
          // Tambahkan rute profil jika sudah ada nanti
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
            size: 24,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}