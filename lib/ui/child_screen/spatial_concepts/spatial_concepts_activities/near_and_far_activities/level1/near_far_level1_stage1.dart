import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<NearFarLevel1Stage1> createState() => NearFarLevel1Stage1State();
}

class NearFarLevel1Stage1State extends State<NearFarLevel1Stage1> {
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
      1,
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

        return LayoutBuilder(
          builder: (context, constraints) {
            // افتراض أن الشاشة الأصلية 400x800
            final double baseWidth = 200.0;
            final double baseHeight = 800.0;

            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // حساب عامل التحجيم بناءً على أصغر نسبة
            final double widthRatio = screenWidth / baseWidth;
            final double heightRatio = screenHeight / baseHeight;
            final double scale = min(widthRatio, heightRatio);

            // تحويل القيم الثابتة إلى قيم متجاوبة
            final double responsiveRight = 90 * scale;
            final double responsiveTop = 340 * scale;
            final double responsiveAnchorWidth = 100 * scale;

            final double responsiveImageTop = 200 * scale;
            final double responsiveImageLeft = 40 * scale;
            final double responsiveImageWidth = 300 * scale;
            final double responsiveImageHeight = 400 * scale;

            return Stack(
              children: [
                // Anchor
                Positioned(
                  right: responsiveRight,
                  top: responsiveTop+60,
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
                    onTapDown: (TapDownDetails details) {
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
                      width: responsiveImageWidth * 1.2 ,
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