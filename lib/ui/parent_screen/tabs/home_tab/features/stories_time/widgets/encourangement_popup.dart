import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../../../../utils/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
