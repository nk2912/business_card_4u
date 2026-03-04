import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();

  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isError ? const Color(0xFFB42318) : const Color(0xFFDCEBFF),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isError ? const Color(0xFFDC2626) : const Color(0xFFBFDBFE),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit(AuthProvider auth) async {
    final email = _emailController.text.trim();

    final message = await auth.sendOtp(email);

    if (!mounted) return;

    final lower = (message ?? "").toLowerCase();
    final isSuccess = lower.contains("success") || lower.contains("sent");

    if (message != null && message.trim().isNotEmpty) {
      _toast(message, isError: !isSuccess);
    }

    if (isSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpPage(email: email)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    const bg = Color(0xFFF7F8FC);
    const text = Color(0xFF0B1220);
    const muted = Color(0xFF5B6473);
    const border = Color(0xFFE7EAF3);

    const deep = Color(0xFF0A2A66);
    const blue = Color(0xFF2F6FDB);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple top branding
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [deep, blue]),
                    ),
                    child: const Icon(Icons.badge_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "businessCard4U",
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title + subtitle
              const Text(
                "Create your account",
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your email to receive a verification code.",
                style: TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              // Form (one clean card)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        controller: _emailController,
                        enabled: !auth.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => auth.isLoading ? null : _submit(auth),
                        decoration: const InputDecoration(
                          hintText: "name@company.com",
                          prefixIcon: Icon(Icons.alternate_email_rounded, color: blue),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        style: const TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : () => _submit(auth),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: auth.isLoading
                                  ? [deep.withOpacity(.55), blue.withOpacity(.55)]
                                  : const [deep, blue],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Send code",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Code expires in 5 minutes.",
                      style: TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Center(
                child: Text(
                  "© ${DateTime.now().year} businessCard4U",
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
