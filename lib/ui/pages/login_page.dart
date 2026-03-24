import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../components/app_primary_button.dart';
import '../components/app_toast.dart';
import '../components/loading_view.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final String? initialMessage;

  const LoginPage({super.key, this.initialMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _lastShownMessage;

  void _showInfoMessage(String message) {
    AppToast.show(context, message, type: AppToastType.info);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _lastShownMessage = widget.initialMessage;
        _showInfoMessage(widget.initialMessage!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pendingMessage = auth.pendingMessage;

    if (pendingMessage != null && pendingMessage != _lastShownMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final message = context.read<AuthProvider>().consumePendingMessage();
        if (message == null) return;
        _lastShownMessage = message;
        _showInfoMessage(message);
      });
    } else if (pendingMessage == null) {
      _lastShownMessage = null;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.surfaceSoft,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              brightness: Brightness.light,
              surface: Colors.white,
              onSurface: const Color(0xFF0B1220),
            ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF0B1220),
              displayColor: const Color(0xFF0B1220),
            ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
          /// ================= MAIN CONTENT =================
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// ================= HERO SECTION =================
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: PremiumHeroPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        RichText(
                          text: TextSpan(
                            text: 'businessCard',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1220),
                            ),
                            children: const [
                              TextSpan(
                                text: '4U',
                                style: TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= FULL WIDTH IMAGE =================
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/login.png',
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= LOGIN FORM =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _inputField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 18),
                      _inputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppPrimaryButton(
                        text: 'Log In',
                        loading: auth.isLoading,
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final success =
                                    await context.read<AuthProvider>().login(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                        );

                                if (!success && context.mounted) {
                                  AppToast.show(
                                    context,
                                    context.read<AuthProvider>().lastErrorMessage ??
                                        'Invalid email or password',
                                    type: AppToastType.error,
                                  );
                                }
                              },
                        height: 52,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Don't have an account? Register"),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Developed by Asia Brightway',
                        style: const TextStyle(
                          color: Color(0xFF5B6473),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ================= LOADING OVERLAY =================
          if (auth.isLoading)
            AbsorbPointer(
              absorbing: true,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoadingView(size: 120),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().cancelLoading();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: Color(0xFF0B1220),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF5B6473)),
        prefixIcon: Icon(icon, color: const Color(0xFF5B6473)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// ================= HERO WAVE PAINTER =================
class PremiumHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.75);

    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 1.05,
      size.width,
      size.height * 0.85,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
