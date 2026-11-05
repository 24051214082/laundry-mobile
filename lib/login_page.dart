import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Validasi form sebelum berpindah ke halaman utama
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Reset Password',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: const Color(0xFF2C7D99),
            ),
          ),
          content: Form(
            key: resetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan email akunmu untuk menerima tautan reset kata sandi.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF28546A),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFFBFD2DC),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF0F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFFB5C9D5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (resetFormKey.currentState!.validate()) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF338CA8),
                      content: Text(
                        'Tautan reset password berhasil dikirim ke ${resetEmailController.text.trim()}',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF338CA8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kirim',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Bagian Card Atas (Logo Mesin Cuci)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Tiga titik hiasan kiri dan kanan atas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            3,
                                (index) => Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E5D57),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            3,
                                (index) => Container(
                              margin: const EdgeInsets.only(left: 5),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E5D57),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tampilan Logo dari Assets
                    Center(
                      child: Transform.scale(
                        scale: 1.1,
                        child: Image.asset(
                          'assets/logoterbaru.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Bagian Form Input dan Teks Deskripsi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Pakaian Bersih,\nHidup Lebih Ringan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: const Color(0xFF2C7D99),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Layanan laundry terpercaya, untuk\nkeseharian yang lebih baik.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF225567),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input Email
                      _buildPillFormField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Masukkan email yang valid (contoh: user@mail.com)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      _buildPillFormField(
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.trim().length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Tombol Log In
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF338CA8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Log In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Forgot Password
                      GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot Password',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF28546A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Navigasi ke Sign Up menggunakan Named Route
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "Don't have an account yet?",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF28546A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          border: InputBorder.none,
          errorStyle: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.redAccent,
          ),
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
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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