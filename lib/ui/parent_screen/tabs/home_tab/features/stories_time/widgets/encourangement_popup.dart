import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../../../../utils/app_colors.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EncouragementPopup extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const EncouragementPopup({super.key, required this.message, required this.onDismiss});

  @override
  State<EncouragementPopup> createState() => _EncouragementPopupState();
}

class _EncouragementPopupState extends State<EncouragementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  final FlutterTts _tts = FlutterTts();

  Future<void> _speak() async {
    final isArabic =
    RegExp(r'[\u0600-\u06FF]').hasMatch(widget.message);

    await _tts.stop();

    await _tts.awaitSpeakCompletion(true);

    await _tts.setLanguage(isArabic ? "ar-EG" : "en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    await _tts.speak(widget.message);

    widget.onDismiss();
  }
  @override
  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
    );

    _ctrl.forward();

    _speak();
  }
  @override
  void dispose() {
    _tts.stop();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: AppColors.popupOverlay,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 48),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(widget.message, textAlign: TextAlign.center,
                      style: AppStyles.bold22Black),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
