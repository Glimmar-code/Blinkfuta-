import 'dart:async';
import 'package:flutter/material.dart';

/// Controller you can hold in a screen's State to trigger the floating
/// pill snackbar (matches Figma's `Snackbar` + `showSnack`).
class BlinkSnackController extends ChangeNotifier {
  String msg = '';
  bool visible = false;
  Timer? _timer;

  void show(String message) {
    _timer?.cancel();
    msg = message;
    visible = true;
    notifyListeners();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      visible = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Place this in a Stack, positioned near the bottom, wherever you use
/// [BlinkSnackController].
class BlinkSnackbar extends StatelessWidget {
  final BlinkSnackController controller;
  const BlinkSnackbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AnimatedOpacity(
          opacity: controller.visible ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            offset: controller.visible ? Offset.zero : const Offset(0, 0.3),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xEB1E1E1E),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  child: Text(
                    controller.msg,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}