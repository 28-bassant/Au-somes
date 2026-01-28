import 'package:au_somes/ui/child_screen/reinforcement_widgets/sound_helper.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/well_done_card.dart';
import 'package:flutter/material.dart';

class WellDoneOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context, {Duration duration = const Duration(seconds: 2)}) {
    if (_entry != null) return;

    SoundHelper.playSuccess();

    _entry = OverlayEntry(
      builder: (_) => const WellDoneCard(),
    );

    Overlay.of(context).insert(_entry!);

    Future.delayed(duration, hide);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
