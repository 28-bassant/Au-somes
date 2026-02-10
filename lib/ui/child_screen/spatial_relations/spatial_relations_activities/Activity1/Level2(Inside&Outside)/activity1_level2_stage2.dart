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

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // ⚓ Anchor في النص
          Image.network(
            anchorElement.imageUrl ?? '',
            width: 300,
          ),

          // ✅ الشمال = إجابة صح
          Positioned(
            left: 40,
            top: 420,
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
                  width: 80,
                ),
              ),
            ),
          ),

          // ❌ اليمين = إجابة غلط + animation
          Positioned(
            right: 160,
            top: 260,
            child: GestureDetector(
              onTap: _handleWrongAnswer,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
