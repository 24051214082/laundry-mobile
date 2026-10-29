import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Pilihan Jenis Laundry
  String _jenisLaundry = 'Kiloan';

  // Kecepatan Layanan
  String _kecepatan = 'Express';

  // Jenis Pengerjaan
  String _pengerjaan = 'Cuci + Setrika';

  // Deterjen & Pewangi
  String _deterjen = 'tanpa';
  String _pewangi = 'tanpa';

  // Metode Pengantaran
  String _metode = 'Penjemputan';

  // Controllers Alamat & Catatan
  final TextEditingController _alamatPengantaran = TextEditingController();
  final TextEditingController _alamatPenjemputan = TextEditingController();
  final TextEditingController _catatan = TextEditingController();

  DateTime _selectedDate = DateTime(2026, 10, 22);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _alamatPengantaran.dispose();
    _alamatPenjemputan.dispose();
    _catatan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6EFFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4E6C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Jenis Laundry
            _buildSectionTitle('Jenis Laundry'),
            const SizedBox(height: 8),
            _buildLaundryTypeCard(
              title: 'Kiloan',
              subtitle: 'Mulai Rp20.000',
              note: 'Berat di bawah 7kg tetap dikenakan tarif minimum Rp20.000, di atas 7kg dikenakan tambahan Rp3.000/kg',
              icon: Icons.scale_outlined,
              isSelected: _jenisLaundry == 'Kiloan',
              onTap: () => setState(() => _jenisLaundry = 'Kiloan'),
            ),
            const SizedBox(height: 10),
            _buildLaundryTypeCard(
              title: 'Satuan',
              subtitle: 'Harga per Barang',
              note: 'Admin memastikan jenis dan jumlah barang sebelum tagihan final dibuat.',
              icon: Icons.checkroom_outlined,
              isSelected: _jenisLaundry == 'Satuan',
              onTap: () => setState(() => _jenisLaundry = 'Satuan'),
            ),

            const SizedBox(height: 20),

            // 2. Kecepatan Layanan
            _buildSectionTitle('Kecepatan Layanan'),
            const SizedBox(height: 8),
            _buildOptionTile(
              title: 'Reguler',
              tagText: 'tarif normal',
              desc: 'Waktu pengerjaan standar',
              isSelected: _kecepatan == 'Reguler',
              onTap: () => setState(() => _kecepatan = 'Reguler'),
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              title: 'Express',
              tagText: 'tarif tambahan',
              desc: 'Pengerjaan lebih cepat',
              isSelected: _kecepatan == 'Express',
              onTap: () => setState(() => _kecepatan = 'Express'),
            ),

            const SizedBox(height: 20),

            // 3. Jenis Pengerjaan
            _buildSectionTitle('Jenis Pengerjaan'),
            const SizedBox(height: 8),
            _buildOptionTile(
              title: 'Cuci saja',
              tagText: 'tarif normal',
              desc: 'Cuci kering tanpa setrika',
              isSelected: _pengerjaan == 'Cuci saja',
              onTap: () => setState(() => _pengerjaan = 'Cuci saja'),
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              title: 'Cuci + Setrika',
              tagText: 'tarif tambahan',
              desc: 'Cuci dengan setrika',
              isSelected: _pengerjaan == 'Cuci + Setrika',
              onTap: () => setState(() => _pengerjaan = 'Cuci + Setrika'),
            ),

            const SizedBox(height: 20),

            // 4. Deterjen dan Pewangi
            _buildSectionTitle('Deterjen dan Pewangi'),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Deterjen
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRadioProduct(
                        label: 'Deterjen A',
                        badge: 'Rp1.000',
                        value: 'Deterjen A',
                        groupValue: _deterjen,
                        onChanged: (val) => setState(() => _deterjen = val!),
                      ),
                      _buildRadioProduct(
                        label: 'Deterjen B',
                        badge: 'Rp1.000',
                        value: 'Deterjen B',
                        groupValue: _deterjen,
                        onChanged: (val) => setState(() => _deterjen = val!),
                      ),
                      _buildRadioProduct(
                        label: 'Deterjen C',
                        badge: 'Rp1.000',
                        value: 'Deterjen C',
                        groupValue: _deterjen,
                        onChanged: (val) => setState(() => _deterjen = val!),
                      ),
                      _buildRadioProduct(
                        label: 'Deterjen sendiri /\ntanpa deterjen',
                        value: 'tanpa',
                        groupValue: _deterjen,
                        onChanged: (val) => setState(() => _deterjen = val!),
                      ),
                    ],
                  ),
                ),
                // Kolom Pewangi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRadioProduct(
                        label: 'Pewangi A',
                        badge: 'Rp1.000',
                        value: 'Pewangi A',
                        groupValue: _pewangi,
                        onChanged: (val) => setState(() => _pewangi = val!),
                      ),
                      _buildRadioProduct(
                        label: 'Pewangi B',
                        badge: 'Rp1.000',
                        value: 'Pewangi B',
                        groupValue: _pewangi,
                        onChanged: (val) => setState(() => _pewangi = val!),
                      ),
                      _buildRadioProduct(
                        label: 'Pewangi C',
                        badge: 'Rp1.000',
                        value: 'Pewangi C',
                        groupValue: _pewangi,
                        onChanged: (val) => setState(() => _pewangi = val!),
                      ),
                      _buildRadioProduct(
                        label: 'Pewangi sendiri /\ntanpa pewangi',
                        value: 'tanpa',
                        groupValue: _pewangi,
                        onChanged: (val) => setState(() => _pewangi = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 5. Metode Pengantaran
            _buildSectionTitle('Metode Pengantaran'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDeliveryCard(
                    icon: Icons.storefront_rounded,
                    title: 'Antar Sendiri',
                    isSelected: _metode == 'Antar Sendiri',
                    onTap: () => setState(() => _metode = 'Antar Sendiri'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDeliveryCard(
                    icon: Icons.delivery_dining_rounded,
                    title: 'Penjemputan',
                    isSelected: _metode == 'Penjemputan',
                    onTap: () => setState(() => _metode = 'Penjemputan'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 6. Jadwal Penjemputan
            _buildSectionTitle('Jadwal Penjemputan'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2026),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: _buildPickerBox(
                      icon: Icons.calendar_today_outlined,
                      text: '${_selectedDate.day} Oktober ${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                    child: _buildPickerBox(
                      icon: Icons.access_time_rounded,
                      text: '${_selectedTime.hour.toString().padLeft(2, '0')}.${_selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 7. Alamat Pengantaran & Penjemputan
            _buildSectionTitle('Alamat Pengantaran'),
            const SizedBox(height: 8),
            _buildAddressInput(controller: _alamatPengantaran),

            const SizedBox(height: 16),

            _buildSectionTitle('Alamat Penjemputan'),
            const SizedBox(height: 8),
            _buildAddressInput(controller: _alamatPenjemputan),

            const SizedBox(height: 16),

            // 8. Catatan Pesanan
            _buildSectionTitleWithOptional('Catatan Pesanan', '(opsional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1B4E6C), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _catatan,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Tombol Lanjutkan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi lanjut ke Form Konfirmasi Pesanan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284470),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Lanjutkan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B4E6C),
      ),
    );
  }

  Widget _buildSectionTitleWithOptional(String title, String opt) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B4E6C),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          opt,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildLaundryTypeCard({
    required String title,
    required String subtitle,
    required String note,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1B4E6C),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1B4E6C)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1B4E6C), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4E6C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: const Color(0xFF1B4E6C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String tagText,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1B4E6C),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B4E6C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDD6FE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tagText,
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          color: const Color(0xFF5B21B6),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: const Color(0xFF1B4E6C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioProduct({
    required String label,
    String? badge,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: const Color(0xFF1B4E6C),
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF1B4E6C),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDD6FE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: const Color(0xFF5B21B6),
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
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1B4E6C),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1B4E6C), size: 24),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: const Color(0xFF1B4E6C),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1B4E6C)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B4E6C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1B4E6C), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 12),
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: Color(0xFF1B4E6C),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}