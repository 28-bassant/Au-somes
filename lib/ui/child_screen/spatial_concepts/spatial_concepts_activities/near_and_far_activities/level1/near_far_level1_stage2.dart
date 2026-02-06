import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<NearFarLevel1Stage2> createState() => NearFarLevel1Stage2State();
}

class NearFarLevel1Stage2State extends State<NearFarLevel1Stage2> {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _hasPlayedSound = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> fetchAndPreload() async {
    final activity = await ApiManager.getActivity(
      ApiConstants.near_far_activityId,
      1,
      2,
    );

    // preload الصور
    for (var element in activity.elements!) {
      if (element.imageUrl != null && element.imageUrl!.isNotEmpty) {
        await precacheImage(NetworkImage(element.imageUrl!), context);
      }
    }

    _activity = activity;
    return activity;
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivityResponse>(
      future: fetchAndPreload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        final activity = snapshot.data!;
        final firstElement = activity.elements!.first;
        final anchorElement = activity.elements!.firstWhere((e) => e.role == 'Anchor');

        // تشغيل الصوت مرة واحدة فقط
        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        // افتراض أن التصميم الأصلي على شاشة 400x800
        final double designWidth = 400.0;
        final double designHeight = 800.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // حساب عامل التحجيم مع الحفاظ على النسبة
            final double widthRatio = screenWidth / designWidth;
            final double heightRatio = screenHeight / designHeight;
            final double scale = min(widthRatio, heightRatio);

            // تحويل القيم الثابتة إلى قيم متجاوبة
            final double responsiveRight = 20 * scale;
            final double responsiveTop = 310 * scale;
            final double responsiveAnchorWidth = 240 * scale;

            final double responsiveImageTop = 250 * scale;
            final double responsiveImageLeft = 20 * scale;
            final double responsiveImageWidth = 300 * scale;
            final double responsiveImageHeight = 400 * scale;

            return Stack(
              children: [
                // Anchor
                Positioned(
                  right: responsiveRight,
                  top: responsiveTop+40,
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    width: responsiveAnchorWidth,
                  ),
                ),

                // الصورة الأساسية مع منطقة الصح
                Positioned(
                  top: responsiveImageTop,
                  left: responsiveImageLeft,
                  child: GestureDetector(
                    onTapDown: (details) {
                      final localPos = details.localPosition;

                      final correctArea = Rect.fromLTWH(
                        responsiveImageWidth * 0.3,
                        0,
                        responsiveImageWidth * 0.4,
                        responsiveImageHeight,
                      );

                      if (correctArea.contains(localPos)) {
                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          widget.onNextStage?.call();
                        });
                      }
                    },
                    child: Image.network(
                      firstElement.imageUrl ?? '',
                      width: responsiveImageWidth,
                      height: responsiveImageHeight,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}