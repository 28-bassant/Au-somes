import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel3Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel3Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<NearFarLevel3Stage2> createState() => NearFarLevel3Stage2State();
}

class NearFarLevel3Stage2State extends State<NearFarLevel3Stage2>
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.near_far_activityId,
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
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    await _player.stop();
    await _player.play(
      UrlSource(_activity!.deceptionInstructions![0]!),
    );
  }


  void repeatSound() => playSound();

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts >= 2) {
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
          _animationController!.stop();
          _animationController!.value = 0;
          setState(() {
            _isAnimatingAnswer = false;
          });
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

    final anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    final actorCorrect = _activity!.elements!.firstWhere((e) => e.role == 'Actor' && e.isCorrect == true);
    final actorWrong = _activity!.elements!.firstWhere((e) => e.role == 'Actor' && e.isCorrect == false);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double scale = min(screenWidth / 400, screenHeight / 800);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.network(
                anchor.imageUrl ?? '',
                width: 250 * scale,
              ),
            ),
          ),

          Positioned(
            right: 80 * scale + 120,
            top: 300 * scale - 40,
            child: GestureDetector(
              onTap: _handleWrongAnswer,
              child: Image.network(
                actorCorrect.imageUrl ?? '',
                width: 80 * scale,

              ),
            ),
          ),

          Positioned(
            top: 160 * scale + 80,
            right: 40 * scale - 40,

            child: AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                double offsetX = 0;
                if (_isAnimatingAnswer) {
                  offsetX = 10 * sin(_animationController!.value * pi); // اهتزاز
                }
                return Transform.translate(offset: Offset(offsetX, 0), child: child);
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
                    widget.onNextStage?.call();
                  });
                },
                child: Image.network(
                  actorWrong.imageUrl ?? '',
                  width: 200 * scale * 0.5,
                  height: 400 * scale * 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
