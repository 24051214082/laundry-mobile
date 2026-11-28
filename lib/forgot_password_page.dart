import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;
  bool _isEmailVerified = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _verifiedUserId;
  String? _verifiedUserName;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white),
        ),
      ),
    );
  }

  // Tahap 1: Cek apakah email terdaftar di tabel 'users' Supabase
  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Masukkan alamat email yang valid terlebih dahulu',
          isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = await _supabase
          .from('users')
          .select('id, name, email')
          .ilike('email', email)
          .maybeSingle();

      if (!mounted) return;

      if (user == null) {
        setState(() => _isLoading = false);
        _showSnackBar('Email tidak terdaftar di sistem kami', isError: true);
        return;
      }

      setState(() {
        _isEmailVerified = true;
        _verifiedUserId = user['id'].toString();
        _verifiedUserName = (user['name'] ?? 'Pengguna').toString();
        _isLoading = false;
      });

      _showSnackBar('Tautan & verifikasi akun berhasil ditemukan untuk $email');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memverifikasi email: $e', isError: true);
    }
  }

  // Tahap 2: Simpan password baru ke kolom 'password_hash' pada tabel 'users'
  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar('Password baru dan konfirmasi password wajib diisi',
          isError: true);
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar('Password minimal terdiri dari 6 karakter', isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar('Konfirmasi password tidak cocok', isError: true);
      return;
    }

    if (_verifiedUserId == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _supabase
          .from('users')
          .update({'password_hash': newPass}).eq('id', _verifiedUserId!);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Tampilkan dialog sukses lalu kembali ke halaman Login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Password Berhasil Diubah!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B4E6C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan masuk kembali menggunakan password baru Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF338CA8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Login',
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
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memperbarui password: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFD6EFFB),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Kembali
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF1B4E6C),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ilustrasi Ikon Kunci
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4E6C).withValues(alpha: 0.1),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 44,
                      color: Color(0xFF338CA8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Lupa Password?',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B4E6C),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _isEmailVerified
                        ? 'Halo $_verifiedUserName, silakan buat password baru untuk akunmu.'
                        : 'Masukkan email yang terdaftar untuk memverifikasi akun dan mengatur ulang password.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF2E637E),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Card Form Putih Rounded
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4E6C).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Email
                      Text(
                        'Email Terdaftar',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B4E6C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        enabled: !_isEmailVerified,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'contoh@gmail.com',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF338CA8),
                          ),
                          suffixIcon: _isEmailVerified
                              ? const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF16A34A),
                          )
                              : null,
                          filled: true,
                          fillColor: _isEmailVerified
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),

                      // Jika email sudah diverifikasi, tampilkan form Password Baru
                      if (_isEmailVerified) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Password Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Minimal 6 karakter',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF338CA8),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Konfirmasi Password Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B4E6C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Ulangi password baru',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF338CA8),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Tombol Utama (Verifikasi Email -> Simpan Password Baru)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isEmailVerified
                              ? _resetPassword
                              : _verifyEmail),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF338CA8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            _isEmailVerified
                                ? 'Simpan Password Baru'
                                : 'Verifikasi Email',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      if (_isEmailVerified) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isEmailVerified = false;
                                _verifiedUserId = null;
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                              });
                            },
                            child: Text(
                              'Ganti Alamat Email',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
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
        ),
      ),
    );
  }
}