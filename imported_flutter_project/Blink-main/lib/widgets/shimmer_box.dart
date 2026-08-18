import 'package:flutter/material.dart';

/// Simple animated shimmer placeholder, no external package required.
/// Matches the Figma `Shimmer` component (1.4s linear sweep).
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({super.key, required this.width, required this.height, this.radius = 12});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: ShaderMask(
              shaderCallback: (bounds) {
                final t = _controller.value;
                return LinearGradient(
                  begin: Alignment(-1 + 4 * t, 0),
                  end: Alignment(1 + 4 * t, 0),
                  colors: const [
                    Color(0x0AFFFFFF),
                    Color(0x1AFFFFFF),
                    Color(0x0AFFFFFF),
                  ],
                  stops: const [0.25, 0.5, 0.75],
                ).createShader(bounds);
              },
              child: Container(color: const Color(0x0AFFFFFF)),
            ),
          ),
        );
      },
    );
  }
}