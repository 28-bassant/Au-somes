import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel3Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const FrontBackLevel3Stage3Activity({Key? key, this.onNextStage})
      : super(key: key);

  @override
  State<FrontBackLevel3Stage3Activity> createState() =>
      FrontBackLevel3Stage3ActivityState();
}

class FrontBackLevel3Stage3ActivityState
    extends State<FrontBackLevel3Stage3Activity>
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

    // تهيئة المتحكم في الحركة بسرعة أقل
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.front_back_activityId,
        1,
        4, // Stage 4
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

  Future<void> playSound() async {
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    await _player.stop();
    await _player.play(
      UrlSource(_activity!.deceptionInstructions![0]!),
    );
  }
  void repeatSound() => playSound();

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

  // دالة للتعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      // المرة الأولى: تشغيل صوت "حاول مجدداً"
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      // المرة الثانية: تحريك الإجابة الصحيحة (في الواجهة)
      _startCorrectAnswerAnimation();
    }
  }

  // دالة لبدء حركة الإجابة الصحيحة (تهتز في مكانها)
  void _startCorrectAnswerAnimation() {
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
    print("🔥 LOG PROGRESS STAGE 3-3");

    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _wrongAttempts > 0,
      );

      print("📡 isPassed = ${result?.isPassed}");

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
        print("📊 PROGRESS UPDATED");
      }
    } catch (e) {
      print("❌ PROGRESS ERROR = $e");
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

    // استخراج العناصر حسب الـ Response
    final anchorElement = _activity!.elements!
        .firstWhere((e) => e.role == 'Anchor'); // العنصر الأساسي

    // كل الـ Actors
    final allActors = _activity!.elements!
        .where((e) => e.role == 'Actor')
        .toList(); // هيرجع 2 Actors

    // العنصر الصحيح من API (isCorrect = true)
    final apiCorrectElement = allActors.firstWhere((e) => e.isCorrect == true);

    // العنصر الغلط من API (isCorrect = false)
    final apiWrongElement = allActors.firstWhere((e) => e.isCorrect == false);

    // تبديل الأدوار في الواجهة:
    // wrongElement من API يصبح هو الصحيح في الواجهة
    // correctElement من API يصبح هو الخطأ في الواجهة
    final correctElement = apiWrongElement; // الصحيح في الواجهة
    final wrongElement = apiCorrectElement; // الخطأ في الواجهة

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // العنصر الصحيح في الواجهة (على اليمين) - كان wrongElement من API
            // وهذا هو الذي يهتز عند الخطأ للمرة الثانية
            Positioned(
              right: screenWidth * 0.65,
              bottom: screenHeight * 0.3,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = 12 * sin(_animationController!.value * pi);
                  }
                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () async {
                    // هذا هو الصحيح في الواجهة: يؤدي للفوز
                    setState(() {
                      _wrongAttempts = 0;
                      _isAnimatingAnswer = false;
                    });

                    _animationController?.stop();
                    _animationController?.value = 0;

// 🔥 IMPORTANT
                    await _logProgress();

                    WellDoneOverlay.show(context);

                    await Future.delayed(const Duration(seconds: 3));

                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  },
                  child: Image.network(
                    correctElement.imageUrl ?? '',
                    width: screenWidth * 0.35,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // صورة الخلفية
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                child: IgnorePointer(
                  child: Image.network(anchorElement.imageUrl ?? ''),
                ),
              ),
            ),



            // العنصر الخطأ في الواجهة (على اليسار) - كان correctElement من API
            Positioned(
              left: screenWidth * 0.4,
              top: screenHeight * 0.4,
              child: GestureDetector(
                onTapDown: (details) {
                  // هذا هو الخطأ في الواجهة: يؤدي لزيادة المحاولات الخاطئة
                  _handleWrongAnswer();
                },
                child: Image.network(
                  width: screenWidth * 0.45,
                  height: screenWidth * 0.45,
                  wrongElement.imageUrl ?? '',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}