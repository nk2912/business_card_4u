import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/auth/auth_provider.dart';

class CompleteRegisterPage extends StatefulWidget {
  final String email;

  const CompleteRegisterPage({super.key, required this.email});

  @override
  State<CompleteRegisterPage> createState() =>
      _CompleteRegisterPageState();
}

class _CompleteRegisterPageState
    extends State<CompleteRegisterPage> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF1C1C1E),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.email,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                // Main Card
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(.06),
                        blurRadius: 30,
                        offset:
                        const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        _buildInput(
                          controller: _nameController,
                          hint: "Full Name",
                        ),

                        const SizedBox(height: 20),

                        _buildPasswordInput(
                          controller:
                          _passwordController,
                          hint: "Password",
                          obscure: _obscurePassword,
                          toggle: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        _buildPasswordInput(
                          controller:
                          _confirmController,
                          hint: "Confirm Password",
                          obscure: _obscureConfirm,
                          toggle: () {
                            setState(() {
                              _obscureConfirm =
                              !_obscureConfirm;
                            });
                          },
                        ),

                        const SizedBox(height: 35),

                        // Premium Button with Strong Shadow
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                    0xFF1E3C72)
                                    .withOpacity(.35),
                                blurRadius: 20,
                                offset:
                                const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(
                                  0xFF1E3C72),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                            auth.isLoading
                                ? null
                                : () async {

                              if (!_formKey
                                  .currentState!
                                  .validate()) {
                                return;
                              }

                              final success =
                              await context
                                  .read<
                                  AuthProvider>()
                                  .completeRegister(
                                widget.email,
                                _nameController
                                    .text
                                    .trim(),
                                _passwordController
                                    .text
                                    .trim(),
                                _confirmController
                                    .text
                                    .trim(),
                              );

                              if (!mounted)
                                return;

                              if (success) {
                                _showMessage(
                                    "Registration Successful");
                                Navigator.popUntil(
                                    context,
                                        (route) =>
                                    route
                                        .isFirst);
                              } else {
                                _showMessage(
                                    "Registration Failed",
                                    isError:
                                    true);
                              }
                            },
                            child: auth.isLoading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Text(
                              "Create Account",
                              style:
                              TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight
                                    .bold,
                                letterSpacing:
                                0.5,
                                color:
                                Colors.white,
                              ),
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
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hint),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Required field";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(
        hint,
        suffix: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: toggle,
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return "Minimum 6 characters";
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String hint,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding:
      const EdgeInsets.symmetric(
          horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }
}