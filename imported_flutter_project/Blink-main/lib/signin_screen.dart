import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/brand.dart';
import 'home_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await AuthService.signInWithEmail(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (res.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      setState(() {
        _loading = false;
        _error = res.error;
      });
    }
  }

  Future<void> _google() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    final res = await AuthService.signInWithGoogle();
    if (!mounted) return;
    if (res.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      setState(() {
        _googleLoading = false;
        _error = res.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: BlinkLogo(fontSize: 38, animate: false),
              ),
              const SizedBox(height: 36),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to pick up where you left off.',
                style: TextStyle(color: BlinkColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              GoogleButton(onPressed: _google, loading: _googleLoading),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Divider(color: BlinkColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or', style: TextStyle(color: BlinkColors.textMuted, fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: BlinkColors.divider)),
                ],
              ),
              const SizedBox(height: 22),
              BlinkTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              BlinkTextField(
                label: 'Password',
                hint: 'Your password',
                controller: _password,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: BlinkColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 28),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: BlinkColors.error, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ).animate().shake(duration: 400.ms),
              PrimaryButton(
                label: 'Sign in',
                icon: Icons.arrow_forward_rounded,
                onPressed: _loading ? null : _signIn,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
