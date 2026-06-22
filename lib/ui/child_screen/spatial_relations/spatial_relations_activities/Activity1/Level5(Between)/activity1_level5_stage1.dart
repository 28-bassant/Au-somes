import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity1Level5Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity1Level5Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity1Level5Stage1State createState() => Activity1Level5Stage1State();
}

class Activity1Level5Stage1State extends State<Activity1Level5Stage1>
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
  bool _usedHint = false;
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
        ApiConstants.sr_between_activityId,
        1,
        1,
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
      _usedHint = true;
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
  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity!.phaseId}");
      print("RESULT = ${result?.isPassed}");

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
      }
    } catch (e) {
      print("Progress error: $e");
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

    // الحصول على العناصر
    final anchorElements = _activity!.elements!
        .where((e) => e.role == 'Anchor')
        .toList();

    final correctActor = _activity!.elements!
        .firstWhere((e) => e.isCorrect == true);

    final wrongActor = _activity!.elements!
        .firstWhere((e) => e.isCorrect == false);

    // التأكد من وجود anchorين
    if (anchorElements.length < 2) {
      return const Center(child: Text('يجب أن يكون هناك anchorين'));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchor1WidthPercent = 100 / 400;    // 25% من العرض المرجعي
            final double anchor2WidthPercent = 120 / 400;    // 30% من العرض المرجعي
            final double optionWidthPercent = 60 / 400;      // 15% من العرض المرجعي

            // نسب المواقع من الكود الأصلي
            final double anchor1LeftPercent = 0.25;          // 25% من العرض
            final double anchor1OffsetPercent = 80 / 400;    // 20% من العرض (للتصحيح)

            final double anchor2RightPercent = 0.25;         // 25% من العرض
            final double anchor2OffsetPercent = 40 / 400;    // 10% من العرض (للتصحيح)
            final double anchor2TopPercent = 230 / 800;      // 28.75% من الارتفاع

            final double wrongRightPercent = 20 / 400;       // 5% من العرض
            final double wrongTopPercent = 0.55;             // 45% من الارتفاع

            final double correctLeftPercent = 0.5;           // 50% من العرض
            final double correctOffsetPercent = 60 / 400;    // 15% من العرض (للتصحيح)
            final double correctTopPercent = 0.55;           // 45% من الارتفاع

            // حساب الأحجام والمواقع الفعلية
            final double anchor1Width = constraints.maxWidth * anchor1WidthPercent;
            final double anchor2Width = constraints.maxWidth * anchor2WidthPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;

            final double anchor1Left = (constraints.maxWidth * anchor1LeftPercent) -
                (constraints.maxWidth * anchor1OffsetPercent);
            final double anchor2Right = (constraints.maxWidth * anchor2RightPercent) -
                (constraints.maxWidth * anchor2OffsetPercent);
            final double anchor2Top = constraints.maxHeight * anchor2TopPercent;

            final double wrongRight = constraints.maxWidth * wrongRightPercent;
            final double wrongTop = constraints.maxHeight * wrongTopPercent;

            final double correctLeft = (constraints.maxWidth * correctLeftPercent) -
                (constraints.maxWidth * correctOffsetPercent);
            final double correctTop = constraints.maxHeight * correctTopPercent;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Anchor الأول (على اليسار)
                Positioned(
                  left: anchor1Left,
                  child: Image.network(
                    anchorElements[0].imageUrl ?? '',
                    width: anchor1Width,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: anchor1Width,
                        height: anchor1Width,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),

                // Anchor الثاني (على اليمين)
                Positioned(
                  right: anchor2Right,
                  top: anchor2Top+30,
                  child: Image.network(
                    anchorElements[1].imageUrl ?? '',
                    width: anchor2Width,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: anchor2Width,
                        height: anchor2Width,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),

                // ❌ الإجابة الخاطئة (كرة خضراء - على اليمين)
                Positioned(
                  right: wrongRight,
                  top: wrongTop,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Image.network(
                      wrongActor.imageUrl ?? '',
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

                // ✅ الإجابة الصحيحة (كرة برتقالية - بين Anchorين)
                Positioned(
                  left: correctLeft,
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
                      onTap: () async {
                        setState(() {
                          _wrongAttempts = 0;
                          _isAnimatingAnswer = false;
                        });

                        _animationController?.stop();
                        _animationController?.value = 0;

                        await _logProgress();

                        WellDoneOverlay.show(context);

                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            widget.onNextStage?.call();
                          }
                        });
                      },
                      child: Image.network(
                        correctActor.imageUrl ?? '',
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}