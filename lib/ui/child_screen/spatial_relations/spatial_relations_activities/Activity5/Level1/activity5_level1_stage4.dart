import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity5Level1Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity5Level1Stage4({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<Activity5Level1Stage4> createState() =>
      Activity5Level1Stage4State();
}

class Activity5Level1Stage4State extends State<Activity5Level1Stage4> {
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
      ApiConstants.sr_front_back_activityId,
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

        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        bool isPlacedCorrectly = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // حساب النسب المئوية بناءً على أبعاد الشاشة
                    final double shadowSizePercent = 500 / 400;        // 125% من العرض المرجعي

                    // نسب منطقة الإسقاط
                    final double targetWidthPercent = 140 / 400;       // 35% من العرض المرجعي
                    final double targetHeightPercent = 160 / 800;      // 20% من الارتفاع المرجعي
                    final double targetLeftPercent = 250 / 440;        // 62.5% من العرض
                    final double targetTopPercent = 360 / 680;         // 45% من الارتفاع

                    // نسب الصورة داخل منطقة الإسقاط
                    final double targetImageWidthPercent = 80 / 400;   // 20% من العرض المرجعي
                    final double targetImageHeightPercent = 120 / 800; // 15% من الارتفاع المرجعي

                    // نسب العنصر القابل للسحب
                    final double actorFeedbackSizePercent = 120 / 400; // 30% من العرض المرجعي
                    final double actorSizePercent = 50 / 400;          // 12.5% من العرض المرجعي
                    final double actorRightPercent = 40 / 400;         // 10% من العرض
                    final double actorBottomPercent = 0 / 800;         // 0% من الارتفاع (أسفل الشاشة)

                    // حساب الأحجام والمواقع الفعلية
                    final double shadowSize = constraints.maxWidth * shadowSizePercent;

                    final double targetWidth = constraints.maxWidth * targetWidthPercent;
                    final double targetHeight = constraints.maxHeight * targetHeightPercent;
                    final double targetLeft = constraints.maxWidth * targetLeftPercent;
                    final double targetTop = constraints.maxHeight * targetTopPercent;

                    final double targetImageWidth = constraints.maxWidth * targetImageWidthPercent;
                    final double targetImageHeight = constraints.maxHeight * targetImageHeightPercent;

                    final double actorFeedbackSize = constraints.maxWidth * actorFeedbackSizePercent;
                    final double actorSize = constraints.maxWidth * actorSizePercent;
                    final double actorRight = constraints.maxWidth * actorRightPercent;
                    final double actorBottom = constraints.maxHeight * actorBottomPercent;

                    return Stack(
                      children: [
                        // صورة الـ Shadow - في الخلفية
                        Center(
                          child: Image.network(
                            shadow.imageUrl ?? '',
                            width: shadowSize,
                            height: shadowSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: shadowSize,
                                height: shadowSize,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),

                        // DragTarget - حاوية فارغة
                        Positioned(
                          left: targetLeft,
                          top: targetTop,
                          child: Container(
                            width: targetWidth,
                            height: targetHeight,
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Colors.black,
                            //     width: 2.0,
                            //   ),
                            // ),
                            child: DragTarget<String>(
                              onWillAccept: (data) => data == actor.targetedZoneId,
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
                                return Center(
                                  child: isPlacedCorrectly
                                      ? Image.network(
                                    actor.imageUrl ?? '',
                                    width: targetImageWidth,
                                    height: targetImageHeight,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: targetImageWidth,
                                        height: targetImageHeight,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  )
                                      : Container(),
                                );
                              },
                            ),
                          ),
                        ),

                        // Draggable العنصر
                        if (!isPlacedCorrectly)
                          Positioned(
                            right: actorRight,
                            bottom: actorBottom,
                            child: Draggable<String>(
                              data: actor.targetedZoneId,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Image.network(
                                    actor.imageUrl ?? '',
                                    width: actorFeedbackSize,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: actorFeedbackSize,
                                        height: actorFeedbackSize,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: Image.network(
                                  actor.imageUrl ?? '',
                                  width: actorSize,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: actorSize,
                                      height: actorSize,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                              child: Image.network(
                                actor.imageUrl ?? '',
                                width: actorSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: actorSize,
                                    height: actorSize,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}