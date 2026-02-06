import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel2Stage1({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  RightLeftLevel2Stage1State createState() => RightLeftLevel2Stage1State();
}

class RightLeftLevel2Stage1State extends State<RightLeftLevel2Stage1> {
  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;
  bool _hasPlayedSound = false;

  late AudioPlayer _player;
  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.right_left_activityId,
        2,
        1,
      );

      activity = response;

      actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
      shadow = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
      anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

      // preload الصور
      await _preloadImages();

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // شغل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> _preloadImages() async {
    final urls = activity!.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in urls) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    // استخدام LayoutBuilder للحصول على حجم الشاشة
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double anchorWidth = 500 * scale;
        final double shadowLeft = 180 * scale;
        final double shadowTop = 280 * scale;
        final double shadowWidth = 250 * scale;
        final double actorRight = 40 * scale;
        final double actorBottom = -15 * scale;
        final double actorWidth = 220 * scale;
        final double actorFeedbackWidth = 220 * scale;

        return Stack(
          children: [
            /// ===== Anchor (خلفية ثابتة) =====
            Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
                fit: BoxFit.contain,
              ),
            ),

            /// ===== Shadow (مكان الإسقاط) =====
            Positioned(
              left: shadowLeft,
              top: shadowTop,
              child: DragTarget<String>(
                onWillAccept: (data) => data == shadow.id,
                onAccept: (data) {
                  setState(() {
                    isPlacedCorrectly = true;
                  });

                  WellDoneOverlay.show(context);

                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: shadowWidth,
                    height: shadowWidth,
                    child: isPlacedCorrectly
                        ? Image.network(
                      actor.imageUrl ?? '',
                      fit: BoxFit.contain,
                    )
                        : Image.network(
                      shadow.imageUrl ?? '',
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

            /// ===== Actor (اللي بيتسحب فعليًا) =====
            if (!isPlacedCorrectly)
              Positioned(
                right: actorRight,
                bottom: actorBottom,
                child: Draggable<String>(
                  data: actor.targetedZoneId,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: actorFeedbackWidth,
                      height: actorFeedbackWidth,
                      child: Image.network(
                        actor.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Container(
                    width: actorWidth,
                    height: actorWidth,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}