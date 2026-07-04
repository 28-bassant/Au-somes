import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel2Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<FrontBackLevel2Stage2Activity> createState() =>
      FrontBackLevel2Stage2ActivityState();
}

class FrontBackLevel2Stage2ActivityState extends State<FrontBackLevel2Stage2Activity>
    with SingleTickerProviderStateMixin {

  late AudioPlayer _player;
  ActivityResponse? _activity;

  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _isPlacedCorrectly = false;

  final GlobalKey _shadowCorrectKey = GlobalKey();
  final GlobalKey _shadowWrongKey = GlobalKey();

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
        ApiConstants.front_back_activityId,
        2,
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

      print(e);
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
  Future<void> _logProgress() async {
    try {
      await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _wrongAttempts > 0,
      );

      await ApiManager.getProgressSummary();
    } catch (e) {
      print("Progress error: $e");
    }
  }

  Future<void> _handleDragEnd(DraggableDetails details, double actorSize) async {

    if (_isPlacedCorrectly) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final shadowCorrectBox =
    _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowCorrectBox != null) {

      final shadowCorrectPos = shadowCorrectBox.localToGlobal(Offset.zero);

      final shadowCorrectRect = Rect.fromLTWH(
        shadowCorrectPos.dx,
        shadowCorrectPos.dy,
        shadowCorrectBox.size.width,
        shadowCorrectBox.size.height,
      );

      if (shadowCorrectRect.contains(actorCenter)) {

        setState(() {
          _isPlacedCorrectly = true;
          _wrongAttempts = 0;
          _isAnimatingShadow = false;
        });

        _animationController?.stop();
        _animationController?.value = 0;

        await _logProgress(); // 👈 ده الجديد

        WellDoneOverlay.show(context);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });

        return;
      }
    }

    final shadowWrongBox =
    _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowWrongBox != null) {

      final shadowWrongPos = shadowWrongBox.localToGlobal(Offset.zero);

      final shadowWrongRect = Rect.fromLTWH(
        shadowWrongPos.dx,
        shadowWrongPos.dy,
        shadowWrongBox.size.width,
        shadowWrongBox.size.height,
      );

      if (shadowWrongRect.contains(actorCenter)) {

        _handleWrongAnswer();
      }
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

    final actor = _activity!.elements!
        .where((e) => e.role == 'Actor')
        .toList()[1];

    final shadowCorrect =
    _activity!.elements!.firstWhere((e) => e.role == 'Shadow');

    final shadowWrong =
    _activity!.elements!.lastWhere((e) => e.role == 'Shadow');

    final anchor =
    _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double anchorWidth = screenWidth * (500 / 400);

    final double wrongShadowLeft = screenWidth * (40 / 400);
    final double wrongShadowTop = screenHeight * (150 / 800);
    final double wrongShadowSize = screenWidth * (150 / 400);

    final double correctShadowLeft = screenWidth * (160 / 400);
    final double correctShadowTop = screenHeight * (300 / 800);
    final double correctShadowSize = screenWidth * (180 / 400);

    final double actorRight = screenWidth * (140 / 400);
    final double actorBottom = screenHeight * (-15/ 800);
    final double actorSize = screenWidth * (140 / 400);

    return Scaffold(
      body: Stack(
        children: [

          Positioned(
            left: wrongShadowLeft-40,
            top: wrongShadowTop-20,
            child: Image.network(
              shadowCorrect.imageUrl ?? '',
              key: _shadowWrongKey,
              width: wrongShadowSize,
              height: wrongShadowSize,
            ),
          ),

          Positioned.fill(
            child: Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
              ),
            ),
          ),

          Positioned(
            left: correctShadowLeft,
            top: correctShadowTop ,
            child: AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {

                double shakeValue = 0;

                if (_isAnimatingShadow) {
                  shakeValue = screenWidth * 0.03 *
                      sin(_animationController!.value * pi);
                }

                return Transform.translate(
                  offset: Offset(shakeValue, 0),
                  child: child,
                );
              },
              child: _isPlacedCorrectly
                  ? Image.network(
                actor.imageUrl ?? '',
                key: _shadowCorrectKey,
                width: correctShadowSize,
                height: correctShadowSize,
              )
                  : Image.network(
                shadowWrong.imageUrl ?? '',
                key: _shadowCorrectKey,
                width: correctShadowSize,
                height: correctShadowSize,
              ),
            ),
          ),

          if (!_isPlacedCorrectly)
            Positioned(
              right: actorRight,
              bottom: actorBottom+20,
              child: Draggable<String>(

                data: actor.id,

                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: actorSize,
                    height: actorSize,
                  ),
                ),

                childWhenDragging: const SizedBox(),

                child: Image.network(
                  actor.imageUrl ?? '',
                  width: actorSize*.8,
                  height: actorSize*.8,
                ),

                onDragEnd: (details) {
                  _handleDragEnd(details, actorSize);
                },
              ),
            ),
        ],
      ),
    );
  }
}
