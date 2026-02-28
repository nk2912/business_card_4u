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

  void _showToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 80,
        left: 24,
        right: 24,
        child: _PremiumToast(
          message: message,
          isError: isError,
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2))
        .then((_) => entry.remove());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Enter your email to receive verification code",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: "Enter your email",
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: auth.isLoading
                      ? null
                      : () async {

                    if (_emailController.text.isEmpty) {
                      _showToast(
                        "Email is required",
                        isError: true,
                      );
                      return;
                    }

                    final message = await context
                        .read<AuthProvider>()
                        .sendOtp(
                      _emailController.text.trim(),
                    );

                    if (!context.mounted) return;

                    final isSuccess =
                        message != null &&
                            message
                                .toLowerCase()
                                .contains("success");

                    _showToast(
                      message ?? "Something went wrong",
                      isError: !isSuccess,
                    );

                    if (isSuccess) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpPage(
                            email:
                            _emailController.text.trim(),
                          ),
                        ),
                      );
                    }
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E3C72),
                          Color(0xFF2A5298),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(30)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: auth.isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Send OTP",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: Text(
                  "businessCard4U",
                  style: TextStyle(
                    color: Colors.grey.shade400,
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

class _PremiumToast extends StatelessWidget {
  final String message;
  final bool isError;

  const _PremiumToast({
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isError
              ? const Color(0xFFE9D5FF)
              : const Color(0xFFDCEBFF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isError
                ? const Color(0xFF6B21A8)
                : const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
