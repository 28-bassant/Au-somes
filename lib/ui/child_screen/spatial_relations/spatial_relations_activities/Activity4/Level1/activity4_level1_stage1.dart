import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity4Level1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity4Level1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity4Level1Stage1State createState() => Activity4Level1Stage1State();
}

class Activity4Level1Stage1State extends State<Activity4Level1Stage1>
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
        ApiConstants.sr_up_down_activityId,
        1,
        2,
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

    final actorElement = _activity!.elements!
        .firstWhere((e) => e.isCorrect == true);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchorWidthPercent = 400 / 400;        // 100% من العرض المرجعي
            final double smallOptionWidthPercent = 25 / 400;    // 6.25% من العرض المرجعي
            final double mediumOptionWidthPercent = 40 / 400;   // 10% من العرض المرجعي

            // نسب المواقع من الكود الأصلي
            final double wrong1LeftPercent = 65 / 425;          // 16.25% من العرض
            final double wrong1BottomPercent = 270 / 700;       // 33.75% من الارتفاع

            final double wrong2RightPercent = 140 / 400;        // 35% من العرض
            final double wrong2BottomPercent = 200 / 700;       // 25% من الارتفاع

            final double correctRightPercent = 140 / 400;       // 35% من العرض
            final double correctTopPercent = 330 / 700;         // 41.25% من الارتفاع

            // حساب الأحجام والمواقع الفعلية
            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double smallOptionWidth = constraints.maxWidth * smallOptionWidthPercent;
            final double mediumOptionWidth = constraints.maxWidth * mediumOptionWidthPercent;

            final double wrong1Left = constraints.maxWidth * wrong1LeftPercent;
            final double wrong1Bottom = constraints.maxHeight * wrong1BottomPercent;

            final double wrong2Right = constraints.maxWidth * wrong2RightPercent;
            final double wrong2Bottom = constraints.maxHeight * wrong2BottomPercent;

            final double correctRight = constraints.maxWidth * correctRightPercent;
            final double correctTop = constraints.maxHeight * correctTopPercent;

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
                      height: anchorWidth * 0.75, // تقريباً نفس نسبة الصورة
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),

                // ❌ الإجابة الغلط (داخل الدولاب)
                Positioned(
                  left: wrong1Left,
                  bottom: wrong1Bottom,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: smallOptionWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: smallOptionWidth,
                            height: smallOptionWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ❌ الإجابة الغلط (تحت السرير)
                Positioned(
                  right: wrong2Right,
                  bottom: wrong2Bottom,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        actorElement.imageUrl ?? '',
                        width: mediumOptionWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: mediumOptionWidth,
                            height: mediumOptionWidth,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ✅ الإجابة الصح (فوق)
                Positioned(
                  right: correctRight,
                  top: correctTop,
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
                        actorElement.imageUrl ?? '',
                        width: mediumOptionWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: mediumOptionWidth,
                            height: mediumOptionWidth,
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