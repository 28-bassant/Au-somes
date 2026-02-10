import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel1Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage3Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage3ActivityState createState() => BetweenLevel1Stage3ActivityState();
}

class BetweenLevel1Stage3ActivityState extends State<BetweenLevel1Stage3Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  // متغيرات لإدارة الإجابات الخاطئة وحركة الإجابة الصحيحة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
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
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        1,
        3,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        // تحميل الصور أولاً
        await _preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
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

  // التعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      // المرة الأولى: صوت Try Again
      TryAgainSound.play();
    } else if (_wrongAttempts >= 2) {
      // المرة الثانية: تحريك الإجابة الصحيحة
      _startAnswerAnimation();
    }
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });
      _animationController!.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingAnswer) {
          _animationController!.stop();
          _animationController!.value = 0;
          setState(() {
            _isAnimatingAnswer = false;
          });
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

    final actorElement = _activity!.elements!.firstWhere((e) => e.role == 'Actor'); // صح
    final wrongActorElement = _activity!.elements!.lastWhere((e) => e.role == 'Actor'); // خطأ
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // حجم ومكان الأنكور
        final anchorWidth = screenWidth * 1.0;
        final anchorHeight = screenHeight * 0.35;
        final anchorTop = screenHeight * 0.5;

        // حجم ومكان الأكتور
        final actorWidth = screenWidth * 1.0;
        final actorHeight = screenHeight * 0.4;

        // موضع الأكتور الصحيح
        final actorOffset = Offset((screenWidth - actorWidth) / 2, screenHeight * 0.15);

        // موضع الأكتور الخطأ
        final wrongOffset = Offset(actorOffset.dx + actorWidth * 0.4, actorOffset.dy + actorHeight * 0.6);

        // كونتينر الأكتور الصحيح
        final correctRect = Rect.fromLTWH(
          actorOffset.dx + actorWidth * 0.39,
          actorOffset.dy + actorHeight * 0.34,
          actorWidth * 0.22,
          actorHeight * 0.56,
        );

        // كونتينر الأكتور الخطأ
        final wrongRect = Rect.fromLTWH(
          wrongOffset.dx + actorWidth * 0.25,
          wrongOffset.dy + actorHeight * 0.55,
          actorWidth * 0.23,
          actorHeight * 0.56,
        );

        return Stack(
          children: [
            // الأنكور
            Positioned(
              top: anchorTop,
              left: 0,
              child: Image.network(
                anchorElement.imageUrl ?? '',
                width: anchorWidth,
                height: anchorHeight,
                fit: BoxFit.cover,
              ),
            ),

            // الأكتور الصحيح مع اهتزاز
            Positioned(
              left: actorOffset.dx,
              top: actorOffset.dy,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = 12 * sin(_animationController!.value * pi); // تصحيح: * 2 * pi
                  }
                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Image.network(
                  actorElement.imageUrl ?? '',
                  width: actorWidth,
                  height: actorHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // كونتينر على الأكتور الصحيح مع GestureDetector
            Positioned(
              left: correctRect.left,
              top: correctRect.top,
              child: GestureDetector(
                onTap: () {
                  // الإجابة صحيحة
                  setState(() {
                    _wrongAttempts = 0;
                    _isAnimatingAnswer = false;
                  });
                  _animationController?.stop();
                  _animationController?.value = 0;

                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () { // تغيير من 2 إلى 3 ثواني
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                child: Container(
                  width: correctRect.width,
                  height: correctRect.height,
                  color: Colors.transparent,
                ),
              ),
            ),

            // كونتينر على الأكتور الخطأ مع GestureDetector
            Positioned(
              left: wrongRect.left,
              top: wrongRect.top,
              child: GestureDetector(
                onTap: () {
                  // الإجابة خاطئة
                  _handleWrongAnswer();
                },
                child: Container(
                  width: wrongRect.width,
                  height: wrongRect.height,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}