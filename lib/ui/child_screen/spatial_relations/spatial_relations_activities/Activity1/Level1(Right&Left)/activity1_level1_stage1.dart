import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity1Level1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity1Level1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity1Level1Stage1State createState() => Activity1Level1Stage1State();
}

class Activity1Level1Stage1State extends State<Activity1Level1Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false; // متغير جديد للتأكد من تحميل البيانات

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
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true; // تم تحميل البيانات
        });

        // تحميل الصور
        await _preloadImages(activity);

        setState(() {
          _imagesLoaded = true;
        });

        // تشغيل الصوت بعد تحميل الصور والبيانات
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
          _dataLoaded = true;
          _imagesLoaded = true;
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

    // تحميل كل الصور في الخلفية
    final List<Future> precacheFutures = [];
    for (final url in images) {
      precacheFutures.add(precacheImage(NetworkImage(url!), context));
    }

    // انتظار تحميل جميع الصور
    await Future.wait(precacheFutures);
    print('All images preloaded successfully');
  }

  Future<void> playSound() async {
    // التأكد من تحميل البيانات والصور قبل تشغيل الصوت
    if (!_dataLoaded || !_imagesLoaded) {
      print('Waiting for data and images to load before playing sound');
      return;
    }

    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    try {
      await _player.stop();
      await _player.play(UrlSource(_activity!.audioUrl!));
      print('Sound played successfully after data and images loaded');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void repeatSound() {
    // التأكد من تحميل كل شيء قبل إعادة تشغيل الصوت
    if (_dataLoaded && _imagesLoaded) {
      playSound();
    }
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

  // دالة للتعامل مع الإجابة الصحيحة
  void _handleCorrectAnswer() {
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
            final double anchorWidthPercent = 180 / 400;    // 45% من العرض المرجعي
            final double optionWidthPercent = 80 / 400;     // 20% من العرض المرجعي
            final double topPaddingPercent = 180 / 800;     // 22.5% من الارتفاع المرجعي

            // حساب الأحجام الفعلية
            final double anchorWidth = constraints.maxWidth * anchorWidthPercent;
            final double optionWidth = constraints.maxWidth * optionWidthPercent;
            final double topPadding = constraints.maxHeight * topPaddingPercent;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ✅ الإجابة الصح (الشمال) – نازلة لتحت

                Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: GestureDetector(
                    onTap: _handleWrongAnswer,
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
                // ⚓ الـ Anchor (ثابت في النص)
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

                // ❌ الإجابة الغلط (اليمين) – نازلة لتحت
                Padding(
                  padding: EdgeInsets.only(top: topPadding),
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
                    child: GestureDetector(
                      onTap: _handleCorrectAnswer,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

