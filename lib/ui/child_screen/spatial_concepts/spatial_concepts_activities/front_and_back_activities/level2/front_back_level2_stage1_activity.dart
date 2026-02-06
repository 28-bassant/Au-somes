import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<FrontBackLevel2Stage1Activity> createState() =>
      FrontBackLevel2Stage1ActivityState();
}

class FrontBackLevel2Stage1ActivityState extends State<FrontBackLevel2Stage1Activity> {
  late AudioPlayer _player;
  late ActivityResponse _activity;
  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.front_back_activityId,
      2,
      1,
    );

    // preload all images
    final urls = _activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in urls) {
      await precacheImage(NetworkImage(url!), context);
    }

    _imagesLoaded = true;
    return _activity;
  }

  Future<void> playSound() async {
    if (_activity.audioUrl == null || _activity.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity.audioUrl!));
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
      future: _loadActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !_imagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        final actor = _activity.elements!.firstWhere((e) => e.role == 'Actor');
        final shadow = _activity.elements!.firstWhere((e) => e.role == 'Shadow');
        final anchor = _activity.elements!.firstWhere((e) => e.role == 'Anchor');

        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        bool isPlacedCorrectly = false;

        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            // حساب النسب المئوية بناءً على التصميم الأصلي (افترضنا 400×800)
            final double anchorWidth = screenWidth * (500 / 400);  // 500 ÷ 400 = 1.25
            final double dragTargetLeft = screenWidth * (100 / 400);  // 100 ÷ 400 = 0.25
            final double dragTargetTop = screenHeight * (280 / 800);  // 280 ÷ 800 = 0.35
            final double dragTargetSize = screenWidth * (250 / 400);  // 250 ÷ 400 = 0.625
            final double draggableRight = screenWidth * (40 / 400);  // 40 ÷ 400 = 0.1
            final double draggableBottom = screenHeight * (-15 / 800);  // -15 ÷ 800 = -0.01875
            final double draggableSize = screenWidth * (220 / 400);  // 220 ÷ 400 = 0.55

            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // صورة الـ Anchor - في المنتصف
                    Positioned.fill(
                      child: Center(
                        child: Image.network(
                          anchor.imageUrl ?? '',
                          width: anchorWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // DragTarget
                    Positioned(
                      left: dragTargetLeft,
                      top: dragTargetTop-40,
                      child: DragTarget<String>(
                        onWillAccept: (data) => data == shadow.id,
                        onAccept: (_) {
                          setState(() => isPlacedCorrectly = true);
                          WellDoneOverlay.show(context);
                          Future.delayed(const Duration(seconds: 3), () {
                            widget.onNextStage?.call();
                          });
                        },
                        builder: (context, _, __) {
                          return isPlacedCorrectly
                              ? Image.network(
                            actor.imageUrl ?? '',
                            width: dragTargetSize,
                            fit: BoxFit.contain,
                          )
                              : Image.network(
                            shadow.imageUrl ?? '',
                            width: dragTargetSize,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),

                    // Draggable العنصر
                    if (!isPlacedCorrectly)
                      Positioned(
                        right: draggableRight,
                        bottom: draggableBottom,
                        child: Draggable<String>(
                          data: actor.targetedZoneId,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Image.network(
                              actor.imageUrl ?? '',
                              width: draggableSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                          childWhenDragging: const SizedBox(),
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: draggableSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}