import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ConfettiOverlayWidget extends StatefulWidget {
  const ConfettiOverlayWidget({super.key});

  @override
  State<ConfettiOverlayWidget> createState() => _ConfettiOverlayWidgetState();
}

class _ConfettiOverlayWidgetState extends State<ConfettiOverlayWidget> {
  late ConfettiController _leftController;
  late ConfettiController _rightController;

  @override
  void initState() {
    super.initState();

    _leftController = ConfettiController(duration: const Duration(seconds: 6));
    _rightController = ConfettiController(duration: const Duration(seconds: 6));

    _leftController.play();
    _rightController.play();
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  /// دالة رسم نجمة حقيقية
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;

    final path = Path();
    final angle = degToRad(360 / numberOfPoints);
    final halfAngle = angle / 2;

    path.moveTo(halfWidth, 0);

    for (int i = 0; i < numberOfPoints; i++) {
      path.lineTo(
        halfWidth + externalRadius * cos(angle * i - pi/2),
        halfWidth + externalRadius * sin(angle * i - pi/2),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(angle * i + halfAngle - pi/2),
        halfWidth + internalRadius * sin(angle * i + halfAngle - pi/2),
      );
    }

    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [

          // من الأعلى يسار
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _leftController,
              blastDirection: pi / 4, // 45 درجة لتنتشر للشاشة
              blastDirectionality: BlastDirectionality.directional,
              emissionFrequency: 0.08,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              createParticlePath: drawStar,
              colors: const [
                AppColors.mintGreen,
                AppColors.softBlue,
                AppColors.lightPastelBlue,
                AppColors.pastelPink,
                AppColors.greyColor,
              ],
            ),
          ),

          // من الأعلى يمين
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _rightController,
              blastDirection: 3 * pi / 4, // 135 درجة لتنتشر للشاشة
              blastDirectionality: BlastDirectionality.directional,
              emissionFrequency: 0.08,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              createParticlePath: drawStar,
              colors: const [
                AppColors.mintGreen,
                AppColors.softBlue,
                AppColors.lightPastelBlue,
                AppColors.pastelPink,
                AppColors.greyColor,
              ],
            ),
          ),

          // الرسالة في المنتصف
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.complete_activity,
                textAlign: TextAlign.center,
                style: AppStyles.bold16MintGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}