import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel3Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel3Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel3Stage3State createState() => RightLeftLevel3Stage3State();
}

class RightLeftLevel3Stage3State extends State<RightLeftLevel3Stage3>
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
        ApiConstants.right_left_activityId,
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

    final rightElement = _activity!.elements![0];
    final leftElement = _activity!.elements![1];
    final anchorElement =
    _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final Size screenSize = MediaQuery.of(context).size;
    final double scale = min(screenSize.width / 400, screenSize.height / 800);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenSize.width,
          height: screenSize.height * .8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Transform.scale(
                  scaleX: -1,
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    width: 320 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController!,
                        builder: (context, child) {
                          double shakeValue = 0;
                          if (_isAnimatingAnswer) {
                            shakeValue = screenSize.width *
                                0.03 *
                                sin(_animationController!.value * pi);
                          }

                          return Transform.translate(
                            offset: Offset(shakeValue, 0),
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTapDown: (details) {
                            final local = details.localPosition;
                            final double imageWidth = 180 * scale;
                            final double imageHeight = 180 * scale;

                            // المنطقة الصحيحة أصبحت في الشمال
                            final correctArea = Rect.fromLTWH(
                              0,
                              0,
                              imageWidth * 0.6,
                              imageHeight,
                            );

                            if (correctArea.contains(local)) {
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
                          },
                          child: SizedBox(
                            width: 180 * scale,
                            height: 180 * scale,
                            child: Stack(
                              children: [
                                Image.network(
                                  leftElement.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),

                                // منطقة المساعدة أصبحت في الشمال
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    width: 180 * scale * 0.6,
                                    height: 180 * scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          _handleWrongAnswer();
                        },
                        child: Container(
                          width: 180 * scale,
                          height: 180 * scale,
                          decoration: const BoxDecoration(
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.transparent),
                            ),
                          ),
                          child: Image.network(
                            rightElement.imageUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}