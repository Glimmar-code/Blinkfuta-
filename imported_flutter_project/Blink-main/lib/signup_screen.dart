import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/brand.dart';
import 'onboarding_screen.dart';
import 'signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await AuthService.signUpWithEmail(
      email: _email.text,
      password: _password.text,
      username: _name.text,
    );
    if (!mounted) return;
    if (res.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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

              // Hero header
              const Align(
                alignment: Alignment.centerLeft,
                child: BlinkLogo(fontSize: 38),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.2, duration: 500.ms),

              const SizedBox(height: 36),

              const Text(
                'Create your account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .slideY(begin: 0.2, delay: 150.ms, duration: 500.ms),

              const SizedBox(height: 8),
              const Text(
                'Join the Blink community in seconds.',
                style: TextStyle(color: BlinkColors.textSecondary, fontSize: 15),
              ).animate().fadeIn(delay: 250.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // Google
              GoogleButton(onPressed: _google, loading: _googleLoading)
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .slideY(begin: 0.2, delay: 350.ms, duration: 500.ms),

              const SizedBox(height: 22),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: BlinkColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or', style: TextStyle(color: BlinkColors.textMuted, fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: BlinkColors.divider)),
                ],
              ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

              const SizedBox(height: 22),

              // Fields
              BlinkTextField(
                label: 'Username',
                hint: 'your_username',
                controller: _name,
                keyboardType: TextInputType.text,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, delay: 500.ms),

              const SizedBox(height: 16),

              BlinkTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, delay: 600.ms),

              const SizedBox(height: 16),

              BlinkTextField(
                label: 'Password',
                hint: 'At least 6 characters',
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
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.1, delay: 700.ms),

              const SizedBox(height: 28),

              // Error
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: BlinkColors.error, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ).animate().shake(duration: 400.ms),

              // Sign up button
              PrimaryButton(
                label: 'Create account',
                icon: Icons.arrow_forward_rounded,
                onPressed: _loading ? null : _signUp,
                loading: _loading,
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

              const SizedBox(height: 22),

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: BlinkColors.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SigninScreen()),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(color: BlinkColors.accent, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
