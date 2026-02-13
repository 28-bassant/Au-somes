import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity1Level4Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity1Level4Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity1Level4Stage2State createState() => Activity1Level4Stage2State();
}

class Activity1Level4Stage2State extends State<Activity1Level4Stage2>
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
        ApiConstants.sr_front_back_activityId,
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

    final correctElement = _activity!.elements!
        .firstWhere((e) => e.isCorrect == true);

    final wrongElement = _activity!.elements!
        .firstWhere((e) => e.isCorrect == false);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب النسب المئوية بناءً على أبعاد الشاشة
            final double anchorHeightPercent = 200 / 800;    // 25% من الارتفاع المرجعي
            final double optionWidthPercent = 200 / 400;     // 50% من العرض المرجعي

            // نسب المواقع من الكود الأصلي
            final double rightPositionPercent = 20 / 400;        // 5% من العرض
            final double leftPositionPercent = 10 / 400;         // 2.5% من العرض
            final double topCorrectPositionPercent = 100 / 800;  // 12.5% من الارتفاع
            final double topWrongPositionPercent = 150 / 800;    // 18.75% من الارتفاع

            // حساب الأحجام والمواقع الفعلية
            final double anchorHeight = constraints.maxHeight * anchorHeightPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;

            final double rightPosition = constraints.maxWidth * rightPositionPercent;
            final double leftPosition = constraints.maxWidth * leftPositionPercent;
            final double topCorrectPosition = constraints.maxHeight * topCorrectPositionPercent;
            final double topWrongPosition = constraints.maxHeight * topWrongPositionPercent;

            return Stack(
              alignment: Alignment.center,
              children: [

                // ✅ الإجابة الصح (يمين + نازلة + animation)
                Positioned(
                  right: rightPosition,
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

                // ⚓ Anchor (في النص)
                Image.network(
                  anchorElement.imageUrl ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: anchorHeight,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),

                // ❌ الإجابة الغلط (شمال + نازلة)
                Positioned(
                  left: leftPosition,
                  top: topWrongPosition+15,
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
                    child: Image.network(
                      wrongElement.imageUrl ?? '',
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
              ],
            );
          },
        ),
      ),
    );
  }
}