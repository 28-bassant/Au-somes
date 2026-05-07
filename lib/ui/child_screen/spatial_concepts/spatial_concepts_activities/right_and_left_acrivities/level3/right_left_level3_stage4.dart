import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel3Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel3Stage4({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel3Stage4State createState() => RightLeftLevel3Stage4State();
}

class RightLeftLevel3Stage4State extends State<RightLeftLevel3Stage4>
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
        ApiConstants.right_left_activityId,
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

    final actorElement = _activity!.elements![1]; // نفس العنصر للإجابة الصحيحة والغلط
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    // استخدام MediaQuery مع SingleChildScrollView
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = min(screenSize.width / 400, screenSize.height / 800);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenSize.width,
          height: screenSize.height * 0.8,
          child: Stack(
            children: [
              // Anchor في النص
              Positioned(
                right: 100,
                top: 150,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi), // flip أفقي
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    width: 350 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // leftElement في أقصى اليسار (إجابة خاطئة)
              Positioned(
                right: 0,
                top: 80,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _handleWrongAnswer();
                    },
                    child: Image.network(
                      width: 150 * scale,
                      height: 150 * scale,
                      actorElement.imageUrl ?? '',
                    ),
                  ),
                ),
              ),
              // rightElement في أقصى اليمين (إجابة صحيحة) مع الحركة

              Positioned(
                left: 0,
                top: 80,
                bottom: 0,

                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      double shakeValue = 0;
                      if (_isAnimatingAnswer) {
                        shakeValue = screenSize.width * 0.03 *
                            sin(_animationController!.value * pi);
                      }

                      return Transform.translate(
                        offset: Offset(shakeValue, 0),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTapDown: (details) {
                        // إجابة صحيحة - نفس الصورة لكن الضغط عليها صحيح
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
                        width: 150 * scale,
                        height: 150 * scale,
                        actorElement.imageUrl ?? '',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
