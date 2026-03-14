import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity2Level1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity2Level1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity2Level1Stage2State createState() => Activity2Level1Stage2State();
}

class Activity2Level1Stage2State extends State<Activity2Level1Stage2>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // تحميل النشاط مرة واحدة في البداية
    _loadActivity();

    // تهيئة المتحكم في الحركة
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.sr_right_left_activityId,
        1,
        3,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // تحميل الصور
        await _preloadImages(activity);

        // تشغيل الصوت بعد تحميل الصور
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
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  // دالة للتعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      // المرة الأولى: تشغيل صوت "حاول مجدداً"
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      // المرة الثانية: تحريك الإجابة الصحيحة
      _startAnswerAnimation();
    }
  }

  // دالة لبدء حركة الإجابة الصحيحة
  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });

      // بدء الحركة المتكررة
      _animationController!.repeat(reverse: true);

      // توقف الحركة بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingAnswer) {
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
    // إذا كان في مرحلة التحميل
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // إذا كان هناك خطأ في تحميل النشاط
    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final anchorElement = _activity!.elements!
        .firstWhere((e) => e.role == 'Anchor');

    final correctElement = _activity!.elements!
        .firstWhere((e) => e.isCorrect == true);
    final wrongActors =
    _activity!.elements!
        .where((e) => e.role == 'Actor' && e.isCorrect == false)
        .toList();
    final firstWrong = wrongActors[0];
    final secondWrong = wrongActors[1];
    final thirdWrong = wrongActors[2];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchorWidthPercent = 250 / 400;    // 62.5% من العرض المرجعي
            final double optionWidthPercent = 50 / 400;     // 12.5% من العرض المرجعي

            // نسب المواقع من الكود الأصلي'

            final double topWrongPositionPercent = 120 / 800;     // 15% من الارتفاع
            final double leftWrongPositionPercent = 20 / 400;     // 5% من العرض
            final double topLeftPositionPercent = 240 / 550;      // 30% من الارتفاع
            final double bottomLeftPositionPercent = 110 / 400;   // 27.5% من العرض
            final double bottomPositionPercent = 180 / 800;       // 22.5% من الارتفاع

            final double rightCorrectPositionPercent = 20 / 400;   // 5% من العرض
            final double topCorrectPositionPercent = 280 / 650;    // 35% من الارتفاع

            final double rightTopPositionPercent = 160 / 400;      // 40% من العرض

            // حساب الأحجام والمواقع الفعلية
            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;

            final double topWrongPosition = constraints.maxHeight * topWrongPositionPercent;
            final double leftWrongPosition = constraints.maxWidth * leftWrongPositionPercent;
            final double topLeftPosition = constraints.maxHeight * topLeftPositionPercent;
            final double bottomLeftPosition = constraints.maxWidth * bottomLeftPositionPercent;
            final double bottomPosition = constraints.maxHeight * bottomPositionPercent;

            final double rightCorrectPosition = constraints.maxWidth * rightCorrectPositionPercent;
            final double topCorrectPosition = constraints.maxHeight * topCorrectPositionPercent;

            final double rightTopPosition = constraints.maxWidth * rightTopPositionPercent;

            return Stack(
              alignment: Alignment.center,
              children: [

                // ⚓ Anchor (في النص)
                Image.network(
                  anchorElement.imageUrl ?? '',
                  width: anchorWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: anchorWidth,
                      height: anchorWidth,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),

                // ❌ الإجابة الغلط (فوق)
                Positioned(
                  right: rightTopPosition,
                  top: topWrongPosition,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Image.network(
                      secondWrong.imageUrl ?? '',
                      width: optionWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: optionWidth,
                          height: optionWidth,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                ),

                // ❌ الإجابة الغلط (شمال)
                Positioned(
                  left: leftWrongPosition,
                  top: topLeftPosition-20,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        firstWrong.imageUrl ?? '',
                        width: optionWidth*1.3,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: optionWidth,
                            height: optionWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ❌ الإجابة الغلط (تحت)
                Positioned(
                  left: bottomLeftPosition,
                  bottom: bottomPosition,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        thirdWrong.imageUrl ?? '',
                        width: optionWidth*1.5,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: optionWidth,
                            height: optionWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ✅ الإجابة الصح (يمين)
                Positioned(
                  right: rightCorrectPosition-10,
                  top: topCorrectPosition,
                  child: AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      double shakeValue = 0;
                      if (_isAnimatingAnswer) {
                        shakeValue = 15 * sin(_animationController!.value * pi);
                      }

                      return Transform.translate(
                        offset: Offset(shakeValue, 0),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _wrongAttempts = 0;
                          _isAnimatingAnswer = false;
                        });
                        _animationController?.stop();
                        _animationController?.value = 0;

                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            widget.onNextStage?.call();
                          }
                        });
                      },
                      child: Image.network(
                        correctElement.imageUrl ?? '',
                        width: optionWidth*1.6,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: optionWidth,
                            height: optionWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
