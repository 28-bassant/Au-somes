import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  BetweenLevel2Stage1ActivityState createState() =>
      BetweenLevel2Stage1ActivityState();
}

class BetweenLevel2Stage1ActivityState
    extends State<BetweenLevel2Stage1Activity>
    with SingleTickerProviderStateMixin {

  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;
  late ActivityElement actor;
  late ActivityElement shadow; // الصح
  late ActivityElement anchor;

  // ===== إدارة الخطأ =====
  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  late AnimationController _animationController;

  final GlobalKey _correctShadowKey = GlobalKey();
  final GlobalKey _wrongShadowKey = GlobalKey();

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
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        await _preloadImages(_activity!);

        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
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
  }void repeatSound() => playSound();

  // ===== منطق الخطأ =====
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    return LayoutBuilder(
        builder: (context, constraints) {
      final double screenWidth = constraints.maxWidth;
      final double scale = screenWidth / 400.0;

      final double anchorWidth = 330 * scale;
      final double anchorTop = 230 * scale;

      final double shadowLeft = 75 * scale;
      final double shadowTop = 310 * scale;
      final double shadowWidth = 175 * scale;

      final double wrongShadowLeft = shadowLeft * 3.55;

      final double actorRight = 0;
      final double actorBottom = -15 * scale;
      final double actorWidth = 220 * scale;
      final double actorFeedbackWidth = 220 * scale;

      final double shakeIntensity = 12 * scale;

      return Stack(
        children: [
          /// ===== Anchor =====
          Positioned(
            top: anchorTop,
            left: 0,
            child: Image.network(
              anchor.imageUrl ?? '',
              width: anchorWidth,
              fit: BoxFit.contain,
            ),
          ),

          /// ===== Shadow الغلط =====
          Positioned(
            key: _wrongShadowKey,
            top: shadowTop,
            left: wrongShadowLeft,
            child: Image.network(
              shadow.imageUrl ?? '',
              width: shadowWidth,
              color: Colors.black,
            ),
          ),

          /// ===== Shadow الصح =====
          Positioned(
            left: shadowLeft,
            top: shadowTop,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                double shake = 0;
                if (_isAnimatingShadow) {
                  shake = shakeIntensity * sin(_animationController.value * 2 * pi);
                }
                double lift = isPlacedCorrectly ? -20.0 : 0.0;
                double scale = isPlacedCorrectly ? 1.3 : 1.0;
                return Transform.translate(
                  offset: Offset(shake, lift),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Container(
                key: _correctShadowKey,
                child: isPlacedCorrectly
                    ? Image.network(
                  actor.imageUrl ?? '',
                  width: shadowWidth,
                  fit: BoxFit.contain,
                )
                    : Image.network(
                  shadow.imageUrl ?? '',
                  width: shadowWidth,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          /// ===== Actor =====
          if (!isPlacedCorrectly)
            Positioned(
              right: actorRight,
              bottom: actorBottom,
              child: Draggable<String>(
                data: actor.id,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: actorFeedbackWidth,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: actorWidth,
                ),
                onDragEnd: (details) {

                  final actorCenter = Offset(
                    details.offset.dx + actorWidth / 2,
                    details.offset.dy + actorWidth / 2,
                  );

                  /// ===== Check Shadow الصح =====
                  final correctBox =
                  _correctShadowKey.currentContext?.findRenderObject()
                  as RenderBox?;

                  if (correctBox != null) {
                    final correctPos =
                    correctBox.localToGlobal(Offset.zero);

                    final correctRect = Rect.fromLTWH(
                      correctPos.dx,
                      correctPos.dy,
                      correctBox.size.width,
                      correctBox.size.height,
                    );

                    if (correctRect.contains(actorCenter)) {
                      setState(() {
                        isPlacedCorrectly = true;
                        _wrongAttempts = 0;
                        _isAnimatingShadow = false;
                      });

                      _animationController.stop();

                      WellDoneOverlay.show(context);

                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          widget.onNextStage?.call();
                        }
                      });
                      return;
                    }
                  }

                  /// ===== Check Shadow الغلط =====
                  final wrongBox =
                  _wrongShadowKey.currentContext?.findRenderObject()
                  as RenderBox?;

                  if (wrongBox != null) {
                    final wrongPos =
                    wrongBox.localToGlobal(Offset.zero);

                    final wrongRect = Rect.fromLTWH(
                      wrongPos.dx,
                      wrongPos.dy,
                      wrongBox.size.width,
                      wrongBox.size.height,
                    );

                    if (wrongRect.contains(actorCenter)) {
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