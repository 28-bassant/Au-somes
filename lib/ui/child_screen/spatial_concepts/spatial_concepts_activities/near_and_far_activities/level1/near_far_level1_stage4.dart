import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel1Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel1Stage4({Key? key, this.onNextStage}) : super(key: key);

  @override
  NearFarLevel1Stage4State createState() => NearFarLevel1Stage4State();
}

class NearFarLevel1Stage4State extends State<NearFarLevel1Stage4>
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
        ApiConstants.near_far_activityId,
        1,
        4,
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

    final firstElement = _activity!.elements!.first; // الصورة الغلط (الكبيرة)
    final lastElement = _activity!.elements!.last;   // الصورة الصح (الصغيرة)

    // استخدام LayoutBuilder للحصول على حجم الشاشة
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // حساب عامل التحجيم بناءً على الشاشة (افتراض أن التصميم كان لشاشة 400px)
        final double scale = screenWidth / 400;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double wrongImageWidth = 300 * scale;  // الصورة الكبيرة
        final double correctImageWidth = 200 * scale; // الصورة الصغيرة
        final double spacingHeight = 30 * scale;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ❌ الصورة الغلط (الأولى - الكبيرة)
            GestureDetector(
              onTap: () {
                // عند النقر على الإجابة الخاطئة
                _handleWrongAnswer();
              },
              child: Container(
                width: wrongImageWidth,
                height: wrongImageWidth, // للحفاظ على النسبة
                child: Image.network(
                  firstElement.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: spacingHeight),

            // ✅ الصورة الصح (التانية - الصغيرة) مع الحركة
            AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                // حساب قيمة الحركة للاهتزاز بشكل متجاوب
                double shakeValue = 0;
                if (_isAnimatingAnswer) {
                  // استخدام نسبة من الشاشة للاهتزاز
                  shakeValue = screenWidth * 0.04 * sin(_animationController!.value * pi);
                }

                return Transform.translate(
                  offset: Offset(shakeValue, 0),
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  // إعادة تعيين المحاولات الخاطئة عند الإجابة الصحيحة
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
                child: Container(
                  width: correctImageWidth,
                  height: correctImageWidth, // للحفاظ على النسبة
                  child: Image.network(
                    lastElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
