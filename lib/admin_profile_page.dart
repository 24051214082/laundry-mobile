import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_bottom_nav.dart';
import 'user_session.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  static const Color _navy = Color(0xFF1B4E6C);
  static const Color _bg = Color(0xFFD8F1FD);
  static const Color _accent = AdminBottomNav.activeColor;
  static const Color _iconColor = Color(0xFF2C6B8E);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _emailC;
  final _outletC = TextEditingController(text: 'Wish You Wash Here');
  late final TextEditingController _addressC;

  late String _savedName;
  late String _savedPhone;
  late String _savedEmail;
  late String _savedOutlet;
  late String _savedAddress;

  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(
      text: (UserSession.name != null && UserSession.name!.isNotEmpty)
          ? UserSession.name!
          : 'Admin Nency',
    );
    _phoneC = TextEditingController(
      text: (UserSession.phone != null && UserSession.phone!.isNotEmpty)
          ? UserSession.phone!
          : '+62 812-3456-7890',
    );
    _emailC = TextEditingController(
      text: (UserSession.email != null && UserSession.email!.isNotEmpty)
          ? UserSession.email!
          : 'admin@wishyouwash.com',
    );
    _addressC = TextEditingController(
      text: (UserSession.address != null && UserSession.address!.isNotEmpty)
          ? UserSession.address!
          : 'Jl. Ketintang Baru No. 12, Surabaya',
    );

    _syncSaved();

    for (final c in [_nameC, _phoneC, _emailC, _outletC, _addressC]) {
      c.addListener(_checkChanges);
    }

    _fetchLatestAdmin();
  }

  void _syncSaved() {
    _savedName = _nameC.text;
    _savedPhone = _phoneC.text;
    _savedEmail = _emailC.text;
    _savedOutlet = _outletC.text;
    _savedAddress = _addressC.text;
  }

  Future<void> _fetchLatestAdmin() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) return;

    try {
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (!mounted || data == null) return;
      await UserSession.setUser(data);

      _nameC.text = UserSession.name ?? _nameC.text;
      _phoneC.text = UserSession.phone ?? _phoneC.text;
      _emailC.text = UserSession.email ?? _emailC.text;
      _addressC.text = UserSession.address ?? _addressC.text;
      _syncSaved();
      setState(() => _hasChanges = false);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _outletC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final changed = _nameC.text != _savedName ||
        _phoneC.text != _savedPhone ||
        _emailC.text != _savedEmail ||
        _outletC.text != _savedOutlet ||
        _addressC.text != _savedAddress;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    final newName = _nameC.text.trim();
    final newPhone = _phoneC.text.trim();
    final newEmail = _emailC.text.trim().toLowerCase();
    final newAddress = _addressC.text.trim();
    final uid = UserSession.userId;

    try {
      if (uid != null && uid.isNotEmpty) {
        final updated = await Supabase.instance.client
            .from('users')
            .update({
              'name': newName,
              'phone': newPhone,
              'email': newEmail,
              'address': newAddress,
            })
            .eq('id', uid)
            .select()
            .single();

        await UserSession.setUser(updated);
      }

      if (!mounted) return;
      _syncSaved();
      setState(() => _hasChanges = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui',
              style: GoogleFonts.poppins(fontSize: 12.5)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text('Gagal memperbarui profil: $e',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profil',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    Text(
                      'Ubah data dirimu langsung di halaman ini',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF326D8C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarSection(),
                        const SizedBox(height: 24),
                        _sectionTitle('Informasi Pribadi'),
                        const SizedBox(height: 10),
                        _field(
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline_rounded,
                          controller: _nameC,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),
                        _field(
                          label: 'Nomor HP',
                          icon: Icons.phone_outlined,
                          controller: _phoneC,
                          keyboardType: TextInputType.phone,
                        ),
                        _field(
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          controller: _emailC,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Email tidak boleh kosong';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        _sectionTitle('Informasi Outlet'),
                        const SizedBox(height: 10),
                        _field(
                          label: 'Nama Outlet',
                          icon: Icons.storefront_outlined,
                          controller: _outletC,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama outlet tidak boleh kosong'
                              : null,
                        ),
                        _field(
                          label: 'Alamat Outlet',
                          icon: Icons.location_on_outlined,
                          controller: _addressC,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Alamat tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        _buildSaveButton(),
                        const SizedBox(height: 12),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 46),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _savedName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded,
                  size: 20, color: Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Administrator',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: readOnly ? const Color(0xFF475569) : _navy,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? 24 : 0),
                child: Icon(icon, size: 22, color: _iconColor),
              ),
              enabledBorder: border(const Color(0xFFE2E8F0)),
              focusedBorder: border(_accent, 1.5),
              errorBorder: border(const Color(0xFFEF4444)),
              focusedErrorBorder: border(const Color(0xFFEF4444), 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (_hasChanges && !_isSaving) ? _save : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Simpan Perubahan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          side: const BorderSide(color: Color(0xFFFECACA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.logout_rounded,
            size: 20, color: Color(0xFFEF4444)),
        label: Text(
          'Keluar dari Akun',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Keluar dari akun?',
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: _navy),
        ),
        content: Text(
          'Kamu perlu login lagi untuk mengakses halaman admin.',
          style: GoogleFonts.poppins(
              fontSize: 12.5, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              await UserSession.clear();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: Text('Keluar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _navy,
      ),
    );
  }
}