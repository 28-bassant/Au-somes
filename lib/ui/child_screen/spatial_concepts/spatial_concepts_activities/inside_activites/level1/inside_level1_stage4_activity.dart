import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
import 'dart:math';

class InsideLevel1Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel1Stage4Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  InsideLevel1Stage4ActivityState createState() =>
      InsideLevel1Stage4ActivityState();
}

class InsideLevel1Stage4ActivityState extends State<InsideLevel1Stage4Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadActivity();
  }bool isPlacedCorrectly = false;
  void resetActivity() {
    setState(() {
      isPlacedCorrectly = false;
      _wrongAttempts = 0;
      playSound();
      // أي حالة داخلية أخرى عايزة reset
    });
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.inside_outside_activityId,
        1,
        4,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        // تحميل الصور أولاً
        await _preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
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

      _animationController!.repeat(reverse: true);

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final firstElement = _activity!.elements!.first;
    final lastElement = _activity!.elements!.last;
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double wrong1Right = 0 * scale;
        final double wrong1Top = 190 * scale;
        final double wrong1Width = 300 * scale;
        final double wrong1Height = 300 * scale;
        final double wrong2Left = 5 * scale;
        final double wrong2Top = 450* scale;
        final double wrong2Width = 180 * scale;
        final double wrong2Height = 170 * scale;
        final double correctRight = 110 * scale;
        final double correctTop = 316 * scale;
        final double correctWidth = 95 * scale;
        final double correctHeight = 100 * scale;
        final double shakeIntensity = 12 * scale;

        return Stack(
          alignment: Alignment.center,
          children: [
            /// الأنكور الأول ( Try Again)
            Positioned(
              right: wrong1Right,
              top: wrong1Top,
              child: GestureDetector(
                onTap: () {
                  _handleWrongAnswer();
                },
                child: Container(
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                    width: wrong1Width,
                    height: wrong1Height,
                  ),
                ),
              ),
            ),

            /// الأنكور الثاني ( Try Again)
            Positioned(
              left: wrong2Left,
              top: wrong2Top,
              child: GestureDetector(
                onTap: () {
                  _handleWrongAnswer();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Image.network(
                    lastElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                    width: wrong2Width,
                    height: wrong2Height,
                  ),
                ),
              ),
            ),

            /// العنصر الصحيح مع الحركة
            Positioned(
              right: correctRight,
              top: correctTop,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = shakeIntensity *
                        sin(_animationController!.value * 1 * pi);
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
                    color: Colors.transparent,
                    child: Transform.rotate(
                      angle: .3,
                      child: Image.network(
                        firstElement.imageUrl ?? '',
                        width: correctWidth,
                        height: correctHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
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