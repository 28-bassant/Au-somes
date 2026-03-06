import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel2Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<FrontBackLevel2Stage1Activity> createState() =>
      FrontBackLevel2Stage1ActivityState();
}

class FrontBackLevel2Stage1ActivityState extends State<FrontBackLevel2Stage1Activity>
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
    _loadActivity();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.front_back_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  void _handleDragEnd(DraggableDetails details, double actorSize) {
    if (_isPlacedCorrectly) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    // =========================
    // تحقق من المكان الغلط أولاً
    // =========================

    final shadowWrongBox =
    _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowWrongBox != null) {
      final pos = shadowWrongBox.localToGlobal(Offset.zero);

      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        shadowWrongBox.size.width,
        shadowWrongBox.size.height,
      );

      if (rect.contains(actorCenter)) {
        _handleWrongAnswer();
        return;
      }
    }

    // =========================
    // تحقق من المكان الصح
    // =========================

    final shadowCorrectBox =
    _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowCorrectBox != null) {
      final pos = shadowCorrectBox.localToGlobal(Offset.zero);

      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        shadowCorrectBox.size.width,
        shadowCorrectBox.size.height,
      );

      if (rect.contains(actorCenter)) {
        setState(() {
          _isPlacedCorrectly = true;
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

    final actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final shadowCorrect =
    _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    final shadowWrong =
    _activity!.elements!.lastWhere((e) => e.role == 'Shadow');
    final anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final anchorWidth = screenWidth * 1.5;
    final actorSize = screenWidth * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // shadow الغلط
          Positioned(
            left: screenWidth * 0.2,
            top: screenHeight * 0.45,
            child: Container(
              key: _shadowWrongKey,
              width: 120,
              height: 120,
              child: Image.network(
                shadowCorrect.imageUrl ?? '',
                fit: BoxFit.fill,
              ),
            ),
          ),

          // anchor
          Positioned.fill(
            child: Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // shadow الصح
          Positioned(
            left: screenWidth * 0.5,
            top: screenHeight * 0.45,
            child: AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                double shake = 0;

                if (_isAnimatingShadow) {
                  shake = screenWidth * 0.04 *
                      sin(_animationController!.value  * pi);
                }

                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: Container(
                key: _shadowCorrectKey,
                width: 120,
                height: 120,
                child: _isPlacedCorrectly
                    ? Image.network(actor.imageUrl ?? '', fit: BoxFit.fill)
                    : Image.network(shadowWrong.imageUrl ?? '',
                    fit: BoxFit.fill),
              ),
            ),
          ),

          // actor draggable
          if (!_isPlacedCorrectly)
            Positioned(
              right: 150,
              bottom: 20,
              child: Draggable<String>(
                data: actor.id,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: actorSize * 0.5,
                    height: actorSize * 0.5,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: actorSize * 0.5,
                  height: actorSize * 0.5,
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