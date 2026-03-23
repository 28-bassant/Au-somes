import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel1Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel1Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel1Stage3State createState() => RightLeftLevel1Stage3State();
}

class RightLeftLevel1Stage3State extends State<RightLeftLevel1Stage3>
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

    final rightElement = _activity!.elements![0]; // الصورة الصحيحة
    final leftElement = _activity!.elements![1];  // الصورة الغلط
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    // استخدام MediaQuery مع SingleChildScrollView
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = min(screenSize.width / 400, screenSize.height / 800);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenSize.width,
          height: screenSize.height*.8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anchor في الخلف
              Center(
                child: Image.network(
                  anchorElement.imageUrl ?? '',
                  width: 320 * scale,
                  fit: BoxFit.contain,
                ),
              ),

              // الصور فوق الـ Anchor
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الصورة الغلط (اليسار)
                      GestureDetector(
                        onTap: () {
                          _handleWrongAnswer();
                        },
                        child: Container(
                          width: 180 * scale,
                          height: 180 * scale,
                          decoration:  BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                          ),
                          child: Image.network(
                            leftElement.imageUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // الصورة الصحيحة (اليمين) مع الحركة
                      AnimatedBuilder(
                        animation: _animationController!,
                        builder: (context, child) {
                          double shakeValue = 0;
                          if (_isAnimatingAnswer) {
                            shakeValue = screenSize.width * 0.03 *
                                sin(_animationController!.value *  pi );
                          }

                          return Transform.translate(
                            offset: Offset(shakeValue, 0),
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTapDown: (details) {
                            final local = details.localPosition;
                            final double imageWidth = 180 * scale;
                            final double imageHeight = 180 * scale;

                            // تحديد المنطقة الصحيحة: النصف الأيمن بالكامل من الصورة
                            final correctArea = Rect.fromLTWH(
                              imageWidth * 0.4,   // تبدأ من 40% من العرض
                              0,                   // من أعلى الصورة
                              imageWidth * 0.6,   // تمتد 60% من العرض (الجزء الأيمن)
                              imageHeight,        // كامل الارتفاع
                            );

                            if (correctArea.contains(local)) {
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
                            } else {
                              // نقر خارج المنطقة الصحيحة يعتبر إجابة خاطئة
                              _handleWrongAnswer();
                            }
                          },
                          child: Container(
                            width: 180 * scale,
                            height: 180 * scale,
                            child: Stack(
                              children: [
                                Image.network(
                                  rightElement.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                                // منطقة مرئية للمساعدة في التصميم (يمكن إزالتها لاحقًا)
                                Positioned(
                                  left: 180 * scale * 0.4,
                                  child: Container(
                                    width: 180 * scale * 0.6,
                                    height: 180 * scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
