import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const FrontBackLevel1Stage2Activity({Key? key, this.onNextStage})
      : super(key: key);

  @override
  State<FrontBackLevel1Stage2Activity> createState() =>
      FrontBackLevel1Stage2ActivityState();
}

class FrontBackLevel1Stage2ActivityState
    extends State<FrontBackLevel1Stage2Activity>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

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
        ApiConstants.front_back_activityId,
        1,
        2,
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

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

    final firstElement = _activity!.elements!.first;
    final lastElement = _activity!.elements!.last;
    final anchorElement =
    _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              right: screenWidth * 0.62,
              bottom: screenHeight * 0.35,
              child: GestureDetector(
                onTap: () {
                  _handleWrongAnswer();
                },
                child: Image.network(
                  firstElement.imageUrl ?? '',
                  width: screenWidth * 0.375,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned.fill(
              child: FittedBox(
                child: IgnorePointer(
                  child: Image.network(
                      anchorElement.imageUrl ?? ''),
                ),
              ),
            ),



            Positioned(
              left: screenWidth * 0.375,
              top: screenHeight * 0.375,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = 12 *
                        sin(_animationController!.value *  pi );
                  }

                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _wrongAttempts = 0;
                      _isAnimatingAnswer = false;
                    });

                    _animationController?.stop();
                    _animationController?.value = 0;

                    /// ===== LOG PROGRESS =====
                    final result = await ApiManager.logAttemptStatus(
                      phaseId: _activity!.phaseId!,
                      userHint: false,
                    );

                    /// (اختياري) تحديث السجل العام للتقدم
                    if (result?.isPassed == true) {
                      await ApiManager.getProgressSummary();
                    }

                    WellDoneOverlay.show(context);

                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        widget.onNextStage?.call();
                      }
                    });
                  },
                  child: Image.network(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    lastElement.imageUrl ?? '',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
