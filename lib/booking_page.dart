import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_confirmation_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Nama Layanan yang diterima dari Homepage
  String _selectedService = 'Laundry Kiloan';
  bool _isInit = true;

  // Sub-kategori khusus Satuan
  String _barangSatuan = 'Kaos';
  final List<String> _listBarangSatuan = [
    'Kaos',
    'Kemeja',
    'Celana Pendek',
    'Celana Panjang',
    'Jeans',
    'Jas',
    'Handuk',
    'Set Seprei',
  ];

  // Kecepatan Layanan
  String _kecepatan = 'Reguler';

  // Jenis Pengerjaan
  String _pengerjaan = 'Cuci + Setrika';

  // Deterjen & Pewangi (Diberi nama merk)
  String _deterjen = 'tanpa';
  String _pewangi = 'tanpa';

  // Metode Pengantaran
  String _metode = 'Penjemputan';

  // Alamat Tetap Laundry
  static const String _alamatLaundryOutlet =
      'Jl. Ketintang Baru No. 12, Wonokromo, Surabaya (Depan UNESA Ketintang)';

  // Controllers
  late final TextEditingController _alamatPengantaran;
  final TextEditingController _alamatPenjemputan = TextEditingController();
  final TextEditingController _catatan = TextEditingController();

  DateTime _selectedDate = DateTime(2026, 11, 6);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _alamatPengantaran = TextEditingController(text: _alamatLaundryOutlet);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _selectedService = args;
        // Khusus Boneka, otomatis kunci ke Cuci Saja
        if (_selectedService == 'Boneka') {
          _pengerjaan = 'Cuci saja';
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _alamatPengantaran.dispose();
    _alamatPenjemputan.dispose();
    _catatan.dispose();
    super.dispose();
  }

  bool get _isAntarSendiri => _metode == 'Antar Sendiri';
  bool get _isBoneka => _selectedService == 'Boneka';
  bool get _isSatuan => _selectedService == 'Laundry Satuan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6EFFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4E6C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= Banner Layanan Yang Dipilih dari Homepage =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F6FC), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF338CA8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4E6C).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF338CA8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isBoneka
                          ? Icons.smart_toy_outlined
                          : _isSatuan
                          ? Icons.checkroom_rounded
                          : _selectedService == 'Bed Cover'
                          ? Icons.bed_rounded
                          : Icons.scale_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Layanan yang Dipilih:',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _selectedService,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= Sub-Kategori Satuan (Hanya Tampil Jika Satuan) =================
            if (_isSatuan) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Pilih Jenis Pakaian Satuan', 'Pilih item yang ingin dicuci'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF338CA8)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _listBarangSatuan.map((item) {
                    final isPicked = _barangSatuan == item;
                    return ChoiceChip(
                      label: Text(item),
                      selected: isPicked,
                      selectedColor: const Color(0xFF338CA8),
                      backgroundColor: const Color(0xFFF0F7FA),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isPicked ? FontWeight.w600 : FontWeight.w400,
                        color: isPicked ? Colors.white : const Color(0xFF28546A),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _barangSatuan = item);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ================= 1. Kecepatan Layanan =================
            _buildSectionHeader('Kecepatan Pengerjaan', 'Pilih durasi pengerjaan'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSelectCard(
                    title: 'Reguler',
                    tagText: 'Standar (2-3 Hari)',
                    desc: 'Tarif normal hemat',
                    isSelected: _kecepatan == 'Reguler',
                    onTap: () => setState(() => _kecepatan = 'Reguler'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSelectCard(
                    title: 'Express',
                    tagText: 'Kilat (24 Jam)',
                    desc: '+Rp5.000',
                    isSelected: _kecepatan == 'Express',
                    onTap: () => setState(() => _kecepatan = 'Express'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= 2. Jenis Pengerjaan =================
            _buildSectionHeader(
              'Jenis Pengerjaan',
              _isBoneka ? 'Cuci Saja untuk Boneka' : 'Pilih perlakuan cucian',
            ),
            const SizedBox(height: 10),

            // Khusus Boneka: Kunci ke Cuci Saja + Alert Box Oranye
            if (_isBoneka) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Untuk item boneka, hanya berlaku "Cuci saja" demi menjaga tekstur bulu dan busa (tidak dapat disetrika).',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Selain Boneka (Kiloan, Satuan, Bed Cover): Tetap normal bisa pilih keduanya
              Row(
                children: [
                  Expanded(
                    child: _buildSelectCard(
                      title: 'Cuci Saja',
                      tagText: 'Kering Bersih',
                      desc: 'Tanpa setrika',
                      isSelected: _pengerjaan == 'Cuci saja',
                      onTap: () => setState(() => _pengerjaan = 'Cuci saja'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSelectCard(
                      title: 'Cuci + Setrika',
                      tagText: 'Rapi & Wangi',
                      desc: '+Rp5.000',
                      isSelected: _pengerjaan == 'Cuci + Setrika',
                      onTap: () => setState(() => _pengerjaan = 'Cuci + Setrika'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ================= 3. Deterjen & Pewangi =================
            _buildSectionHeader('Deterjen & Pewangi Khusus', 'Pilih merk atau gunakan bawaan'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6EFFB)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF28546A).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deterjen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilihan Deterjen',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRadioItem(
                          label: 'Rinso Gentle',
                          badge: '+Rp1rb',
                          value: 'Rinso Gentle',
                          groupValue: _deterjen,
                          onChanged: (val) => setState(() => _deterjen = val!),
                        ),
                        _buildRadioItem(
                          label: 'Attack Higienis',
                          badge: '+Rp1rb',
                          value: 'Attack Higienis',
                          groupValue: _deterjen,
                          onChanged: (val) => setState(() => _deterjen = val!),
                        ),
                        _buildRadioItem(
                          label: 'So Klin Bio',
                          badge: '+Rp1rb',
                          value: 'So Klin Bio',
                          groupValue: _deterjen,
                          onChanged: (val) => setState(() => _deterjen = val!),
                        ),
                        _buildRadioItem(
                          label: 'Standar / Bawa Sendiri',
                          value: 'tanpa',
                          groupValue: _deterjen,
                          onChanged: (val) => setState(() => _deterjen = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Pewangi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilihan Pewangi',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildRadioItem(
                          label: 'Molto Floral',
                          badge: '+Rp1rb',
                          value: 'Molto Floral',
                          groupValue: _pewangi,
                          onChanged: (val) => setState(() => _pewangi = val!),
                        ),
                        _buildRadioItem(
                          label: 'Downy Mystique',
                          badge: '+Rp1rb',
                          value: 'Downy Mystique',
                          groupValue: _pewangi,
                          onChanged: (val) => setState(() => _pewangi = val!),
                        ),
                        _buildRadioItem(
                          label: 'So Klin Pelembut',
                          badge: '+Rp1rb',
                          value: 'So Klin Pelembut',
                          groupValue: _pewangi,
                          onChanged: (val) => setState(() => _pewangi = val!),
                        ),
                        _buildRadioItem(
                          label: 'Standar / Bawa Sendiri',
                          value: 'tanpa',
                          groupValue: _pewangi,
                          onChanged: (val) => setState(() => _pewangi = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= 4. Metode Pengantaran =================
            _buildSectionHeader('Metode Pengiriman', 'Pilih cara serah terima cucian'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDeliveryCard(
                    icon: Icons.storefront_rounded,
                    title: 'Antar Sendiri',
                    subtitle: 'Bawa ke outlet',
                    isSelected: _isAntarSendiri,
                    onTap: () => setState(() => _metode = 'Antar Sendiri'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDeliveryCard(
                    icon: Icons.two_wheeler_rounded,
                    title: 'Penjemputan',
                    subtitle: 'Kurir jemput ke rumah',
                    isSelected: !_isAntarSendiri,
                    onTap: () => setState(() => _metode = 'Penjemputan'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= 5. Jadwal Penjemputan =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Jadwal Penjemputan', 'Tentukan jadwal kurir tiba'),
                if (_isAntarSendiri)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nonaktif',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: _isAntarSendiri ? 0.45 : 1.0,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isAntarSendiri
                          ? null
                          : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2026),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: _buildPickerBox(
                        icon: Icons.calendar_today_rounded,
                        label: 'Tanggal Jemput',
                        text: _tanggalText,
                        isDisabled: _isAntarSendiri,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isAntarSendiri
                          ? null
                          : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                      child: _buildPickerBox(
                        icon: Icons.access_time_rounded,
                        label: 'Jam Jemput',
                        text: _jamText,
                        isDisabled: _isAntarSendiri,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= 6. Alamat Laundry =================
            _buildSectionHeader('Alamat Outlet Laundry (Tujuan Pengantaran)', 'Lokasi cucian diproses'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.store, color: Color(0xFF1B4E6C), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outlet Utama Mobile Laundry',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _alamatLaundryOutlet,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Alamat Penjemputan jika Penjemputan dipilih
            if (!_isAntarSendiri) ...[
              const SizedBox(height: 18),
              _buildSectionHeader('Alamat Penjemputan Anda', 'Kurir akan mengambil cucian di sini'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF338CA8)),
                ),
                child: TextField(
                  controller: _alamatPenjemputan,
                  style: GoogleFonts.poppins(fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat lengkap & patokan rumah...',
                    prefixIcon: Icon(Icons.home_work_outlined, color: Color(0xFF338CA8), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ================= 7. Catatan =================
            _buildSectionHeader('Catatan Khusus', '(Opsional) Berikan instruksi tambahan'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _catatan,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Contoh: Pakaian putih dipisah / jahitan boneka rapuh.',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Lanjutkan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goToConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF338CA8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lanjutkan ke Konfirmasi',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Perhitungan & Konfirmasi ---

  static const int _tarifMinimumKiloan = 20000;
  static const int _biayaExpress = 5000;
  static const int _biayaSetrika = 5000;
  static const int _biayaDeterjen = 1000;
  static const int _biayaPewangi = 1000;

  static const List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  String get _tanggalText =>
      '${_selectedDate.day} ${_namaBulan[_selectedDate.month - 1]} ${_selectedDate.year}';

  String get _jamText =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB';

  String _rupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp$buf';
  }

  void _goToConfirmation() {
    if (!_isAntarSendiri && _alamatPenjemputan.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Mohon isi alamat penjemputan terlebih dahulu!',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
      return;
    }

    final biaya = <CostItem>[];
    var subtotal = 0;

    void tambah(String label, int nilai) {
      biaya.add(CostItem(label, _rupiah(nilai)));
      subtotal += nilai;
    }

    String labelLayanan = _selectedService;
    if (_selectedService == 'Laundry Kiloan') {
      tambah('Tarif minimum kiloan (7kg)', _tarifMinimumKiloan);
    } else if (_isSatuan) {
      labelLayanan = 'Satuan: $_barangSatuan';
      biaya.add(CostItem('Satuan ($_barangSatuan)', 'Dihitung admin'));
    } else {
      biaya.add(CostItem(_selectedService, 'Dihitung admin'));
    }

    if (_kecepatan == 'Express') tambah('Layanan Express', _biayaExpress);
    if (_pengerjaan == 'Cuci + Setrika') tambah('Layanan Cuci + Setrika', _biayaSetrika);
    if (_deterjen != 'tanpa') tambah('Deterjen ($_deterjen)', _biayaDeterjen);
    if (_pewangi != 'tanpa') tambah('Pewangi ($_pewangi)', _biayaPewangi);

    final finalAlamat = _isAntarSendiri
        ? 'Antar ke outlet: $_alamatLaundryOutlet'
        : _alamatPenjemputan.text.trim();

    final finalJadwal = _isAntarSendiri
        ? 'Pelanggan antar langsung ke outlet'
        : '$_tanggalText, $_jamText';

    Navigator.pushNamed(
      context,
      '/order-confirmation',
      arguments: OrderSummary(
        jenisLaundry: labelLayanan,
        kecepatan: _kecepatan,
        pengerjaan: _pengerjaan,
        deterjen: _deterjen == 'tanpa' ? 'Standar / Bawa Sendiri' : _deterjen,
        pewangi: _pewangi == 'tanpa' ? 'Standar / Bawa Sendiri' : _pewangi,
        metode: _metode,
        jadwal: finalJadwal,
        alamat: finalAlamat,
        biaya: biaya,
        subtotal: _selectedService == 'Laundry Kiloan' ? _rupiah(subtotal) : 'Menunggu Review Admin',
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectCard({
    required String title,
    required String tagText,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F6FC) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF338CA8) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E6C),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? const Color(0xFF338CA8) : const Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD6EFFB),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tagText,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioItem({
    required String label,
    String? badge,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF338CA8) : const Color(0xFF94A3B8),
              size: 17,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: isSelected ? const Color(0xFF1B4E6C) : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F6FC) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF338CA8) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF338CA8) : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4E6C),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF338CA8) : const Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBox({
    required IconData icon,
    required String label,
    required String text,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDisabled ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDisabled ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                color: isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF338CA8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}