import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Memantau perubahan teks agar status tombol selalu reaktif
    _namaController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _teleponController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _konfirmasiPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _namaController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _teleponController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _konfirmasiPasswordController.removeListener(_onFieldChanged);

    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  // Cek apakah semua field telah diisi teks
  bool get _isAllFieldsFilled {
    return _namaController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _teleponController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _konfirmasiPasswordController.text.trim().isNotEmpty;
  }

  // Validasi format email standar
  bool _isEmailValid(String email) {
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _handleSignUp() {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final telepon = _teleponController.text.trim();
    final password = _passwordController.text;
    final konfirmasiPassword = _konfirmasiPasswordController.text;

    // 1. Validasi semua field terisi
    if (nama.isEmpty ||
        email.isEmpty ||
        telepon.isEmpty ||
        password.isEmpty ||
        konfirmasiPassword.isEmpty) {
      _showWarningSnackBar('Semua kolom data wajib diisi!');
      return;
    }

    // 2. Validasi format email
    if (!_isEmailValid(email)) {
      _showWarningSnackBar('Format email tidak valid (contoh: user@gmail.com)');
      return;
    }

    // 3. Validasi kesamaan password dan konfirmasi password
    if (password != konfirmasiPassword) {
      _showWarningSnackBar('Konfirmasi password tidak cocok dengan password awal!');
      return;
    }

    // Tampilkan notifikasi berhasil dan langsung navigasi ke HomePage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Akun berhasil dibuat! Selamat datang di Wish You Wash.',
          style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // Langsung arahkan ke HomePage dan bersihkan tumpukan rute sign up/login
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFFB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Navigasi Kembali
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1B4E6C),
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Create New\nAccount',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF287998),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Daftar sekarang dan nikmati layanan\nlaundry yang mudah.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF1E5266),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Nama
                    _buildPillTextField(
                      controller: _namaController,
                      hintText: 'Nama',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Input Email
                    _buildPillTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Input Nomor Telepon
                    _buildPillTextField(
                      controller: _teleponController,
                      hintText: 'Nomor Telepon',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Input Password
                    _buildPillTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Konfirmasi Password
                    _buildPillTextField(
                      controller: _konfirmasiPasswordController,
                      hintText: 'Konfirmasi Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 28),

                    // Tombol Sign Up
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAllFieldsFilled
                              ? const Color(0xFF338CA8)
                              : const Color(0xFF338CA8).withOpacity(0.55),
                          elevation: _isAllFieldsFilled ? 3 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Link Kembali ke Login
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF28546A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Log in here',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E465D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF24607B).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFFBFD2DC),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              icon,
              color: const Color(0xFFB5C9D5),
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFFB5C9D5),
              size: 20,
            ),
            onPressed: onToggleVisibility,
          )
              : null,
        ),
      ),
    );
  }
}