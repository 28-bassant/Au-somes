import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity1Level1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity1Level1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity1Level1Stage2State createState() => Activity1Level1Stage2State();
}

class Activity1Level1Stage2State extends State<Activity1Level1Stage2>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;
  bool _usedHint = false;

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
        ApiConstants.sr_right_left_activityId,
        1,
        2,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;
        });

        await _preloadImages(activity);

        setState(() {
          _imagesLoaded = true;
        });

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
          _dataLoaded = true;
          _imagesLoaded = true;
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

    final List<Future> precacheFutures = [];
    for (final url in images) {
      precacheFutures.add(precacheImage(NetworkImage(url!), context));
    }
    await Future.wait(precacheFutures);
    print('All images preloaded successfully');
  }

  Future<void> playSound() async {
    if (!_dataLoaded || !_imagesLoaded) {
      print('Waiting for data and images to load before playing sound');
      return;
    }

    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    try {
      await _player.stop();
      await _player.play(UrlSource(_activity!.audioUrl!));
      print('Sound played successfully after data and images loaded');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void repeatSound() {
    if (_dataLoaded && _imagesLoaded) {
      playSound();
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

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingAnswer) {
          setState(() {
            _isAnimatingAnswer = false;
          });
          _animationController!.stop();
          _animationController!.value = 0;
        }
      });
    }
  }

  Future<void> _handleCorrectAnswer() async {
    setState(() {
      _wrongAttempts = 0;
      _isAnimatingAnswer = false;
    });

    _animationController?.stop();
    _animationController?.value = 0;

    await _logProgress();

    WellDoneOverlay.show(context);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onNextStage?.call();
      }
    });
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final anchorElement = _activity!.elements!
        .firstWhere((e) => e.role == 'Anchor');

    final correctElement = _activity!.elements!
        .firstWhere((e) => e.isCorrect == true);

    final wrongElement = _activity!.elements!
        .firstWhere((e) => e.isCorrect == false);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double anchorWidthPercent = 180 / 400;
            final double optionWidthPercent = 80 / 400;
            final double topPaddingPercent = 180 / 800;

            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;
            final double topPadding = constraints.maxHeight * topPaddingPercent;

            // استخدام Stack بدلاً من Row
            return Stack(
              children: [
                // Anchor في المنتصف
                Center(
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

                // ✅ الإجابة الصحيحة (على الجهة اليسرى) - عكس stage 2
                Positioned(
                  left: 25,
                  top: topPadding+200,
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
                      onTap: _handleCorrectAnswer,
                      child: Image.network(
                        correctElement.imageUrl ?? '',
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

                // ❌ الإجابة الخاطئة (على الجهة اليمنى) - عكس stage 2
                Positioned(
                  right: 25,
                  top: topPadding+200,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Image.network(
                      wrongElement.imageUrl ?? '',
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