import 'package:flutter/material.dart';
import '../post_model.dart';
import '../config/theme.dart';

class VerifiedMark extends StatelessWidget {
  final VerificationBadge badge;
  final double size;

  const VerifiedMark({
    super.key,
    required this.badge,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (badge == VerificationBadge.none) return const SizedBox.shrink();

    return Icon(
      Icons.verified,
      size: size,
      color: badge == VerificationBadge.gold 
          ? const Color(0xFFFFD700) 
          : BlinkColors.accent,
    );
  }
}
