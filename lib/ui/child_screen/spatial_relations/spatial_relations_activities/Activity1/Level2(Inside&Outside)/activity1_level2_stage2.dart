import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity1Level2Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity1Level2Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity1Level2Stage2State createState() => Activity1Level2Stage2State();
}

class Activity1Level2Stage2State extends State<Activity1Level2Stage2>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;

  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

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
        1,
        2,
      );

      if (!mounted) return;

      setState(() {
        _activity = activity;
      });

      if (!_hasPlayedSound) {
        await playSound();
        _hasPlayedSound = true;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }
  void repeatSound() => playSound();

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startAnswerAnimation();
    }
  }

  void _startAnswerAnimation() {
    if (_isAnimatingAnswer) return;

    setState(() {
      _isAnimatingAnswer = true;
    });

    _animationController!.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _animationController!.stop();
      _animationController!.value = 0;
      setState(() {
        _isAnimatingAnswer = false;
      });
    });
  }

  void _handleCorrectAnswer() {
    setState(() {
      _wrongAttempts = 0;
      _isAnimatingAnswer = false;
    });

    _animationController?.stop();
    _animationController?.value = 0;

    WellDoneOverlay.show(context);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onNextStage?.call();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController?.dispose();
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

    final anchorElement =
    _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final actorElement =
    _activity!.elements!.firstWhere((e) => e.isCorrect == true);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchorWidthPercent = 300 / 400;    // 75% من العرض المرجعي
            final double optionWidthPercent = 80 / 400;     // 20% من العرض المرجعي

            // نسب المواقع من الكود الأصلي
            final double leftPositionPercent = 40 / 400;        // 10% من العرض
            final double rightPositionPercent = 160 / 400;      // 40% من العرض
            final double topFirstPositionPercent = 420 / 800;   // 52.5% من الارتفاع
            final double topSecondPositionPercent = 260 / 800;  // 32.5% من الارتفاع

            // حساب الأحجام والمواقع الفعلية
            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;

            final double leftPosition = constraints.maxWidth * leftPositionPercent;
            final double rightPosition = constraints.maxWidth * rightPositionPercent;
            final double topFirstPosition = constraints.maxHeight * topFirstPositionPercent;
            final double topSecondPosition = constraints.maxHeight * topSecondPositionPercent;

            return Stack(
              alignment: Alignment.center,
              children: [

                // ⚓ Anchor في النص
                Image.network(
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

                // ✅ الشمال = إجابة صح + Animation
                Positioned(
                  left: leftPosition,
                  top: topFirstPosition,
                  child: AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      double shakeValue = 0;
                      if (_isAnimatingAnswer) {
                        shakeValue = 20 * sin(_animationController!.value * pi);
                      }

                      return Transform.translate(
                        offset: Offset(shakeValue, 0),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _wrongAttempts = 0;
                          _isAnimatingAnswer = false;
                        });
                        _animationController?.stop();
                        _animationController?.value = 0;

                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            widget.onNextStage?.call();
                          }
                        });
                      },
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: optionWidth,
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
                ),

                // ❌ اليمين = إجابة غلط
                Positioned(
                  right: rightPosition,
                  top: topSecondPosition+36,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Image.network(
                      actorElement.imageUrl ?? '',
                      width: optionWidth,
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
              ],
            );
          },
        ),
      ),
    );
  }
}