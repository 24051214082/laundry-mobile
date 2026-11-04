import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({super.key});

  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  bool _isBannerActive = true;

  // Controllers tarif layanan
  final TextEditingController _bannerTextController = TextEditingController(
    text: 'Selamat datang! saatnya pakaian bersih lagi!',
  );
  final TextEditingController _kiloanPriceController = TextEditingController(text: '7.000');
  final TextEditingController _satuanPriceController = TextEditingController(text: '15.000');
  final TextEditingController _bedCoverPriceController = TextEditingController(text: '25.000');
  final TextEditingController _bonekaPriceController = TextEditingController(text: '15.000');
  final TextEditingController _pewangiPriceController = TextEditingController(text: '1.000');
  final TextEditingController _minWeightController = TextEditingController(text: '2');

  @override
  void dispose() {
    _bannerTextController.dispose();
    _kiloanPriceController.dispose();
    _satuanPriceController.dispose();
    _bedCoverPriceController.dispose();
    _bonekaPriceController.dispose();
    _pewangiPriceController.dispose();
    _minWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header (Versi Perbaikan Overflow)
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              color: const Color(0xFFD6EFFB),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pembungkus Expanded agar teks judul mengalah pada sisa lebar layar
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4E6C)),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Halo,',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: const Color(0xFF1B4E6C),
                                                ),
                                              ),
                                              Text(
                                                'Kelola Layanan',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF1B4E6C),
                                                ),
                                              ),
                                              Text(
                                                'Kelola tarif dan tampilan aplikasi pelanggan',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: const Color(0xFF2E637E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Bagian Ikon Kanan
                                  Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.notifications_none_rounded,
                                              color: Color(0xFF1B4E6C),
                                              size: 22,
                                            ),
                                          ),
                                          Positioned(
                                            top: 2,
                                            right: 2,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Color(0xFF4285F4),
                                        child: Icon(Icons.person, color: Colors.white, size: 22),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Section Banner Promo
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Banner Promo & Beranda',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B4E6C),
                                ),
                              ),
                              Switch(
                                value: _isBannerActive,
                                activeColor: const Color(0xFF38BDF8),
                                onChanged: (val) => setState(() => _isBannerActive = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFF1B4E6C)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: TextField(
                                        controller: _bannerTextController,
                                        maxLines: 2,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: const Color(0xFF1B4E6C),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF1B4E6C)),
                                      label: Text(
                                        'Unggah gambar banner',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1B4E6C),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD6EFFB),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6EFFB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_laundry_service,
                                  size: 50,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Section Atur Tarif Layanan
                    Text(
                      'Atur Tarif Layanan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4E6C),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildServiceItem(
                            icon: Icons.shopping_basket_rounded,
                            title: 'Laundry Kiloan',
                            controller: _kiloanPriceController,
                            unit: 'Rp / kg',
                          ),
                          const SizedBox(height: 12),
                          _buildServiceItem(
                            icon: Icons.checkroom_rounded,
                            title: 'Laundry Satuan',
                            controller: _satuanPriceController,
                            unit: 'Rp / kg',
                          ),
                          const SizedBox(height: 12),
                          _buildServiceItem(
                            icon: Icons.bed_rounded,
                            title: 'Bed Cover',
                            controller: _bedCoverPriceController,
                            unit: 'Rp / kg',
                          ),
                          const SizedBox(height: 12),
                          _buildServiceItem(
                            icon: Icons.pets_rounded,
                            title: 'Boneka',
                            controller: _bonekaPriceController,
                            unit: 'Rp / kg',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Section Penganturan Tambahan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Penganturan Tambahan',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        Text(
                          'Opsi & Tambahan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildOptionRow(
                            title: 'Tambah Pewangi A, B, C',
                            controller: _pewangiPriceController,
                            unit: 'Rp',
                          ),
                          const SizedBox(height: 10),
                          _buildOptionRow(
                            title: 'Minimum Berat Kiloan',
                            controller: _minWeightController,
                            unit: 'Kg',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Tombol Simpan Perubahan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF70C5FF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String unit,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFD6EFFB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: const Color(0xFF1B4E6C), size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4E6C),
            ),
          ),
        ),
        Container(
          width: 130,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1B4E6C)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.edit, size: 18, color: Color(0xFF1B4E6C)),
      ],
    );
  }

  Widget _buildOptionRow({
    required String title,
    required TextEditingController controller,
    required String unit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
        Container(
          width: 110,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1B4E6C)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}