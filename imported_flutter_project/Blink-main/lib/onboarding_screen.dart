import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../config/theme.dart';
import 'home_screen.dart';

class _OnboardStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color accent;
  const _OnboardStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accent,
  });
}

const _steps = <_OnboardStep>[
  _OnboardStep(
    icon: PhosphorIconsFill.house,
    title: 'Your Feed',
    subtitle: 'See posts, moments and stories from the people you follow — all in one place.',
    gradient: [Color(0xFF2E1212), Color(0xFF1A0808)],
    accent: BlinkColors.accent,
  ),
  _OnboardStep(
    icon: PhosphorIconsFill.magnifyingGlass,
    title: 'Discover',
    subtitle: 'Search for people, topics and trending content across the whole Blink community.',
    gradient: [Color(0xFF2A1414), Color(0xFF180A0A)],
    accent: Color(0xFFE04A4A),
  ),
  _OnboardStep(
    icon: PhosphorIconsFill.trophy,
    title: 'Leaderboard',
    subtitle: "Climb the ranks. See who's topping the charts and compete for the top spot.",
    gradient: [Color(0xFF2E1810), Color(0xFF1A0C08)],
    accent: Color(0xFFFBBF24),
  ),
  _OnboardStep(
    icon: PhosphorIconsFill.storefront,
    title: 'Aluta Market',
    subtitle: 'Buy and sell with the community. List items, make offers, and trade safely.',
    gradient: [Color(0xFF1E1226), Color(0xFF120A18)],
    accent: Color(0xFF4ADE80),
  ),
  _OnboardStep(
    icon: PhosphorIconsFill.bell,
    title: 'Notifications',
    subtitle: 'Never miss a thing — likes, comments, follows and market updates in real time.',
    gradient: [Color(0xFF1A1410), Color(0xFF100A08)],
    accent: Color(0xFFFF6B6B),
  ),
  _OnboardStep(
    icon: PhosphorIconsFill.chatCircle,
    title: 'Messages',
    subtitle: 'Chat privately with friends, share posts and stay connected.',
    gradient: [Color(0xFF22101A), Color(0xFF14080E)],
    accent: Color(0xFF60A5FA),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _steps.length - 1) {
      _controller.nextPage(duration: 400.ms, curve: Curves.easeOutCubic);
    } else {
      _enter();
    }
  }

  void _enter() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: 500.ms,
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_page];
    final isLast = _page == _steps.length - 1;
    return Scaffold(
      body: AnimatedContainer(
        duration: 500.ms,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: step.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: _enter,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: BlinkColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final s = _steps[index];
                    return _OnboardPage(step: s, active: index == _page);
                  },
                ),
              ),

              // Dots
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? step.accent : BlinkColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: step.accent,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Get started' : 'Continue',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
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

class _OnboardPage extends StatelessWidget {
  final _OnboardStep step;
  final bool active;
  const _OnboardPage({required this.step, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon badge
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: step.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: step.accent.withValues(alpha: 0.3), width: 1.5),
            ),
            child: PhosphorIcon(
              step.icon,
              size: 60,
              color: step.accent,
            ),
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 40),

          Text(
            step.title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.center,
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.2, delay: 150.ms, duration: 500.ms),

          const SizedBox(height: 16),

          Text(
            step.subtitle,
            style: const TextStyle(fontSize: 16, color: BlinkColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          )
              .animate(target: active ? 1 : 0)
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.2, delay: 300.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
