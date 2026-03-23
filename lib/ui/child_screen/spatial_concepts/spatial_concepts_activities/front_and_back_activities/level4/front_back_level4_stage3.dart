import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel4Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel4Stage3Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<FrontBackLevel4Stage3Activity> createState() =>
      FrontBackLevel4Stage3ActivityState();
}

class FrontBackLevel4Stage3ActivityState extends State<FrontBackLevel4Stage3Activity>
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
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    await _player.stop();
    await _player.play(
      UrlSource(_activity!.deceptionInstructions![0]!),
    );
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
    if (!_isAnimatingShadow && _animationController != null) {
      setState(() => _isAnimatingShadow = true);
      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingShadow) {
          setState(() => _isAnimatingShadow = false);
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

    final shadowCorrectBox =
    _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;
    final shadowWrongBox =
    _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowCorrectBox != null) {
      final pos = shadowCorrectBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(pos.dx, pos.dy, shadowCorrectBox.size.width, shadowCorrectBox.size.height);

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
          if (mounted) widget.onNextStage?.call();
        });
        return;
      }
    }

    if (shadowWrongBox != null) {
      final pos = shadowWrongBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(pos.dx, pos.dy, shadowWrongBox.size.width, shadowWrongBox.size.height);

      if (rect.contains(actorCenter)) _handleWrongAnswer();
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

    final actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final actor2 = _activity!.elements!.lastWhere((e) => e.role == 'Actor');
    final shadowCorrect = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    final shadowWrong = _activity!.elements!.lastWhere((e) => e.role == 'Shadow');
    final anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final anchorWidth = screenWidth * 1.2; // 600/400
    final wrongShadowLeft = screenWidth * 0.1;
    final wrongShadowTop = screenHeight * 0.1875;
    final wrongShadowSize = screenWidth * 0.5;
    final correctShadowLeft = screenWidth * 0.4;
    final correctShadowTop = screenHeight * 0.4;
    final correctShadowSize = screenWidth * 0.5;
    final actorRight = screenWidth * 0.37;
    final actorBottom = screenHeight * -0.001;
    final actorSize = screenWidth * 0.4;

    return Scaffold(
      body: Stack(
        children: [

          // Shadow الصح
          Positioned(
            left: wrongShadowLeft - 60,
            top: wrongShadowTop-20,
        child: AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            double shakeValue = 0;
            if (_isAnimatingShadow) {
              shakeValue = screenWidth * 0.03 * sin(_animationController!.value * pi);
            }
            return Transform.translate(
              offset: Offset(shakeValue, 0),
              child: child,
            );
          },
          child: _isPlacedCorrectly
              ? Image.network(
            actor2.imageUrl ?? '',
            width: correctShadowSize*.8, // نفس مقاس Shadow بعد الإجابة الصح
            height: correctShadowSize*.8,
            key: _shadowCorrectKey,
          )
              : Image.network(
            shadowWrong.imageUrl ?? '',
            width: correctShadowSize * 0.8, // مقاس Shadow الأصلي قبل الإجابة
            height: correctShadowSize * 0.8,
            key: _shadowCorrectKey,
          ),
        ),
      ),

        // Actor draggable
        if (!_isPlacedCorrectly)
          Positioned(
      right: actorRight,
      bottom: actorBottom,
      child: Draggable<String>(
        data: actor2.id,
        feedback: Image.network(
          actor2.imageUrl ?? '',
          width: actorSize, // مقاس Actor الأصلي
          height: actorSize,
        ),
        childWhenDragging: const SizedBox(),
        child: Image.network(
          actor2.imageUrl ?? '',
          width: actorSize*.8,
          height: actorSize*.8,
        ),
        onDragEnd: (details) => _handleDragEnd(details, actorSize),
      ),
    ),




          // Anchor
          Positioned.fill(
            child: Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
              ),
            ),
          ),

          // ...
// Shadow الغلط
          Positioned(
            left: correctShadowLeft,
            top: correctShadowTop - 10,
            child: Image.network(
    shadowCorrect.imageUrl ?? '',
    key: _shadowWrongKey,
    width: wrongShadowSize,
    height: wrongShadowSize,
    ),
          ),
        ],
      ),
    );
  }
}
