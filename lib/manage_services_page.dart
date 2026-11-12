import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({super.key});

  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  bool _isBannerActive = true;
  final TextEditingController _bannerTextController = TextEditingController(
    text: 'Selamat datang! Saatnya pakaian bersih lagi!',
  );

  // 1. Controller Tarif Utama
  final TextEditingController _kiloanController =
      TextEditingController(text: '3.000');
  final TextEditingController _satuanStartController =
      TextEditingController(text: '15.000');
  final TextEditingController _bedCoverController =
      TextEditingController(text: '25.000');
  final TextEditingController _bonekaController =
      TextEditingController(text: '15.000');

  // 2. Sub-item Tarif Laundry Satuan
  final Map<String, TextEditingController> _satuanItemControllers = {
    'Kaos': TextEditingController(text: '15.000'),
    'Kemeja': TextEditingController(text: '15.000'),
    'Celana Pendek': TextEditingController(text: '15.000'),
    'Celana Panjang': TextEditingController(text: '17.000'),
    'Jeans': TextEditingController(text: '20.000'),
    'Jas': TextEditingController(text: '30.000'),
    'Handuk': TextEditingController(text: '15.000'),
    'Set Seprei': TextEditingController(text: '25.000'),
  };

  // 3. Pengaturan Tambahan Umum
  final TextEditingController _tarifMinKiloanController =
      TextEditingController(text: '20.000');
  final TextEditingController _minBeratKiloanController =
      TextEditingController(text: '7');
  final TextEditingController _expressController =
      TextEditingController(text: '5.000');
  final TextEditingController _setrikaController =
      TextEditingController(text: '5.000');

  // 4. Daftar Varian Deterjen & Pewangi (Tanpa kurung siku agar aman di-copy)
  final List _deterjenList = [
    {'name': 'Rinso Gentle', 'price': '1.000', 'isAvailable': true},
    {'name': 'Attack Higienis', 'price': '1.000', 'isAvailable': true},
    {'name': 'So Klin Bio', 'price': '1.000', 'isAvailable': false},
  ];

  final List _pewangiList = [
    {'name': 'Molto Floral', 'price': '1.000', 'isAvailable': true},
    {'name': 'Downy Mystique', 'price': '1.000', 'isAvailable': true},
    {'name': 'So Klin Pelembut', 'price': '1.000', 'isAvailable': true},
  ];

  bool _isSatuanExpanded = false;

  @override
  void dispose() {
    _bannerTextController.dispose();
    _kiloanController.dispose();
    _satuanStartController.dispose();
    _bedCoverController.dispose();
    _bonekaController.dispose();
    for (final c in _satuanItemControllers.values) {
      c.dispose();
    }
    _tarifMinKiloanController.dispose();
    _minBeratKiloanController.dispose();
    _expressController.dispose();
    _setrikaController.dispose();
    super.dispose();
  }

  // Pop-up Tambah Varian Baru (Deterjen / Pewangi)
  void _showAddVariantDialog({required bool isDeterjen}) {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '1.000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isDeterjen ? 'Tambah Varian Deterjen' : 'Tambah Varian Pewangi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDeterjen
                  ? 'Nama Merk / Varian Deterjen'
                  : 'Nama Merk / Aroma Pewangi',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: isDeterjen
                    ? 'Contoh: Daia Softener'
                    : 'Contoh: Downy Ocean Fresh',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Biaya Tambahan (Rp)',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = priceController.text.trim().isEmpty
                  ? '1.000'
                  : priceController.text.trim();

              if (name.isNotEmpty) {
                setState(() {
                  final newItem = {
                    'name': name,
                    'price': price,
                    'isAvailable': true,
                  };
                  if (isDeterjen) {
                    _deterjenList.add(newItem);
                  } else {
                    _pewangiList.add(newItem);
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF338CA8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Tambah',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B4E6C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Tarif layanan & stok varian berhasil disimpan',
          style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= Top Header =================
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  color: const Color(0xFFD6EFFB),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF1B4E6C),
                              ),
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
                                    'Kelola tarif, stok varian, dan tampilan beranda',
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/admin-notification',
                              );
                            },
                            child: Stack(
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
                          ),
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF4285F4),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 22,
                            ),
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
                      // ================= 2. Atur Tarif Layanan =================
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildServiceRateRow(
                              icon: Icons.shopping_basket_rounded,
                              title: 'Laundry Kiloan',
                              subtitle: 'Tarif dasar per kg',
                              controller: _kiloanController,
                              unit: 'Rp / kg',
                            ),
                            const Divider(height: 22, color: Color(0xFFF1F5F9)),
                            _buildServiceRateRow(
                              icon: Icons.checkroom_rounded,
                              title: 'Laundry Satuan',
                              subtitle: 'Start from (8 jenis item)',
                              controller: _satuanStartController,
                              unit: 'Rp / pcs',
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isSatuanExpanded = !_isSatuanExpanded;
                                  });
                                },
                                icon: Icon(
                                  _isSatuanExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: const Color(0xFF338CA8),
                                ),
                                label: Text(
                                  _isSatuanExpanded
                                      ? 'Sembunyikan Rincian Item Satuan'
                                      : 'Atur Harga per Item Satuan (8)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF338CA8),
                                  ),
                                ),
                              ),
                            ),
                            if (_isSatuanExpanded) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  children: _satuanItemControllers.entries
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF334155),
                                                ),
                                              ),
                                              _buildCompactPriceInput(
                                                controller: entry.value,
                                                unit: 'Rp / pcs',
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                            const Divider(height: 22, color: Color(0xFFF1F5F9)),
                            _buildServiceRateRow(
                              icon: Icons.bed_rounded,
                              title: 'Bed Cover',
                              subtitle: 'Start from per item',
                              controller: _bedCoverController,
                              unit: 'Rp / pcs',
                            ),
                            const Divider(height: 22, color: Color(0xFFF1F5F9)),
                            _buildServiceRateRow(
                              icon: Icons.pets_rounded,
                              title: 'Boneka',
                              subtitle: 'Khusus Cuci Saja',
                              controller: _bonekaController,
                              unit: 'Rp / pcs',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= 3. Varian Deterjen & Pewangi (Stok & Tambah) =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Varian Deterjen & Pewangi',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C),
                            ),
                          ),
                          Text(
                            'Stok & Harga',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Card Pilihan Deterjen
                      _buildVariantCard(
                        title: 'Pilihan Deterjen',
                        icon: Icons.cleaning_services_rounded,
                        items: _deterjenList,
                        onAddPressed: () =>
                            _showAddVariantDialog(isDeterjen: true),
                      ),

                      const SizedBox(height: 14),

                      // Card Pilihan Pewangi
                      _buildVariantCard(
                        title: 'Pilihan Pewangi',
                        icon: Icons.local_florist_rounded,
                        items: _pewangiList,
                        onAddPressed: () =>
                            _showAddVariantDialog(isDeterjen: false),
                      ),

                      const SizedBox(height: 24),

                      // ================= 4. Pengaturan Tambahan =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pengaturan Tambahan',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C),
                            ),
                          ),
                          Text(
                            'Opsi & Tambahan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildAdditionalSettingRow(
                              title: 'Minimum Berat Kiloan',
                              subtitle: 'Batas minimal order kiloan',
                              controller: _minBeratKiloanController,
                              unit: 'Kg',
                            ),
                            const SizedBox(height: 12),
                            _buildAdditionalSettingRow(
                              title: 'Tarif Minimum Kiloan',
                              subtitle:
                                  'Paket minimum (${_minBeratKiloanController.text} kg)',
                              controller: _tarifMinKiloanController,
                              unit: 'Rp',
                            ),
                            const Divider(height: 22, color: Color(0xFFF1F5F9)),
                            _buildAdditionalSettingRow(
                              title: 'Layanan Express (24 Jam)',
                              subtitle: 'Biaya tambahan kilat',
                              controller: _expressController,
                              unit: 'Rp',
                            ),
                            const SizedBox(height: 12),
                            _buildAdditionalSettingRow(
                              title: 'Layanan Cuci + Setrika',
                              subtitle: 'Biaya tambahan setrika',
                              controller: _setrikaController,
                              unit: 'Rp',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ================= Tombol Simpan Perubahan =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Card Kelola Varian Deterjen & Pewangi
  Widget _buildVariantCard({
    required String title,
    required IconData icon,
    required List items,
    required VoidCallback onAddPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFD6EFFB),
                    child: Icon(icon, size: 17, color: const Color(0xFF1B4E6C)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4E6C),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddPressed,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFD6EFFB),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: Color(0xFF1B4E6C),
                ),
                label: Text(
                  'Tambah',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Belum ada varian ditambahkan',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = items[index];
                final bool isReady = item['isAvailable'] == true;

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isReady
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFF94A3B8),
                                    decoration: isReady
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isReady
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isReady ? 'Ready' : 'Habis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isReady
                                        ? const Color(0xFF166534)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '+Rp ${item['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Switch Ready / Habis
                    Switch(
                      value: isReady,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF338CA8),
                      onChanged: (val) {
                        setState(() {
                          items[index]['isAvailable'] = val;
                        });
                      },
                    ),
                    // Tombol Hapus Varian
                    IconButton(
                      onPressed: () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Color(0xFFEF4444),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceRateRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String unit,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFD6EFFB),
          child: Icon(icon, color: const Color(0xFF1B4E6C), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        _buildCompactPriceInput(controller: controller, unit: unit),
        const SizedBox(width: 6),
        const Icon(Icons.edit_rounded, size: 17, color: Color(0xFF1B4E6C)),
      ],
    );
  }

  Widget _buildAdditionalSettingRow({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String unit,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        _buildCompactPriceInput(controller: controller, unit: unit),
      ],
    );
  }

  Widget _buildCompactPriceInput({
    required TextEditingController controller,
    required String unit,
  }) {
    return Container(
      width: 126,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1B4E6C), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
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
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}