import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel2Stage2Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  BetweenLevel2Stage2ActivityState createState() =>
      BetweenLevel2Stage2ActivityState();
}class BetweenLevel2Stage2ActivityState
    extends State<BetweenLevel2Stage2Activity>
    with SingleTickerProviderStateMixin {

  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;
  late ActivityElement actor;
  late ActivityElement shadowCorrect;
  late ActivityElement shadowWrong;
  late ActivityElement anchor;

  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  late AnimationController _animationController;

  final GlobalKey _shadowCorrectKey = GlobalKey();
  final GlobalKey _shadowWrongKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        2,
        2,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadowCorrect = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        shadowWrong = _activity!.elements!.lastWhere((e) => e.role == 'Shadow');
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
    setState(() => _isAnimatingShadow = true);
    _animationController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.stop();
        _animationController.value = 0;
        setState(() => _isAnimatingShadow = false);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    return LayoutBuilder(
        builder: (context, constraints) {

      final double screenWidth = constraints.maxWidth;
      final double designWidth = 400.0;
      final double scale = screenWidth / designWidth;

      final double anchorWidth = 350 * scale;
      final double anchorTop = 210 * scale;

      final double shadowLeft = 35 * scale;
      final double shadowTop = 260 * scale;
      final double shadowWidth = 280 * scale;

      final double actorPlacedWidth = 220 * scale;
      final double actorPlacedOffset = 5 * scale;
      final double actorRight = 30 * scale;
      final double actorBottom = 20 * scale;
      final double actorWidth = 190 * scale;
      final double actorFeedbackWidth = 190 * scale;

      final double scaleFactor = 2.5;
      final double shakeIntensity = 12 * scale;

      return Stack(
        children: [

          Positioned(
            top: anchorTop,
            left: 0,
            child: Image.network(
              anchor.imageUrl ?? '',
              width: anchorWidth,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: shadowTop,
            left: shadowLeft * 6,
            child: Container(
              key: _shadowWrongKey,
              width: shadowWidth,
              child: Image.network(
                shadowWrong.imageUrl ?? '',
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            left: shadowLeft,
            top: shadowTop,
            child: Container(
              key: _shadowCorrectKey,
              width: shadowWidth,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double shake = 0;
                  if (_isAnimatingShadow) {
                    shake = shakeIntensity * sin(_animationController.value * 2 * pi);
                  }
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: isPlacedCorrectly
                    ? Transform.translate(
                  offset: Offset(actorPlacedOffset, -22*scale),
                  child: Transform.scale(
                    scale: 1.9,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: actorPlacedWidth,
                    ),
                  ),
                )
                    : Image.network(
                  shadowCorrect.imageUrl ?? '',
                  width: shadowWidth,
                ),
              ),
            ),
          ),

          if (!isPlacedCorrectly)
            Positioned(
              right: actorRight,
              bottom: actorBottom,
              child: Draggable<String>(
                data: actor.id,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: scaleFactor,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: actorFeedbackWidth,
                    ),
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Transform.scale(
                  scale: scaleFactor,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: actorWidth,
                  ),
                ),
                onDragEnd: (details) {

                  final actorCenter = Offset(
                    details.offset.dx + actorWidth / 2,
                    details.offset.dy + actorWidth / 2,
                  );

                  final correctBox = _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;
                  if (correctBox != null) {
                    final pos = correctBox.localToGlobal(Offset.zero);
                    final rect = Rect.fromLTWH(
                      pos.dx,
                      pos.dy,
                      correctBox.size.width,
                      correctBox.size.height,
                    );
                    if (rect.contains(actorCenter)) {
                      setState(() {
                        isPlacedCorrectly = true;
                        _wrongAttempts = 0;
                      });
                      WellDoneOverlay.show(context);
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) widget.onNextStage?.call();
                      });
                      return;
                    }
                  }

                  final wrongBox = _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;
                  if (wrongBox != null) {
                    final pos = wrongBox.localToGlobal(Offset.zero);
                    final rect = Rect.fromLTWH(
                      pos.dx,
                      pos.dy,
                      wrongBox.size.width,
                      wrongBox.size.height,
                    );
                    if (rect.contains(actorCenter)) {
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