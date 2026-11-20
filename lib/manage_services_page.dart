import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({super.key});

  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;

  // ID baris dari tabel 'services' untuk keperluan UPDATE
  String? _kiloanId;
  String? _satuanId;
  String? _bedCoverId;
  String? _bonekaId;

  // 1. Controller Tarif Utama
  final TextEditingController _kiloanController =
  TextEditingController(text: '3.000');
  final TextEditingController _satuanStartController =
  TextEditingController(text: '15.000');
  final TextEditingController _bedCoverController =
  TextEditingController(text: '25.000');
  final TextEditingController _bonekaController =
  TextEditingController(text: '15.000');

  // 2. Sub-item Tarif Laundry Satuan (dari tabel 'satuan_items')
  List _satuanItems = [];

  // 3. Pengaturan Tambahan Umum
  final TextEditingController _tarifMinKiloanController =
  TextEditingController(text: '20.000');
  final TextEditingController _minBeratKiloanController =
  TextEditingController(text: '7');
  final TextEditingController _expressController =
  TextEditingController(text: '5.000');
  final TextEditingController _setrikaController =
  TextEditingController(text: '5.000');

  // 4. Daftar Varian Deterjen & Pewangi (dari tabel 'addons')
  List _deterjenList = [];
  List _pewangiList = [];

  bool _isSatuanExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Format angka integer ke teks bertitik (misal 15000 -> 15.000)
  String _formatThousands(dynamic value) {
    final int numVal = int.tryParse(value.toString()) ?? 0;
    return numVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
  }

  // Ubah teks bertitik kembali ke integer database (misal '15.000' -> 15000)
  int _parsePriceToInt(String formatted, {int fallback = 0}) {
    final digitsOnly = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? fallback;
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _supabase.from('services').select('id, name, price'),
        _supabase
            .from('satuan_items')
            .select('id, name, price')
            .order('name', ascending: true),
        _supabase
            .from('addons')
            .select('id, category, name, price, is_available')
            .order('name', ascending: true),
      ]);

      if (!mounted) return;

      // 1. Mapping Services
      final servicesData = List.from(results[0]);
      for (final row in servicesData) {
        final name = (row['name'] ?? '').toString().toLowerCase();
        final id = row['id'].toString();
        final formattedPrice = _formatThousands(row['price']);

        if (name.contains('kiloan')) {
          _kiloanId = id;
          _kiloanController.text = formattedPrice;
        } else if (name.contains('satuan')) {
          _satuanId = id;
          _satuanStartController.text = formattedPrice;
        } else if (name.contains('bed cover') || name.contains('bedcover')) {
          _bedCoverId = id;
          _bedCoverController.text = formattedPrice;
        } else if (name.contains('boneka')) {
          _bonekaId = id;
          _bonekaController.text = formattedPrice;
        }
      }

      // 2. Mapping Satuan Items
      final satuanData = List.from(results[1]).map((row) {
        return {
          'id': row['id'].toString(),
          'name': (row['name'] ?? '').toString(),
          'price': _formatThousands(row['price']),
        };
      }).toList();

      // 3. Mapping Addons (Deterjen & Pewangi)
      final addonsData = List.from(results[2]);
      final List deterjen = [];
      final List pewangi = [];

      for (final row in addonsData) {
        final category = (row['category'] ?? '').toString().toLowerCase();
        final mappedItem = {
          'id': row['id'].toString(),
          'name': (row['name'] ?? '').toString(),
          'price': _formatThousands(row['price']),
          'isAvailable': row['is_available'] == true,
        };
        if (category == 'deterjen') {
          deterjen.add(mappedItem);
        } else if (category == 'pewangi') {
          pewangi.add(mappedItem);
        }
      }

      setState(() {
        _satuanItems = satuanData;
        _deterjenList = deterjen;
        _pewangiList = pewangi;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data layanan: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        isError ? const Color(0xFFEF4444) : const Color(0xFF1B4E6C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _kiloanController.dispose();
    _satuanStartController.dispose();
    _bedCoverController.dispose();
    _bonekaController.dispose();
    _tarifMinKiloanController.dispose();
    _minBeratKiloanController.dispose();
    _expressController.dispose();
    _setrikaController.dispose();
    super.dispose();
  }

  // ==================== DIALOG KONFIRMASI HAPUS ====================
  void _confirmDelete({
    required String itemName,
    required String categoryLabel,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Konfirmasi Hapus',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4E6C),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$itemName" dari daftar $categoryLabel?',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: const Color(0xFF475569),
          ),
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
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Ya, Hapus',
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

  // ==================== DIALOG TAMBAH & EDIT ITEM SATUAN ====================
  void _showSatuanItemDialog({int? editIndex}) {
    final bool isEdit = editIndex != null;
    final nameController = TextEditingController(
      text: isEdit ? _satuanItems[editIndex]['name'] : '',
    );
    final priceController = TextEditingController(
      text: isEdit ? _satuanItems[editIndex]['price'] : '20.000',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? 'Edit Item Satuan' : 'Tambah Item Satuan',
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
              'Nama Jenis Pakaian',
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
                hintText: 'Contoh: Hoodie / Jaket',
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
              'Tarif Mulai Dari (Rp / pcs)',
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final int priceInt =
              _parsePriceToInt(priceController.text, fallback: 15000);
              final formattedPrice = _formatThousands(priceInt);

              if (name.isEmpty) return;
              Navigator.pop(dialogContext);

              try {
                if (isEdit) {
                  final id = _satuanItems[editIndex]['id'];
                  await _supabase.from('satuan_items').update({
                    'name': name,
                    'price': priceInt,
                  }).eq('id', id);

                  if (!mounted) return;
                  setState(() {
                    _satuanItems[editIndex]['name'] = name;
                    _satuanItems[editIndex]['price'] = formattedPrice;
                  });
                  _showSnackBar('Item "$name" berhasil diperbarui');
                } else {
                  final inserted = await _supabase
                      .from('satuan_items')
                      .insert({
                    'name': name,
                    'price': priceInt,
                  })
                      .select()
                      .single();

                  if (!mounted) return;
                  setState(() {
                    _satuanItems.add({
                      'id': inserted['id'].toString(),
                      'name': name,
                      'price': formattedPrice,
                    });
                  });
                  _showSnackBar('Item "$name" berhasil ditambahkan');
                }
              } catch (e) {
                _showSnackBar('Gagal menyimpan item satuan: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF338CA8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEdit ? 'Simpan' : 'Tambah',
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

  // ==================== DIALOG TAMBAH & EDIT DETERJEN / PEWANGI ====================
  void _showVariantDialog({
    required bool isDeterjen,
    int? editIndex,
  }) {
    final bool isEdit = editIndex != null;
    final targetList = isDeterjen ? _deterjenList : _pewangiList;
    final String categoryValue = isDeterjen ? 'deterjen' : 'pewangi';

    final nameController = TextEditingController(
      text: isEdit ? targetList[editIndex]['name'] : '',
    );
    final priceController = TextEditingController(
      text: isEdit ? targetList[editIndex]['price'] : '1.000',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit
              ? (isDeterjen ? 'Edit Varian Deterjen' : 'Edit Varian Pewangi')
              : (isDeterjen
              ? 'Tambah Varian Deterjen'
              : 'Tambah Varian Pewangi'),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final int priceInt =
              _parsePriceToInt(priceController.text, fallback: 1000);
              final formattedPrice = _formatThousands(priceInt);

              if (name.isEmpty) return;
              Navigator.pop(dialogContext);

              try {
                if (isEdit) {
                  final id = targetList[editIndex]['id'];
                  await _supabase.from('addons').update({
                    'name': name,
                    'price': priceInt,
                  }).eq('id', id);

                  if (!mounted) return;
                  setState(() {
                    targetList[editIndex]['name'] = name;
                    targetList[editIndex]['price'] = formattedPrice;
                  });
                  _showSnackBar('Varian "$name" berhasil diperbarui');
                } else {
                  final inserted = await _supabase
                      .from('addons')
                      .insert({
                    'category': categoryValue,
                    'name': name,
                    'price': priceInt,
                    'is_available': true,
                  })
                      .select()
                      .single();

                  if (!mounted) return;
                  setState(() {
                    targetList.add({
                      'id': inserted['id'].toString(),
                      'name': name,
                      'price': formattedPrice,
                      'isAvailable': true,
                    });
                  });
                  _showSnackBar('Varian "$name" berhasil ditambahkan');
                }
              } catch (e) {
                _showSnackBar('Gagal menyimpan varian: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF338CA8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEdit ? 'Simpan' : 'Tambah',
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

  // Simpan pembaruan tarif utama layanan ke tabel 'services'
  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final List updates = [];

      if (_kiloanId != null) {
        updates.add(_supabase.from('services').update({
          'price': _parsePriceToInt(_kiloanController.text, fallback: 3000),
        }).eq('id', _kiloanId!));
      }

      if (_satuanId != null) {
        updates.add(_supabase.from('services').update({
          'price':
          _parsePriceToInt(_satuanStartController.text, fallback: 15000),
        }).eq('id', _satuanId!));
      }

      if (_bedCoverId != null) {
        updates.add(_supabase.from('services').update({
          'price': _parsePriceToInt(_bedCoverController.text, fallback: 25000),
        }).eq('id', _bedCoverId!));
      }

      if (_bonekaId != null) {
        updates.add(_supabase.from('services').update({
          'price': _parsePriceToInt(_bonekaController.text, fallback: 15000),
        }).eq('id', _bonekaId!));
      }

      if (updates.isNotEmpty) {
        await Future.wait(updates.cast<Future>());
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('Tarif layanan & stok varian berhasil disimpan');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('Gagal menyimpan perubahan tarif: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int jumlahItemSatuan = _satuanItems.length;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            color: const Color(0xFF338CA8),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                                      'Kelola tarif, stok varian, dan jenis layanan',
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

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF338CA8),
                        ),
                      ),
                    )
                  else
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
                                const Divider(
                                    height: 22, color: Color(0xFFF1F5F9)),
                                _buildServiceRateRow(
                                  icon: Icons.checkroom_rounded,
                                  title: 'Laundry Satuan',
                                  subtitle:
                                  'Start from ($jumlahItemSatuan jenis item)',
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
                                          : 'Kelola Item Satuan ($jumlahItemSatuan)',
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
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Daftar Pakaian Satuan',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1B4E6C),
                                              ),
                                            ),
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _showSatuanItemDialog(),
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                const Color(0xFFD6EFFB),
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(16),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.add_rounded,
                                                size: 15,
                                                color: Color(0xFF1B4E6C),
                                              ),
                                              label: Text(
                                                'Tambah Item',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                  const Color(0xFF1B4E6C),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          height: 16,
                                          color: Color(0xFFE2E8F0),
                                        ),
                                        if (_satuanItems.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              'Belum ada item pakaian satuan',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                color: const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          )
                                        else
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            itemCount: _satuanItems.length,
                                            separatorBuilder: (_, __) =>
                                            const Divider(
                                              height: 14,
                                              color: Color(0xFFE2E8F0),
                                            ),
                                            itemBuilder: (context, index) {
                                              final item = _satuanItems[index];
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          item['name'],
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 12.5,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                            color: const Color(
                                                                0xFF1E293B),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Mulai Rp ${item['price']} / pcs',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 10.5,
                                                            color: const Color(
                                                                0xFF64748B),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Tombol Edit Nama & Harga
                                                  IconButton(
                                                    onPressed: () =>
                                                        _showSatuanItemDialog(
                                                          editIndex: index,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 19,
                                                      color: Color(0xFF338CA8),
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                    const BoxConstraints(),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Tombol Hapus dari Supabase
                                                  IconButton(
                                                    onPressed: () =>
                                                        _confirmDelete(
                                                          itemName: item['name'],
                                                          categoryLabel:
                                                          'Pakaian Satuan',
                                                          onConfirm: () async {
                                                            try {
                                                              await _supabase
                                                                  .from(
                                                                  'satuan_items')
                                                                  .delete()
                                                                  .eq('id',
                                                                  item['id']);

                                                              if (!mounted) return;
                                                              setState(() {
                                                                _satuanItems
                                                                    .removeAt(
                                                                    index);
                                                              });
                                                              _showSnackBar(
                                                                  '"${item['name']}" berhasil dihapus');
                                                            } catch (e) {
                                                              _showSnackBar(
                                                                  'Gagal menghapus: $e',
                                                                  isError: true);
                                                            }
                                                          },
                                                        ),
                                                    icon: const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      size: 19,
                                                      color: Color(0xFFEF4444),
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                    const BoxConstraints(),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                                const Divider(
                                    height: 22, color: Color(0xFFF1F5F9)),
                                _buildServiceRateRow(
                                  icon: Icons.bed_rounded,
                                  title: 'Bed Cover',
                                  subtitle: 'Start from per item',
                                  controller: _bedCoverController,
                                  unit: 'Rp / pcs',
                                ),
                                const Divider(
                                    height: 22, color: Color(0xFFF1F5F9)),
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

                          // ================= 3. Varian Deterjen & Pewangi (CRUD + Stok) =================
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
                                'Edit, Stok & Hapus',
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
                            categoryLabel: 'Varian Deterjen',
                            icon: Icons.cleaning_services_rounded,
                            items: _deterjenList,
                            onAddPressed: () =>
                                _showVariantDialog(isDeterjen: true),
                            onEditPressed: (index) => _showVariantDialog(
                              isDeterjen: true,
                              editIndex: index,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Card Pilihan Pewangi
                          _buildVariantCard(
                            title: 'Pilihan Pewangi',
                            categoryLabel: 'Varian Pewangi',
                            icon: Icons.local_florist_rounded,
                            items: _pewangiList,
                            onAddPressed: () =>
                                _showVariantDialog(isDeterjen: false),
                            onEditPressed: (index) => _showVariantDialog(
                              isDeterjen: false,
                              editIndex: index,
                            ),
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
                                const Divider(
                                    height: 22, color: Color(0xFFF1F5F9)),
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
                              onPressed: _isSaving ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38BDF8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Text(
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
      ),
    );
  }

  // Widget Card Kelola Varian Deterjen & Pewangi (Full CRUD + Update Stok ke Supabase)
  Widget _buildVariantCard({
    required String title,
    required String categoryLabel,
    required IconData icon,
    required List items,
    required VoidCallback onAddPressed,
    required Function(int) onEditPressed,
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
                    // Switch Ready / Habis (Langsung update ke Supabase)
                    Switch(
                      value: isReady,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF338CA8),
                      onChanged: (val) async {
                        final previousVal = items[index]['isAvailable'];
                        setState(() {
                          items[index]['isAvailable'] = val;
                        });
                        try {
                          await _supabase
                              .from('addons')
                              .update({'is_available': val})
                              .eq('id', item['id']);
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            items[index]['isAvailable'] = previousVal;
                          });
                          _showSnackBar('Gagal memperbarui status stok: $e',
                              isError: true);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    // Tombol Edit Nama & Harga Varian
                    IconButton(
                      onPressed: () => onEditPressed(index),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                        color: Color(0xFF338CA8),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    // Tombol Hapus Varian dari Supabase
                    IconButton(
                      onPressed: () => _confirmDelete(
                        itemName: item['name'],
                        categoryLabel: categoryLabel,
                        onConfirm: () async {
                          try {
                            await _supabase
                                .from('addons')
                                .delete()
                                .eq('id', item['id']);

                            if (!mounted) return;
                            setState(() {
                              items.removeAt(index);
                            });
                            _showSnackBar('"${item['name']}" berhasil dihapus');
                          } catch (e) {
                            _showSnackBar('Gagal menghapus varian: $e',
                                isError: true);
                          }
                        },
                      ),
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
      width: 118,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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