import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity3Level1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity3Level1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity3Level1Stage1State createState() => Activity3Level1Stage1State();
}

class Activity3Level1Stage1State extends State<Activity3Level1Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;

  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  bool isCorrectPlaced = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.sr_inside_outside_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        await _preloadImages(activity);

        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  void _handleWrongAnswer() {
    if (_wrongAttempts == 0) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 1) {
      _startAnswerAnimation();
    }
    _wrongAttempts++;
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isAnimatingAnswer = false;
          });
          _animationController!.stop();
          _animationController!.value = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    final actorElement = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final shadowElement = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchorWidthPercent = 250 / 400;        // 62.5% من العرض المرجعي
            final double shadowWidthPercent = 100 / 400;        // 25% من العرض المرجعي
            final double actorWidthPercent = 60 / 400;          // 15% من العرض المرجعي
            final double smallActorWidthPercent = 50 / 400;     // 12.5% من العرض المرجعي

            // نسب المواقع من الكود الأصلي
            final double anchorTopPercent = 240 / 800;          // 30% من الارتفاع

            final double dragTargetLeftPercent = 20 / 400;      // 5% من العرض
            final double dragTargetTopPercent = 20 / 800;       // 2.5% من الارتفاع
            final double actorTopInShadowPercent = 40 / 800;    // 5% من الارتفاع

            final double wrong1RightPercent = 20 / 400;         // 5% من العرض
            final double wrong1TopPercent = 300 / 800;          // 37.5% من الارتفاع

            final double wrong2LeftPercent = 20 / 400;          // 5% من العرض
            final double wrong2TopPercent = 300 / 800;          // 37.5% من الارتفاع

            final double wrong3LeftPercent = 110 / 400;         // 27.5% من العرض
            final double wrong3BottomPercent = 180 / 800;       // 22.5% من الارتفاع

            final double correctLeftPercent = 180 / 400;        // 45% من العرض
            final double correctTopPercent = 150 / 800;         // 18.75% من الارتفاع

            // حساب الأحجام والمواقع الفعلية
            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double shadowWidth = constraints.maxWidth * shadowWidthPercent;
            final double actorWidth = constraints.maxWidth * actorWidthPercent;
            final double smallActorWidth = constraints.maxWidth * smallActorWidthPercent;

            final double anchorTop = constraints.maxHeight * anchorTopPercent;

            final double dragTargetLeft = constraints.maxWidth * dragTargetLeftPercent;
            final double dragTargetTop = constraints.maxHeight * dragTargetTopPercent;
            final double actorTopInShadow = constraints.maxHeight * actorTopInShadowPercent;

            final double wrong1Right = constraints.maxWidth * wrong1RightPercent;
            final double wrong1Top = constraints.maxHeight * wrong1TopPercent;

            final double wrong2Left = constraints.maxWidth * wrong2LeftPercent;
            final double wrong2Top = constraints.maxHeight * wrong2TopPercent;

            final double wrong3Left = constraints.maxWidth * wrong3LeftPercent;
            final double wrong3Bottom = constraints.maxHeight * wrong3BottomPercent;

            final double correctLeft = constraints.maxWidth * correctLeftPercent;
            final double correctTop = constraints.maxHeight * correctTopPercent;

            return Stack(
              alignment: Alignment.center,
              children: [
                // ⚓ Anchor
                Positioned(
                  top: anchorTop,
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    width: anchorWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: anchorWidth,
                        height: anchorWidth,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),

                // ✅ DragTarget مع الصورة تحت الشادو
                Positioned(
                  left: dragTargetLeft,
                  top: dragTargetTop,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isCorrectPlaced)
                            Positioned(
                              top: actorTopInShadow,
                              child: Image.network(
                                actorElement.imageUrl ?? '',
                                width: actorWidth,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: actorWidth,
                                    height: actorWidth,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          Image.network(
                            shadowElement.imageUrl ?? '',
                            width: shadowWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: shadowWidth,
                                height: shadowWidth,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    onWillAccept: (_) => true,
                    onAccept: (data) {
                      if (data == 'correct') {
                        setState(() {
                          isCorrectPlaced = true;
                          _wrongAttempts = 0;
                          _isAnimatingAnswer = false;
                        });
                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) widget.onNextStage?.call();
                        });
                      } else {
                        _handleWrongAnswer();
                      }
                    },
                  ),
                ),

                // ❌ العناصر الخاطئة الثلاث
                Positioned(
                  right: wrong1Right,
                  top: wrong1Top,
                  child: Draggable(
                    data: 'wrong1',
                    feedback: Image.network(
                      actorElement.imageUrl ?? '',
                      width: actorWidth,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: actorWidth,
                      ),
                    ),
                    child: Image.network(
                      actorElement.imageUrl ?? '',
                      width: actorWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: actorWidth,
                          height: actorWidth,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                    onDragEnd: (_) {},
                  ),
                ),

                Positioned(
                  left: wrong2Left,
                  top: wrong2Top,
                  child: Draggable(
                    data: 'wrong2',
                    feedback: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: actorWidth,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.network(
                          actorElement.imageUrl ?? '',
                          width: actorWidth,
                        ),
                      ),
                    ),
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: actorWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: actorWidth,
                            height: actorWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    onDragEnd: (_) {},
                  ),
                ),

                Positioned(
                  left: wrong3Left,
                  bottom: wrong3Bottom,
                  child: Draggable(
                    data: 'wrong3',
                    feedback: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: smallActorWidth,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.network(
                          actorElement.imageUrl ?? '',
                          width: smallActorWidth,
                        ),
                      ),
                    ),
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: smallActorWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: smallActorWidth,
                            height: smallActorWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    onDragEnd: (_) {},
                  ),
                ),

                // ✅ العنصر الصحيح مع Animation
                if (!isCorrectPlaced)
                  Positioned(
                    left: correctLeft,
                    top: correctTop,
                    child: AnimatedBuilder(
                      animation: _animationController!,
                      builder: (context, child) {
                        double shakeValue = 0;
                        if (_isAnimatingAnswer) {
                          shakeValue = 15 * sin(_animationController!.value * pi);
                        }
                        return Transform.translate(
                          offset: Offset(shakeValue, 0),
                          child: child,
                        );
                      },
                      child: Draggable(
                        data: 'correct',
                        feedback: Image.network(
                          actorElement.imageUrl ?? '',
                          width: actorWidth,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: Image.network(
                            actorElement.imageUrl ?? '',
                            width: actorWidth,
                          ),
                        ),
                        child: Image.network(
                          actorElement.imageUrl ?? '',
                          width: actorWidth,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: actorWidth,
                              height: actorWidth,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}