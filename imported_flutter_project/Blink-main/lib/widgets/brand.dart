import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../config/theme.dart';

/// The Blink brand mark: a gradient badge with an eye that blinks on a
/// gentle, randomized interval. It's a self-contained widget — drop it
/// anywhere (app bars, splash, profile headers) and it takes care of its
/// own animation lifecycle.
class BlinkMark extends StatefulWidget {
  final double size;
  const BlinkMark({super.key, this.size = 40});

  @override
  State<BlinkMark> createState() => _BlinkMarkState();
}

class _BlinkMarkState extends State<BlinkMark> with SingleTickerProviderStateMixin {
  late final AnimationController _lidController;
  final Random _random = Random();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      value: 1, // 1 = eye open, ~0 = eye closed
    );
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    final waitMs = 2200 + _random.nextInt(2600);
    _timer = Timer(Duration(milliseconds: waitMs), _blink);
  }

  Future<void> _blink() async {
    if (!mounted) return;
    await _lidController.reverse();
    if (!mounted) return;
    await _lidController.forward();
    if (!mounted) return;
    _scheduleNextBlink();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size * 0.32;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BlinkColors.accentSoft, BlinkColors.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: BlinkColors.accent.withValues(alpha: 0.35),
            blurRadius: widget.size * 0.35,
            offset: Offset(0, widget.size * 0.12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _lidController,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            // Squash vertically to mimic an eyelid closing, rather than a
            // uniform shrink — reads unmistakably as a "blink".
            transform: Matrix4.diagonal3Values(1, max(_lidController.value, 0.06), 1),
            child: child,
          );
        },
        child: PhosphorIcon(
          PhosphorIconsFill.eye,
          size: widget.size * 0.52,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// The Blink wordmark. When [animate] is true, a slow shimmer sweeps
/// across the text — reserved for hero moments (splash, auth headers).
/// Set it to false for compact, persistent placements like app bars,
/// where a looping shimmer would be more distracting than delightful.
class BlinkLogo extends StatelessWidget {
  final double fontSize;
  final bool animate;
  const BlinkLogo({super.key, this.fontSize = 32, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      letterSpacing: -0.5,
      height: 1,
    );

    final wordmark = Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'Blin'),
          TextSpan(text: 'k', style: base.copyWith(color: BlinkColors.accentSoft)),
        ],
      ),
    );

    if (!animate) return wordmark;

    return wordmark
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 1800.ms,
          delay: 900.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

/// A small, hand-painted Google "G" — no network image, no asset bundle,
/// crisp at any size. Used inside [GoogleButton].
class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.2;
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const double quarter = pi / 2;

    ring.color = const Color(0xFF4285F4); // blue
    canvas.drawArc(rect, -quarter, quarter, false, ring);
    ring.color = const Color(0xFFEA4335); // red
    canvas.drawArc(rect, 0, quarter, false, ring);
    ring.color = const Color(0xFFFBBC05); // yellow
    canvas.drawArc(rect, quarter, quarter, false, ring);
    ring.color = const Color(0xFF34A853); // green
    canvas.drawArc(rect, 2 * quarter, quarter, false, ring);

    // Crossbar that completes the "G" silhouette.
    final Paint bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - strokeWidth / 2, radius * 0.92, strokeWidth),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleGPainter oldDelegate) => false;
}

/// "Continue with Google" button, styled per Google's brand guidance
/// (white surface, dark text) regardless of the app's dark theme.
class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  const GoogleButton({super.key, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: BlinkColors.googleWhite,
          disabledBackgroundColor: BlinkColors.googleWhite.withValues(alpha: 0.7),
          foregroundColor: const Color(0xFF1F1F1F),
          side: BorderSide.none,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: BlinkColors.googleBlue),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleGPainter()),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F)),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A labeled text field matching the Blink input style. The label renders
/// above the field (rather than as a floating Material label) to keep
/// forms scannable at a glance.
class BlinkTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffix;

  const BlinkTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: BlinkColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// The primary call-to-action button. Shows a spinner in place of its
/// content while [loading] is true, and disables taps during that time
/// even if the caller forgets to also null out [onPressed].
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
                if (icon != null) ...[
                  const SizedBox(width: 10),
                  Icon(icon, size: 20, color: Colors.white),
                ],
              ],
            ),
    );
  }
}
