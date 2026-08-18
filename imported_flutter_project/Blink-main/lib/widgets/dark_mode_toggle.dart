import 'package:flutter/material.dart';
import '../../config/theme.dart';

class DarkModeToggle extends StatelessWidget {
  final bool on;
  final VoidCallback onChanged;
  const DarkModeToggle({super.key, required this.on, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: on ? BlinkColors.accent : const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              on ? Icons.nightlight_round : Icons.wb_sunny,
              size: 12,
              color: on ? BlinkColors.accent : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}