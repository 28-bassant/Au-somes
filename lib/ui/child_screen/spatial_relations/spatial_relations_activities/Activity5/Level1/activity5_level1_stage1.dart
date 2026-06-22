import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity5Level1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity5Level1Stage1({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<Activity5Level1Stage1> createState() =>
      Activity5Level1Stage1State();
}

class Activity5Level1Stage1State extends State<Activity5Level1Stage1> {
  late AudioPlayer _player;
  late ActivityResponse _activity;
  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;
  bool _usedHint = false;
  bool _progressSent = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.sr_near_far_activityId,
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
  Future<void> _logProgress() async {
    if (_progressSent) return;

    try {
      _progressSent = true;

      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity.phaseId}");
      print("RESULT = ${result?.isPassed}");

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
      }
    } catch (e) {
      print("Progress error: $e");
    }
  }
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
                    final double shadowSizePercent = 500 / 400;     // 125% من العرض المرجعي (أكبر من الشاشة)
                    final double targetSizePercent = 40 / 400;      // 10% من العرض المرجعي
                    final double actorSizePercent = 40 / 400;       // 10% من العرض المرجعي

                    // نسب المواقع من الكود الأصلي
                    final double targetLeftPercent = 210 / 400;     // 52.5% من العرض
                    final double targetTopPercent = 330 / 680;      // 41.25% من الارتفاع

                    final double actorRightPercent = 40 / 400;      // 10% من العرض
                    final double actorBottomPercent = 50 / 800;     // 6.25% من الارتفاع

                    // حساب الأحجام والمواقع الفعلية
                    final double shadowSize = constraints.maxWidth * shadowSizePercent;
                    final double targetSize = constraints.maxWidth * targetSizePercent;
                    final double actorSize = constraints.maxWidth * actorSizePercent;

                    final double targetLeft = constraints.maxWidth * targetLeftPercent;
                    final double targetTop = constraints.maxHeight * targetTopPercent;

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
                          left: targetLeft-20,
                          top: targetTop-15,
                          child: Container(
                            width: targetSize*1.5,
                            height: targetSize*1.7,
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Colors.black,
                            //     width: 2.0,
                            //   ),
                            // ),
                            child: DragTarget<String>(
                              onWillAccept: (data) => data == actor.targetedZoneId,
                              onAccept: (data) async {
                                setState(() {
                                  isPlacedCorrectly = true;
                                });

                                await _logProgress();

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
                                    width: targetSize,
                                    height: targetSize,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: targetSize,
                                        height: targetSize,
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
