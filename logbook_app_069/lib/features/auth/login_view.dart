// login_view.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logbook_app_069/features/auth/login_controller.dart';
import 'package:logbook_app_069/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // State untuk fitur baru
  bool _isPasswordVisible = false;
  int _loginAttempts = 0;
  bool _isLoginDisabled = false;
  Timer? _timer;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleLogin() {
    if (_isLoginDisabled) return;

    String user = _userController.text;
    String pass = _passController.text;

    // Validasi field tidak boleh kosong
    if (user.isEmpty || pass.isEmpty) {
      _showError("Username dan Password tidak boleh kosong!");
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      // Reset percobaan jika berhasil
      setState(() {
        _loginAttempts = 0;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Di sini kita kirimkan variabel 'user' ke parameter 'username' di CounterView
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      setState(() {
        _loginAttempts++;
      });
      _showError("Login Gagal! Percobaan ke-$_loginAttempts.");

      // Logika untuk menonaktifkan tombol
      if (_loginAttempts >= 3) {
        setState(() {
          _isLoginDisabled = true;
        });
        _timer = Timer(const Duration(seconds: 10), () {
          setState(() {
            _isLoginDisabled = false;
            _loginAttempts = 0; // Reset setelah 10 detik
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _timer?.cancel(); // Batalkan timer jika widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF59E0B);
    const primaryDark = Color(0xFFD97706);
    const darkText = Color(0xFF1F2937);
    const muted = Color(0xFF6B7280);
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative blurred circles ──
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            top: screenH * 0.15,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: screenH * 0.1,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // ── Konten utama ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: screenH * 0.03),

                    // ── Ikon + branding (glass circle) ──
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: const Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Logbook App",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Catat aktivitas harian Anda",
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75)),
                    ),

                    SizedBox(height: screenH * 0.035),

                    // ── Glassmorphism card ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.82),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Heading
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.login_rounded, size: 20, color: primaryDark),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Masuk Akun",
                                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: darkText),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Silakan masukkan kredensial Anda untuk melanjutkan",
                                style: TextStyle(fontSize: 13, color: muted, height: 1.4),
                              ),

                              const SizedBox(height: 22),

                              // Username
                              _buildLabel("Username"),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: _userController,
                                hint: "Masukkan username",
                                icon: Icons.person_outline_rounded,
                              ),

                              const SizedBox(height: 18),

                              // Password
                              _buildLabel("Password"),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: _passController,
                                hint: "Masukkan password",
                                icon: Icons.lock_outline_rounded,
                                obscure: !_isPasswordVisible,
                                suffix: IconButton(
                                  splashRadius: 20,
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: const Color(0xFFB0B8C4),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),

                              // Percobaan gagal (inline)
                              if (_loginAttempts > 0 && !_isLoginDisabled) ...[
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Percobaan gagal: $_loginAttempts/3",
                                        style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 22),

                              // Tombol Masuk (gradient button)
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: _isLoginDisabled
                                        ? null
                                        : const LinearGradient(
                                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                    color: _isLoginDisabled ? const Color(0xFFD1D5DB) : null,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _isLoginDisabled
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: primary.withOpacity(0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: _isLoginDisabled ? null : _handleLogin,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isLoginDisabled ? Icons.lock_clock_rounded : Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isLoginDisabled ? "Terkunci (10 detik)" : "Masuk",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Footer keamanan
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_user_rounded, size: 14, color: Colors.green[400]),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Koneksi aman & terenkripsi",
                                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                   
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    const primary = Color(0xFFF59E0B);
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        prefixIcon: Icon(icon, color: primary, size: 20),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
