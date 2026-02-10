import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  BetweenLevel2Stage1ActivityState createState() =>
      BetweenLevel2Stage1ActivityState();
}

class BetweenLevel2Stage1ActivityState
    extends State<BetweenLevel2Stage1Activity> {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        // البحث عن العناصر
        actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        // تحميل الصور أولاً
        await _preloadImages(_activity!);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double anchorWidth = 500 * scale;
        final double shadowLeft = 120 * scale;
        final double shadowTop = 280 * scale;
        final double shadowWidth = 175 * scale;
        final double actorPlacedWidth = 200 * scale;
        final double actorPlacedOffsetX = -20 * scale;
        final double actorPlacedOffsetY = -30 * scale;
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
                  return isPlacedCorrectly
                      ? Transform.translate(
                    offset: Offset(actorPlacedOffsetX, actorPlacedOffsetY),
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: actorPlacedWidth,
                    ),
                  )
                      : Image.network(
                    shadow.imageUrl ?? '',
                    width: shadowWidth,
                    color: Colors.black,
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
                  /// 👈 ده اللي الطفل شايفه وهو بيسحب
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: actorFeedbackWidth,
                    ),
                  ),

                  /// 👈 نخفي الأصل
                  childWhenDragging: const SizedBox(),

                  /// 👈 الشكل قبل السحب
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: actorWidth,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}