import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class OutsideLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const OutsideLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<OutsideLevel2Stage1Activity> createState() =>
      OutsideLevel2Stage1ActivityState();
}

class OutsideLevel2Stage1ActivityState
    extends State<OutsideLevel2Stage1Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow1;
  late ActivityElement shadow2;
  late ActivityElement anchor;

  final GlobalKey _shadow2Key = GlobalKey();
  final GlobalKey _shadow1Key = GlobalKey();

  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
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
        ApiConstants.inside_outside_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow1 = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        shadow2 = _activity!.elements!.lastWhere((e) => e.role == 'Shadow');
        anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        await _preloadImages(_activity!);

        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
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
  }
  Future<void> playSound() async {
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    final deceptionUrl = _activity!.deceptionInstructions!.first;

    await _player.stop();
    await _player.play(UrlSource(deceptionUrl));
  }

  void repeatSound() => playSound();

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startShadowAnimation();
    }
  }

  void _startShadowAnimation() {
    if (!_isAnimatingShadow && _animationController != null) {
      setState(() {
        _isAnimatingShadow = true;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingShadow) {
          setState(() {
            _isAnimatingShadow = false;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        final double shadow2Left = 10 * scale;
        final double shadow2Top = 180 * scale;
        final double shadow2Width = 100 * scale;
        final double anchorRight = 5 * scale;
        final double anchorTop = 130 * scale;
        final double anchorWidth = 280 * scale;
        final double shadow1Right = 132 * scale;
        final double shadow1Top = 231 * scale;
        final double shadow1Width = 50 * scale;
        final double actorPlacedWidth = 100 * scale;
        final double actorLeft = 10 * scale;
        final double actorBottom = 240 * scale;
        final double actorWidth = 100 * scale;
        final double actorFeedbackWidth = 100 * scale;
        final double actorPlacedOffset = -5 * scale;
        final double wrongPointSize = 50 * scale;
        final double shakeIntensity = 10 * scale ;

        return Stack(
          children: [
            Positioned(
              left: shadow2Left,
              top: shadow2Top,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;

                  if (_isAnimatingShadow) {
                    shakeValue =
                        shakeIntensity * sin(_animationController!.value * 2 * pi);
                  }

                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Container(
                  key: _shadow2Key,
                  child: DragTarget<String>(
                    onWillAccept: (data) => data == actor.id,
                    onAccept: (_) {
                      setState(() {
                        isPlacedCorrectly = true;
                        _wrongAttempts = 0;
                        _isAnimatingShadow = false;
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
                    builder: (context, _, __) {
                      return isPlacedCorrectly
                          ? Transform.translate(
                        offset: Offset(0, actorPlacedOffset),
                        child:Image.asset(
                          AppAssets.dress_outside,
                          width: actorWidth,
                        ),
                      )
                          : Image.network(
                        shadow1.imageUrl ?? '',
                        width: shadow2Width,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              right: anchorRight,
              top: anchorTop,
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
              ),
            ),

            Positioned(
              right: shadow1Right,
              top: shadow1Top,
              child: Container(
                key: _shadow1Key,
                width: shadow1Width,
                child: DragTarget<String>(
                  onWillAccept: (data) => data == actor.id,
                  onAccept: (_) {
                    _handleWrongAnswer();
                  },
                  builder: (context, _, __) {
                    return Image.network(
                      shadow2.imageUrl ?? '',
                      width: shadow1Width,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
            if (!isPlacedCorrectly)
              Positioned(
                left: actorLeft,
                bottom: actorBottom-50,
                child: Draggable<String>(
                  data: actor.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      AppAssets.dress_outside,
                      width: actorFeedbackWidth,
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Image.asset(
                    AppAssets.dress_outside,
                    width: actorWidth,
                  ),
                  onDragEnd: (details) {
                    if (isPlacedCorrectly) return;

                    final double actorSize = 220 * scale;
                    final actorCenter = Offset(
                      details.offset.dx + actorSize / 2,
                      details.offset.dy + actorSize / 2,
                    );

                    final shadow1Box = _shadow1Key.currentContext?.findRenderObject() as RenderBox?;

                    if (shadow1Box != null) {
                      final shadow1Pos = shadow1Box.localToGlobal(Offset.zero);
                      final shadow1Size = shadow1Box.size;
                      final shadow1Rect = Rect.fromLTWH(
                          shadow1Pos.dx, shadow1Pos.dy, shadow1Size.width, shadow1Size.height
                      );

                      if (shadow1Rect.contains(actorCenter)) {
                        _handleWrongAnswer();

                      }
                    }

                    final shadow2Box = _shadow2Key.currentContext?.findRenderObject() as RenderBox?;

                    if (shadow2Box != null) {
                      final shadow2Pos = shadow2Box.localToGlobal(Offset.zero);
                      final shadow2Size = shadow2Box.size;

                      final wrongCenter = Offset(
                        shadow2Pos.dx + shadow2Size.width / 2 - wrongPointSize / 2,
                        shadow2Pos.dy + shadow2Size.height / 2 - wrongPointSize / 2,
                      );
                      final wrongRect = Rect.fromLTWH(
                        wrongCenter.dx,
                        wrongCenter.dy,
                        wrongPointSize,
                        wrongPointSize,
                      );

                      if (wrongRect.contains(actorCenter)) {
                        setState(() {
                          isPlacedCorrectly = true;
                          _wrongAttempts = 0;
                          _isAnimatingShadow = false;
                        });

                        _animationController?.stop();
                        _animationController?.value = 0;

                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            widget.onNextStage?.call();
                          }
                        });
                        return;
                      }
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

