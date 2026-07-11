import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class DownLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const DownLevel2Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<DownLevel2Stage2Activity> createState() => DownLevel2Stage2ActivityState();
}

class DownLevel2Stage2ActivityState extends State<DownLevel2Stage2Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;

  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;

  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  ActivityElement? actor;
  ActivityElement? shadowCorrect;
  ActivityElement? shadowWrong;
  ActivityElement? anchor;

  final GlobalKey _shadowWrongKey = GlobalKey();
  final GlobalKey _shadowCorrectKey = GlobalKey();

  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fetchActivity();
  }

  void fetchActivity() async {
    try {
      activity = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        2,
        2,
      );

      if (mounted) {
        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadowCorrect = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        shadowWrong = activity!.elements!.lastWhere((e) => e.role == 'Shadow');
        anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        await preloadImages(activity!);

        if (!hasPlayedSound && activity?.audioUrl != null && activity!.audioUrl!.isNotEmpty) {
          await _player.stop();
          await _player.play(UrlSource(activity!.deceptionInstructions!.first));
          setState(() {
            hasPlayedSound = true;
          });
        }

        setState(() {
          imagesLoaded = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> playSound() async {
    if (activity?.deceptionInstructions == null ||
        activity!.deceptionInstructions!.isEmpty) return;

    final deceptionUrl = activity!.deceptionInstructions!.first;

    await _player.stop();
    await _player.play(UrlSource(deceptionUrl));
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
    if (!_isAnimatingShadow) {
      setState(() => _isAnimatingShadow = true);
      _animationController.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _animationController.stop();
          _animationController.value = 0;
          setState(() => _isAnimatingShadow = false);
        }
      });
    }
  }

  void _handleDragEnd(DraggableDetails details) {
    if (isPlacedCorrectly) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 360.0;

    final actorCenter = Offset(
      details.offset.dx + (200 * scale) / 2,
      details.offset.dy + (200 * scale) / 2,
    );

    final wrongBox = _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrongBox != null) {
      final pos = wrongBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(pos.dx, pos.dy, wrongBox.size.width, wrongBox.size.height);
      if (rect.contains(actorCenter)) {
        _animationController.stop();
        _animationController.value = 0;
        setState(() {
          isPlacedCorrectly = true;
          _wrongAttempts = 0;
          _isAnimatingShadow = false;
        });
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
        return;
      }
    }

    final correctBox = _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;
    if (correctBox != null) {
      final pos = correctBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(pos.dx, pos.dy, correctBox.size.width, correctBox.size.height);
      if (rect.contains(actorCenter)) {
        _handleWrongAnswer();
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || actor == null || shadowCorrect == null || shadowWrong == null || anchor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scale = screenWidth / 360.0;

    final anchorWidth = screenWidth * 2.6;
    final anchorHeight = screenHeight * 0.7;
    final anchorTop = screenHeight * 0.01;

    return Stack(
      children: [
        Positioned(
          top: anchorTop,
          left: (screenWidth - anchorWidth) / 2 + 15,
          child: Image.network(
            anchor!.imageUrl ?? '',
            width: anchorWidth,
            height: anchorHeight,
            fit: BoxFit.contain,
          ),
        ),

        Positioned(
          left: 90 * scale,
          top: 340* scale,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double shake = 0;
              if (_isAnimatingShadow) {
                shake = 12 * sin(_animationController.value * pi);
              }
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Container(
              key: _shadowWrongKey,
              width: 110* scale,
              height: 160* scale,
              child: isPlacedCorrectly
                  ? Transform.translate(
                offset: Offset(0, -1 * scale),
                child: Transform.scale(
                  scale: .98,
                  child: Image.network(
                    actor!.imageUrl ?? '',
                    width: 100* scale,
                    height: 160 * scale,
                    fit: BoxFit.contain,

                  ),
                ),
              )
                  : Image.network(
                shadowWrong!.imageUrl ?? '',
                width: 50 * scale,
                height: 160 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),

        ),

        Positioned(
          left: 120 * scale,
          top: 170 * scale,
          child: Container(
            key: _shadowCorrectKey,
            width: 110 * scale,
            height: 160 * scale,
            child: Image.network(shadowCorrect!.imageUrl ?? '', fit: BoxFit.contain),
          ),

        ),

        if (!isPlacedCorrectly)
          Positioned(
            right: 15*scale,
            bottom: 5 * scale,
            child: Draggable<String>(
              data: actor!.id,
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(actor!.imageUrl ?? '', width: 105 * scale),
              ),
              childWhenDragging: const SizedBox(),
              child: Image.network(actor!.imageUrl ?? '', width: 105 * scale),
              onDragEnd: _handleDragEnd,
            ),
          ),
      ],
    );
  }
}