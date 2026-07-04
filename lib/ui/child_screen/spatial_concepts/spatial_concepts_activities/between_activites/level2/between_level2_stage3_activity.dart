import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel2Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel2Stage3Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<BetweenLevel2Stage3Activity> createState() =>
      BetweenLevel2Stage3ActivityState();
}

class BetweenLevel2Stage3ActivityState
    extends State<BetweenLevel2Stage3Activity>
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
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        2,
        3,
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
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  void _handleWrongAnswer() {
    setState(() => _wrongAttempts++);

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startShadowAnimation();
    }
  }

  void _startShadowAnimation() {
    if (_animationController == null) return;

    setState(() => _isAnimatingShadow = true);
    _animationController!.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController!.stop();
        _animationController!.value = 0;
        setState(() => _isAnimatingShadow = false);
      }
    });
  }
  Future<void> _logProgress() async {
    final result = await ApiManager.logAttemptStatus(
      phaseId: _activity!.phaseId!,
      userHint: _wrongAttempts > 0,
    );

    if (result?.isPassed == true) {
      await ApiManager.getProgressSummary();
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

        final double shadow2Right = 0 * scale;
        final double shadow2Top = 400 * scale;
        final double shadow2Width = 200 * scale;
        final double anchorTop = 80 * scale;
        final double bag1Width = 100 * scale;
        final double bag1Top = 400 * scale;
        final double bag1Left1 = 20 * scale;
        final double bag1Left2 = 135 * scale;
        final double shadow1Left = 150 * scale;
        final double shadow1Top = 180 * scale;
        final double shadow1Width = 90 * scale;
        final double shadow1Height = 140 * scale;
        final double actorPlacedWidth = 300 * scale;
        final double actorPlacedHeight = 300 * scale;
        final double shadow1ImageWidth = 300 * scale;
        final double shadow1ImageHeight = 300 * scale;
        final double actorLeft = 0 * scale;
        final double actorBottom = -15 * scale;
        final double actorWidth = 250 * scale;
        final double actorFeedbackWidth = 250 * scale;
        final double shakeIntensity = 12 * scale;
        final double actorCenterSize = 200 * scale;

        return Stack(
          children: [
            Positioned(
              right: shadow2Right,
              top: shadow2Top,
              child: Container(
                key: _shadow2Key,
                width: shadow2Width,
                child: Image.network(
                  shadow2.imageUrl ?? '',
                  fit: BoxFit.cover,
                  color: Colors.black,
                ),
              ),
            ),

            Positioned(
              top: anchorTop,
              left: 0,
              right: 0,
              child: Center(
                child: Image.network(
                  anchor.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned(
              top: bag1Top,
              left: bag1Left1,
              child: Image.asset(
                AppAssets.bag1 ?? '',
                width: bag1Width,
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              top: bag1Top,
              left: bag1Left2,
              child: Image.asset(
                AppAssets.bag1 ?? '',
                width: bag1Width,
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              left: shadow1Left,
              top: shadow1Top,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shake = 0;
                  if (_isAnimatingShadow) {
                    shake = shakeIntensity * sin(_animationController!.value * 2 * pi);
                  }
                  return Transform.translate(offset: Offset(shake, 0), child: child);
                },
                child: Container(
                  key: _shadow1Key,
                  width: shadow1Width,
                  height: shadow1Height,
                  child: isPlacedCorrectly
                      ? Transform.scale(
                    scale: 1.5,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: actorPlacedWidth,
                      height: actorPlacedHeight,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.network(
                    shadow1.imageUrl ?? '',
                    width: shadow1ImageWidth,
                    height: shadow1ImageHeight,
                    fit: BoxFit.cover,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            if (!isPlacedCorrectly)
              Positioned(
                left: actorLeft,
                bottom: actorBottom,
                child: Draggable<String>(
                  data: actor.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: actorFeedbackWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: actorWidth,
                    fit: BoxFit.contain,
                  ),
                  onDragEnd: (details) async {
                    if (isPlacedCorrectly) return;

                    final actorCenter = Offset(
                      details.offset.dx + actorCenterSize / 2,
                      details.offset.dy + actorCenterSize / 2,
                    );

                    final shadow1Box = _shadow1Key.currentContext?.findRenderObject() as RenderBox?;
                    if (shadow1Box != null) {
                      final shadow1Pos = shadow1Box.localToGlobal(Offset.zero);
                      final shadow1Rect = Rect.fromLTWH(
                        shadow1Pos.dx,
                        shadow1Pos.dy,
                        shadow1Box.size.width,
                        shadow1Box.size.height,
                      );

                      if (shadow1Rect.contains(actorCenter)) {
                        setState(() {
                          isPlacedCorrectly = true;
                          _wrongAttempts = 0;
                          _isAnimatingShadow = false;
                        });

                        _animationController?.stop();

                        await _logProgress(); // 🔥 مهم هنا

                        WellDoneOverlay.show(context);

                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            widget.onNextStage?.call();
                          }
                        });

                        return;
                      }
                    }

                    final shadow2Box = _shadow2Key.currentContext?.findRenderObject() as RenderBox?;
                    if (shadow2Box != null) {
                      final shadow2Pos = shadow2Box.localToGlobal(Offset.zero);
                      final shadow2Rect = Rect.fromLTWH(
                        shadow2Pos.dx,
                        shadow2Pos.dy,
                        shadow2Box.size.width,
                        shadow2Box.size.height,
                      );

                      if (shadow2Rect.contains(actorCenter)) {
                        _handleWrongAnswer();
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