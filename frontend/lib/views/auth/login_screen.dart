import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: 'admin');
  final TextEditingController _passwordController = TextEditingController(text: 'Admin@123');
  bool _useRSAEncryption = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authVM = context.read<AuthViewModel>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    bool success = false;
    if (_useRSAEncryption) {
      success = await authVM.secureLoginWithRSA(username, password);
    } else {
      success = await authVM.login(username, password);
    }

    if (success && mounted) {
      if (authVM.isKitchen) {
        context.go('/kitchen');
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Staff & Admin Security Portal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: AppTheme.darkCard,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.lock_outline, color: AppTheme.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Staff Authentication',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'RSA-2048 + JWT Bearer Security',
                              style: TextStyle(fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.darkBorder, height: 32),

                    if (authVM.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorRed),
                        ),
                        child: Text(
                          authVM.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Username
                    const Text('Username', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter username',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppTheme.darkBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                        ),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white60),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppTheme.darkBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                        ),
                        prefixIcon: const Icon(Icons.key_outlined, color: Colors.white60),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white60,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // RSA Toggle Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('RSA 2048-Bit Handshake', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text('Encrypts payload before wire transmission',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                      value: _useRSAEncryption,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _useRSAEncryption = val),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authVM.isLoading ? null : _handleLogin,
                        child: authVM.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(_useRSAEncryption ? '🔒 Secure RSA Sign In' : 'Sign In'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Fill Demo Credentials
                    const Text('Demo Quick-Fill:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _usernameController.text = 'admin';
                            _passwordController.text = 'Admin@123';
                          },
                          child: const Text('Admin', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            _usernameController.text = 'chef';
                            _passwordController.text = 'Chef@123';
                          },
                          child: const Text('Kitchen Chef', style: TextStyle(fontSize: 12)),
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
    );
  }
}

