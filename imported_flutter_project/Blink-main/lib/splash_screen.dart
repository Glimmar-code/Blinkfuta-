import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/theme.dart';
import '../widgets/brand.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 2200.ms);
    _ctrl.forward();
    Future.delayed(2600.ms, _goNext);
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;

    // A signed-in user has already seen onboarding — send them straight
    // to the feed. Only a brand-new (signed-out) visitor should land on
    // sign-up, which is what eventually leads into onboarding.
    final session = Supabase.instance.client.auth.currentSession;
    final destination = session == null ? const SignupScreen() : const HomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => destination,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: 500.ms,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [BlinkColors.primary, BlinkColors.primaryDeep],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlinkMark(size: 72)
                  .animate(controller: _ctrl)
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .then()
                  .shimmer(duration: 1200.ms, color: BlinkColors.accentSoft.withValues(alpha: 0.4)),
              const SizedBox(height: 28),
              const BlinkLogo(fontSize: 56),
              const SizedBox(height: 14),
              const Text(
                'See. Share. Blink.',
                style: TextStyle(
                  color: BlinkColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideY(begin: 0.3, delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
