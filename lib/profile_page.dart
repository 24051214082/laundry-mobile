import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_bottom_nav.dart';
import 'user_profile_store.dart';
import 'user_session.dart';

class _C {
  static const headerBlue = Color(0xFFD6EFFB);
  static const navy = Color(0xFF1F3A6E);
  static const button = Color(0xFF263F73);
  static const tealAccent = Color(0xFF338CA8);
  static const textSub = Color(0xFF64748B);
  static const bgLight = Color(0xFFF8FAFC);
  static const danger = Color(0xFFEF4444);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _store = UserProfileStore.instance;

  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _emailC;
  late final TextEditingController _addressC;

  late String _savedName;
  late String _savedPhone;
  late String _savedEmail;
  late String _savedAddress;

  bool _isDirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _savedName = (UserSession.name != null && UserSession.name!.isNotEmpty)
        ? UserSession.name!
        : _store.name;
    _savedPhone = (UserSession.phone != null && UserSession.phone!.isNotEmpty)
        ? UserSession.phone!
        : _store.phone;
    _savedEmail = (UserSession.email != null && UserSession.email!.isNotEmpty)
        ? UserSession.email!
        : _store.email;
    _savedAddress =
        (UserSession.address != null && UserSession.address!.isNotEmpty)
            ? UserSession.address!
            : _store.address;

    _store.update(
      name: _savedName,
      phone: _savedPhone,
      email: _savedEmail,
      address: _savedAddress,
    );

    _nameC = TextEditingController(text: _savedName);
    _phoneC = TextEditingController(text: _savedPhone);
    _emailC = TextEditingController(text: _savedEmail);
    _addressC = TextEditingController(text: _savedAddress);

    for (final c in [_nameC, _phoneC, _emailC, _addressC]) {
      c.addListener(_checkDirty);
    }

    _fetchLatestProfile();
  }

  Future<void> _fetchLatestProfile() async {
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

      _savedName = UserSession.name ?? _savedName;
      _savedPhone = UserSession.phone ?? _savedPhone;
      _savedEmail = UserSession.email ?? _savedEmail;
      _savedAddress = UserSession.address ?? _savedAddress;

      _store.update(
        name: _savedName,
        phone: _savedPhone,
        email: _savedEmail,
        address: _savedAddress,
      );

      _nameC.text = _savedName;
      _phoneC.text = _savedPhone;
      _emailC.text = _savedEmail;
      _addressC.text = _savedAddress;

      setState(() => _isDirty = false);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  void _checkDirty() {
    final dirty = _nameC.text.trim() != _savedName ||
        _phoneC.text.trim() != _savedPhone ||
        _emailC.text.trim() != _savedEmail ||
        _addressC.text.trim() != _savedAddress;
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

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
      _savedName = newName;
      _savedPhone = newPhone;
      _savedEmail = newEmail;
      _savedAddress = newAddress;

      _store.update(
        name: newName,
        phone: newPhone,
        email: newEmail,
        address: newAddress,
      );

      setState(() => _isDirty = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Profil berhasil diperbarui',
            style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.danger,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Gagal menyimpan profil: $e',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _C.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Keluar Akun?',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Apakah kamu yakin ingin keluar dari akun Wish You Wash?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: _C.textSub),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await UserSession.clear();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.danger,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _C.headerBlue,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profil',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _C.navy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Ubah data dirimu langsung di halaman ini',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF2E637E),
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
                    color: _C.bgLight,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatar(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Informasi Pribadi'),
                          const SizedBox(height: 12),
                          _buildField(
                            label: 'Nama Lengkap',
                            controller: _nameC,
                            icon: Icons.person_outline_rounded,
                            hint: 'Masukkan nama lengkap',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              if (v.trim().length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            label: 'Nomor HP',
                            controller: _phoneC,
                            icon: Icons.phone_outlined,
                            hint: '+62 812-xxxx-xxxx',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s]'),
                              ),
                            ],
                            validator: (v) {
                              final digits =
                                  (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                              if (digits.isEmpty) {
                                return 'Nomor HP tidak boleh kosong';
                              }
                              if (digits.length < 9 || digits.length > 15) {
                                return 'Nomor HP tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            label: 'Email',
                            controller: _emailC,
                            icon: Icons.mail_outline_rounded,
                            hint: 'nama@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value);
                              return ok ? null : 'Format email tidak valid';
                            },
                          ),
                          const SizedBox(height: 22),
                          _buildSectionHeader('Alamat Utama'),
                          const SizedBox(height: 12),
                          _buildField(
                            label: 'Alamat Utama',
                            controller: _addressC,
                            icon: Icons.location_on_outlined,
                            hint: 'Nama jalan, nomor, kota',
                            maxLines: 3,
                            keyboardType: TextInputType.streetAddress,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              if (v.trim().length < 8) {
                                return 'Alamat terlalu singkat';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          _buildSaveButton(),
                          const SizedBox(height: 12),
                          _buildLogoutButton(),
                          const SizedBox(height: 16),
                          Text(
                            'Wish You Wash Laundry • Versi 1.0.0',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      ),
    );
  }

  Widget _buildAvatar() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _C.headerBlue, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: _C.navy.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(_store.avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _savedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.navy,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.verified_rounded,
              size: 17,
              color: Color(0xFF0284C7),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _C.navy,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _C.textSub,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: _C.tealAccent,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _C.navy,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFF94A3B8),
            ),
            errorStyle: GoogleFonts.poppins(fontSize: 10.5),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 14,
                right: 10,
                bottom: maxLines > 1 ? (maxLines - 1) * 20.0 : 0,
              ),
              child: Icon(icon, size: 20, color: _C.tealAccent),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            enabledBorder: border(const Color(0xFFE2E8F0)),
            focusedBorder: border(_C.tealAccent, 1.6),
            errorBorder: border(_C.danger),
            focusedErrorBorder: border(_C.danger, 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final enabled = _isDirty && !_isSaving;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? _saveProfile : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.button,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: const Icon(Icons.logout_rounded, size: 18, color: _C.danger),
        label: Text(
          'Keluar dari Akun',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.danger,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFECACA), width: 1.4),
          backgroundColor: const Color(0xFFFEF2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}