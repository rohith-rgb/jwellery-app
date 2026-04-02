import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: const Icon(Icons.account_balance,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text('Finance & Jewelry',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 4),
                  const Text('Admin Management Portal',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 40),

                  // Form
                  Container(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(color: AppTheme.divider),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.cardShadow,
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sign In',
                              style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 4),
                          const Text('Enter your admin credentials',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Enter valid email'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Minimum 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Error
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) {
                              if (auth.error == null)
                                return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: AppTheme.errorLight,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(auth.error!,
                                    style: const TextStyle(
                                        color: AppTheme.error, fontSize: 13)),
                              );
                            },
                          ),

                          // Button
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => ElevatedButton(
                              onPressed: auth.loading ? null : _login,
                              child: auth.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Sign In'),
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
      ),
    );
  }
}
