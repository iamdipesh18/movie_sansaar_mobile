import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/content_type.dart'; // for /combined_home routing

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Account created!')));
        Navigator.pushReplacementNamed(
          context,
          '/combined_home',
          arguments: ContentType.movie,
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFEEE5FF), Color(0xFF8973B3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
          ),

          // 🔙 Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black,
                ),

                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/combined_home',
                    arguments: ContentType.movie,
                  );
                },
              ),
            ),
          ),

          // 🧾 Form Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(maxWidth: 450),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/logo.png'),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // always white
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your name'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.length < 6
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_reset_outlined,
                            obscureText: true,
                            validator: (value) =>
                                value != _passwordController.text
                                ? 'Passwords don’t match'
                                : null,
                          ),
                          const SizedBox(height: 28),

                          // ⚫ Modern Black Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already registered?',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/signin',
                                  );
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: isDark ? Colors.white12 : Colors.white,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
