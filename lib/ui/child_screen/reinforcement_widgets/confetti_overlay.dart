import 'package:flutter/material.dart';
import 'confetti_overlay_widget.dart';

class ConfettiOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context,
      {Duration duration = const Duration(seconds: 5)}) {

    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => const ConfettiOverlayWidget(),
    );

    Overlay.of(context).insert(_entry!);

    Future.delayed(duration, hide);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}