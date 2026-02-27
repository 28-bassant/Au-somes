import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity4Level1Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity4Level1Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity4Level1Stage3State createState() => Activity4Level1Stage3State();
}

class Activity4Level1Stage3State extends State<Activity4Level1Stage3>
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

    final elements = _activity!.elements!;

// Anchor
    final anchorElement =
    elements.firstWhere((e) => e.role == 'Anchor');

// Correct Actor
    final correctActor =
    elements.firstWhere((e) =>
    e.role == 'Actor' && e.isCorrect == true);

// Wrong Actors (كلهم)
    final wrongActors =
    elements.where((e) =>
    e.role == 'Actor' && e.isCorrect == false)
        .toList();
    final wrongActor1 = wrongActors[0];
    final wrongActor2 = wrongActors[1];


    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchorWidthPercent = 400 / 400;        // 100% من العرض المرجعي
            final double mediumOptionWidthPercent = 40 / 220;   // 10% من العرض المرجعي
            final double smallOptionWidthPercent = 25 / 400;    // 6.25% من العرض المرجعي

            // نسب المواقع من الكود الأصلي
            final double wrong1RightPercent = 140 / 400;        // 35% من العرض
            final double wrong1TopPercent = 330 / 700;          // 41.25% من الارتفاع

            final double wrong2LeftPercent = 65 / 425;          // 16.25% من العرض
            final double wrong2BottomPercent = 270 / 700;       // 33.75% من الارتفاع

            final double correctRightPercent = 140 / 400;       // 35% من العرض
            final double correctBottomPercent = 200 / 700;      // 25% من الارتفاع

            // حساب الأحجام والمواقع الفعلية
            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double mediumOptionWidth = constraints.maxWidth * mediumOptionWidthPercent;
            final double smallOptionWidth = constraints.maxWidth * smallOptionWidthPercent;

            final double wrong1Right = constraints.maxWidth * wrong1RightPercent;
            final double wrong1Top = constraints.maxHeight * wrong1TopPercent;

            final double wrong2Left = constraints.maxWidth * wrong2LeftPercent;
            final double wrong2Bottom = constraints.maxHeight * wrong2BottomPercent;

            final double correctRight = constraints.maxWidth * correctRightPercent;
            final double correctBottom = constraints.maxHeight * correctBottomPercent;

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
                      height: anchorWidth * 0.75,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),

                // ❌ الإجابة الغلط (فوق السرير)
                Positioned(
                  right: wrong1Right,
                  top: wrong1Top+10,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        wrongActor1.imageUrl ?? '',
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

                // ❌ الإجابة الغلط (داخل الدولاب)
                Positioned(
                  left: wrong2Left,
                  bottom: wrong2Bottom,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.network(
                        wrongActor2.imageUrl ?? '',
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

                // ✅ الإجابة الصح (تحت السرير)
                Positioned(
                  right: correctRight-20,
                  bottom: correctBottom-10,
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
                        correctActor.imageUrl ?? '',
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