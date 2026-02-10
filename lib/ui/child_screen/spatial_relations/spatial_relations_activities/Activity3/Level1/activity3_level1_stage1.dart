import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity3Level1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity3Level1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity3Level1Stage1State createState() => Activity3Level1Stage1State();
}

class Activity3Level1Stage1State extends State<Activity3Level1Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;

  int _wrongAttempts = 0; // لتتبع الأخطاء
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  bool isCorrectPlaced = false;

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
        ApiConstants.sr_inside_outside_activityId,
        2,
        1,
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
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }
  void repeatSound() => playSound();

  void _handleWrongAnswer() {
    if (_wrongAttempts == 0) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 1) {
      _startAnswerAnimation();
    }
    _wrongAttempts++;
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    final actorElement = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final shadowElement = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ⚓ Anchor
          Positioned(
            top: 240,
            child: Image.network(
              anchorElement.imageUrl ?? '',
              width: 250,
            ),
          ),

          // ✅ DragTarget مع الصورة تحت الشادو (من الكود الأول)
          Positioned(
            left: 20,
            top: 20,
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // الصورة الصحيحة تحت الشادو (لو تم إسقاطها)
                    if (isCorrectPlaced)
                      Positioned(
                        top: 40, // أسفل الشادو
                        child: Image.network(actorElement.imageUrl ?? '', width: 60),
                      ),
                    // الشادو فوق
                    Image.network(shadowElement.imageUrl ?? '', width: 100),
                  ],
                );
              },
              onWillAccept: (_) => true,
              onAccept: (data) {
                if (data == 'correct') {
                  setState(() {
                    isCorrectPlaced = true;
                    _wrongAttempts = 0;
                    _isAnimatingAnswer = false;
                  });
                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) widget.onNextStage?.call();
                  });
                } else {
                  _handleWrongAnswer(); // من الكود الثاني
                }
              },
            ),
          ),

          // ❌ العناصر الخاطئة الثلاث
          Positioned(
            right: 20,
            top: 300,
            child: Draggable(
              data: 'wrong1',
              feedback: Image.network(actorElement.imageUrl ?? '', width: 60),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: Image.network(actorElement.imageUrl ?? '', width: 60),
              ),
              child: Image.network(actorElement.imageUrl ?? '', width: 60),
              onDragEnd: (_) {},
            ),
          ),
          Positioned(
            left: 20,
            top: 300,
            child: Draggable(
              data: 'wrong2',
              feedback: Transform.flip(
                flipX: true,
                child: Image.network(actorElement.imageUrl ?? '', width: 60),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: Transform.flip(
                  flipX: true,
                  child: Image.network(actorElement.imageUrl ?? '', width: 60),
                ),
              ),
              child: Transform.flip(
                flipX: true,
                child: Image.network(actorElement.imageUrl ?? '', width: 60),
              ),
              onDragEnd: (_) {},
            ),
          ),
          Positioned(
            left: 110,
            bottom: 180,
            child: Draggable(
              data: 'wrong3',
              feedback: Transform.flip(
                flipX: true,
                child: Image.network(actorElement.imageUrl ?? '', width: 50),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: Transform.flip(
                  flipX: true,
                  child: Image.network(actorElement.imageUrl ?? '', width: 50),
                ),
              ),
              child: Transform.flip(
                flipX: true,
                child: Image.network(actorElement.imageUrl ?? '', width: 50),
              ),
              onDragEnd: (_) {},
            ),
          ),

          // ✅ العنصر الصحيح مع Animation (من الكود الثاني)
          if (!isCorrectPlaced)
            Positioned(
              left: 180,
              top: 150,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = 20 * sin(_animationController!.value * pi);
                  }
                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Draggable(
                  data: 'correct',
                  feedback: Image.network(actorElement.imageUrl ?? '', width: 60),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: Image.network(actorElement.imageUrl ?? '', width: 60),
                  ),
                  child: Image.network(actorElement.imageUrl ?? '', width: 60),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
