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
  bool _hasPlayedDeceptionSound = false;
  bool _hasPlayedAudioSound = false;

  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  bool isCorrectPlaced = false;
  bool isCorrectSelected = false;
  bool _usedHint = false;
  // متغيرات لتخزين العناصر
  late Map<String, dynamic> elements;

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
          _extractElements(activity);
        });

        await _preloadImages(activity);

        if (!_hasPlayedDeceptionSound) {
          await playDeceptionSound();
          _hasPlayedDeceptionSound = true;
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

  void _extractElements(ActivityResponse activity) {
    final anchor = activity.elements!.firstWhere((e) => e.role == 'Anchor');
    final shadow = activity.elements!.firstWhere((e) => e.role == 'Shadow');

    final allActors = activity.elements!
        .where((e) => e.role == 'Actor')
        .toList();

    final correct = allActors.firstWhere(
          (e) => e.targetedZoneId != null,
      orElse: () => allActors[0],
    );

    final wrong = allActors
        .where((e) => e.id != correct.id)
        .toList();

    elements = {
      'anchor': anchor,
      'shadow': shadow,
      'correct': correct,
      'wrong': wrong,
    };
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

  Future<void> playDeceptionSound() async {
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.deceptionInstructions![0]));
  }

  Future<void> playAudioSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() {
    if (isCorrectSelected) {
      playAudioSound();
    } else {
      playDeceptionSound();
    }
  }

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
      _usedHint = true;
    });


    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startAnswerAnimation();
    }
  }

  void _handleCorrectSelection() {
    setState(() {
      isCorrectSelected = true;
      _wrongAttempts = 0;
      _isAnimatingAnswer = false;
    });
    _animationController?.stop();
    _animationController?.value = 0;

    playAudioSound();
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
  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity!.phaseId}");
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
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));
    if (elements.isEmpty) return const Center(child: Text('Error loading elements'));

    final anchorElement = elements['anchor'];
    final shadowElement = elements['shadow'];
    final correctElement = elements['correct'];
    final wrongElements = elements['wrong'] as List;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double anchorWidthPercent = 250 / 400;
            final double shadowWidthPercent = 100 / 400;
            final double actorWidthPercent = 60 / 400;
            final double smallActorWidthPercent = 50 / 400;
            final double optionWidthPercent = 50 / 400;

            final double anchorTopPercent = 240 / 800;

            final double dragTargetLeftPercent = 20 / 400;
            final double dragTargetTopPercent = 20 / 800;
            final double actorTopInShadowPercent = 40 / 800;

            final double topWrongPositionPercent = 120 / 800;
            final double leftWrongPositionPercent = 20 / 400;
            final double topLeftPositionPercent = 240 / 550;
            final double bottomLeftPositionPercent = 110 / 400;
            final double bottomPositionPercent = 180 / 800;

            final double rightTopPositionPercent = 160 / 400;

            final double rightCorrectPositionPercent = 20 / 400;
            final double topCorrectPositionPercent = 280 / 650;

            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double shadowWidth = constraints.maxWidth * shadowWidthPercent;
            final double actorWidth = constraints.maxWidth * actorWidthPercent;
            final double smallActorWidth = constraints.maxWidth * smallActorWidthPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;

            final double anchorTop = constraints.maxHeight * anchorTopPercent;

            final double dragTargetLeft = constraints.maxWidth * dragTargetLeftPercent;
            final double dragTargetTop = constraints.maxHeight * dragTargetTopPercent;
            final double actorTopInShadow = constraints.maxHeight * actorTopInShadowPercent;

            final double topWrongPosition = constraints.maxHeight * topWrongPositionPercent;
            final double leftWrongPosition = constraints.maxWidth * leftWrongPositionPercent;
            final double topLeftPosition = constraints.maxHeight * topLeftPositionPercent;
            final double bottomLeftPosition = constraints.maxWidth * bottomLeftPositionPercent;
            final double bottomPosition = constraints.maxHeight * bottomPositionPercent;

            final double rightTopPosition = constraints.maxWidth * rightTopPositionPercent;

            final double rightCorrectPosition = constraints.maxWidth * rightCorrectPositionPercent;
            final double topCorrectPosition = constraints.maxHeight * topCorrectPositionPercent;

            return Stack(
              children: [
                // Anchor
                Positioned(
                  top: anchorTop,
                  left: 0,
                  right: 0,
                  child: Center(
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
                ),

                // Shadow (القفص)
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
                                correctElement.imageUrl ?? '',
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
                    onWillAccept: (data) {
                      return data == 'correct' && isCorrectSelected && !isCorrectPlaced;
                    },
                    onAccept: (data) async {
                      setState(() {
                        isCorrectPlaced = true;
                      });

                      await _logProgress();

                      WellDoneOverlay.show(context);

                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) widget.onNextStage?.call();
                      });
                    },
                  ),
                ),

                // أول عنصر غلط (فوق - يمين)
                if (wrongElements.length > 0)
                  Positioned(
                    right: rightCorrectPosition,
                    top: topCorrectPosition,
                    child: GestureDetector(
                      onTap: !isCorrectSelected ? _handleWrongAnswer : null,
                      child: Image.network(
                        wrongElements[0].imageUrl ?? '',
                        width: optionWidth * 1.5,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: optionWidth,
                            height: optionWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),

                // تاني عنصر غلط (شمال)
                if (wrongElements.length > 1)
                  Positioned(
                    left: leftWrongPosition,
                    top: topLeftPosition - 20,
                    child: GestureDetector(
                      onTap: !isCorrectSelected ? _handleWrongAnswer : null,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.network(
                          wrongElements[2].imageUrl ?? '',
                          width: optionWidth * 1.3,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: optionWidth * 1.3,
                              height: optionWidth * 1.3,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // تالت عنصر غلط (تحت)
                if (wrongElements.length > 2)
                  Positioned(
                    left: bottomLeftPosition,
                    bottom: bottomPosition,
                    child: GestureDetector(
                      onTap: !isCorrectSelected ? _handleWrongAnswer : null,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.network(
                          wrongElements[1].imageUrl ?? '',
                          width: optionWidth * 1.5,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: optionWidth * 1.5,
                              height: optionWidth * 1.5,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // العنصر الصحيح (فوق)
                if (!isCorrectPlaced)
                  Positioned(
                    right: rightTopPosition,
                    top: topWrongPosition,
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
                      child: isCorrectSelected
                          ? Draggable(
                        data: 'correct',
                        feedback: Image.network(
                          correctElement.imageUrl ?? '',
                          width: optionWidth * 1.5,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: Image.network(
                            correctElement.imageUrl ?? '',
                            width: optionWidth * 1.5,
                          ),
                        ),
                        child: Image.network(
                          correctElement.imageUrl ?? '',
                          width: optionWidth * 1.5,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: optionWidth * 1.5,
                              height: optionWidth * 1.5,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      )
                          : GestureDetector(
                        onTap: _handleCorrectSelection,
                        child: Image.network(
                          correctElement.imageUrl ?? '',
                          width: optionWidth * 1.5,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: optionWidth * 1.5,
                              height: optionWidth * 1.5,
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