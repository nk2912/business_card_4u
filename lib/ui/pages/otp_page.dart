import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/auth/auth_provider.dart';
import 'complete_register_page.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  int _secondsRemaining = 300;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes =
    (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds =
    (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : const Color(0xFF1E3C72),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      _showMessage("Please enter valid 6 digit OTP",
          isError: true);
      return;
    }

    final message = await context
        .read<AuthProvider>()
        .verifyOtpOnly(widget.email, otp);

    if (!mounted) return;

    if (message == null) {
      _showMessage("Something went wrong",
          isError: true);
      return;
    }

    final isSuccess =
    message.toLowerCase().contains("success");

    _showMessage(message, isError: !isSuccess);

    if (isSuccess) {
      Future.delayed(const Duration(milliseconds: 500),
              () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CompleteRegisterPage(email: widget.email),
              ),
            );
          });
    }
  }

  Future<void> _resendOtp() async {
    final message = await context
        .read<AuthProvider>()
        .sendOtp(widget.email);

    if (!mounted) return;

    if (message == null) {
      _showMessage("Failed to resend OTP",
          isError: true);
      return;
    }

    final isSuccess =
    message.toLowerCase().contains("success");

    _showMessage(message, isError: !isSuccess);

    if (isSuccess) {
      setState(() {
        _secondsRemaining = 300;
      });
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 80),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formattedTime,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _secondsRemaining == 0
                              ? Colors.red
                              : const Color(0xFF1E3C72),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "------",
                        filled: true,
                        fillColor:
                        const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF1E3C72),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                30),
                          ),
                        ),
                        onPressed:
                        auth.isLoading ? null : _verifyOtp,
                        child: auth.isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Verify OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (_secondsRemaining == 0) ...[
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _resendOtp,
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(
                            color:
                            Color(0xFF1E3C72),
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
    );
  }
}
