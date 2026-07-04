
import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel4Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel4Stage1({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  NearFarLevel4Stage1State createState() => NearFarLevel4Stage1State();
}

class NearFarLevel4Stage1State extends State<NearFarLevel4Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  AnimationController? _animationController;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.near_far_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = activity.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = activity.elements!.firstWhere((e) => e.role == 'Anchor');


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
      if (mounted) setState(() => _isLoading = false);
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

  void _handleWrongDrop() {
    _wrongAttempts++;
    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startShadowShake();
    }
  }

  void _startShadowShake() {
    if (!_isAnimatingShadow && _animationController != null) {
      setState(() {
        _isAnimatingShadow = true;
      });
      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double scale = screenWidth / 400.0;

    final double anchorWidth = 250 * scale;
    final double shadowLeft = 150 * scale;
    final double shadowTop = 360 * scale;
    final double shadowWidth = 80 * scale;
    final double shadowBallWidth = 70 * scale;
    final double actorRight = 165 * scale;
    final double actorBottom =  scale;
    final double actorWidth = 70 * scale;
    final double actorFeedbackWidth = 80 * scale;
    final double wrongShadowLeft = screenWidth - 90 * scale;
    final double wrongShadowTop = shadowTop;

    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: anchorWidth,
            fit: BoxFit.contain,
          ),
        ),

        Positioned(
          left: shadowLeft,
          top: shadowTop,
          child: DragTarget<String>(
            onWillAccept: (data) => data == shadow.id,
            onAccept: (data) {
              _handleWrongDrop();
            },
            builder: (context, candidateData, rejectedData) {
              return Image.network(shadow.imageUrl ?? '', width: shadowBallWidth);
            },
          ),
        ),

        Positioned(
          left: wrongShadowLeft,
          top: wrongShadowTop,

          child: AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              double shakeOffset = 0;
              if (_isAnimatingShadow) {
                shakeOffset = 12 * sin(_animationController!.value * pi);
              }
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: child,
              );
            },
            child: DragTarget<String>(
              onWillAccept: (data) => data == shadow.id,
              onAccept: (data) {
                setState(() {
                  isPlacedCorrectly = true;
                });
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) widget.onNextStage?.call();
                });
              },
              builder: (context, candidateData, rejectedData) {
                return isPlacedCorrectly
                    ? Container(
                  width: shadowWidth,
                  height: shadowWidth,
                  child: Image.network(actor.imageUrl ?? '',
                      fit: BoxFit.contain),
                )
                    : Image.network(shadow.imageUrl ?? '', width: shadowBallWidth);
              },
            ),
          ),
        ),

        if (!isPlacedCorrectly)
          Positioned(
            right: actorRight,
            bottom: actorBottom + 20,
            child: Draggable<String>(
              data: actor.targetedZoneId,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  width: actorFeedbackWidth,
                  height: actorFeedbackWidth,
                  child: Image.network(actor.imageUrl ?? '',
                      fit: BoxFit.contain),
                ),
              ),
              childWhenDragging: const SizedBox(),
              child: Container(
                width: actorWidth,
                height: actorWidth,
                child: Image.network(actor.imageUrl ?? '', fit: BoxFit.contain),
              ),
            ),
          ),
      ],
    );
  }
}
