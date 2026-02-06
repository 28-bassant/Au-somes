import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel2Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel2Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel2Stage2State createState() => RightLeftLevel2Stage2State();
}

class RightLeftLevel2Stage2State extends State<RightLeftLevel2Stage2> {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // تحميل النشاط مرة واحدة في البداية
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.right_left_activityId,
        2,
        2,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // حفظ العناصر
        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = activity.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = activity.elements!.firstWhere((e) => e.role == 'Anchor');

        // تحميل الصور
        await _preloadImages(activity);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }

    _imagesLoaded = true;
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
    // إذا كان في مرحلة التحميل
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // إذا كان هناك خطأ في تحميل النشاط
    if (_activity == null) {
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
        final double shadowLeft = 140 * scale;
        final double shadowTop = 200 * scale;
        final double shadowWidth = 300 * scale;
        final double actorPlacedWidth = 250 * scale;
        final double actorRight = 20 * scale;
        final double actorBottom = -10 * scale;
        final double actorWidth = 150 * scale;
        final double actorFeedbackWidth = 300 * scale;

        return Stack(
          children: [
            // Anchor (خلفية ثابتة)
            Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
                fit: BoxFit.contain,
              ),
            ),

            // Shadow (مكان الإسقاط)
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
                    width: isPlacedCorrectly ? actorPlacedWidth : shadowWidth,
                    height: isPlacedCorrectly ? actorPlacedWidth : shadowWidth,
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

            // Actor (اللي بيتسحب فعليًا)
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
