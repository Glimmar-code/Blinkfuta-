import 'package:flutter/material.dart';
import '../../config/theme.dart';

class FacultyBadge extends StatelessWidget {
  final String tag;
  const FacultyBadge({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final color = BlinkColors.faculty(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.33)),
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
      ),
    );
  }
}