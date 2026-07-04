import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel1Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel1Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  NearFarLevel1Stage3State createState() => NearFarLevel1Stage3State();
}

class NearFarLevel1Stage3State extends State<NearFarLevel1Stage3>
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
        ApiConstants.near_far_activityId,
        1,
        3,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final double scale = screenWidth / 400;

        final double correctImageWidth = 200 * scale;
        final double wrongImageWidth = 300 * scale;
        final double spacingHeight = 30 * scale;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                double shakeValue = 0;
                if (_isAnimatingAnswer) {
                  shakeValue = screenWidth * 0.05 * sin(_animationController!.value * pi);
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
                child: Container(
                  width: correctImageWidth,
                  height: correctImageWidth,
                  child: Image.network(
                    lastElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            SizedBox(height: spacingHeight),

            GestureDetector(
              onTap: () {
                _handleWrongAnswer();
              },
              child: Container(
                width: wrongImageWidth,
                height: wrongImageWidth,
                child: Image.network(
                  firstElement.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
