import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../utils/app_assets.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel2Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const NearFarLevel2Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<NearFarLevel2Stage3> createState() => NearFarLevel2Stage3State();
}

class NearFarLevel2Stage3State extends State<NearFarLevel2Stage3>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;
  bool isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;
  late ActivityElement actor;
  late ActivityElement correctShadow;
  late ActivityElement wrongShadow;
  late ActivityElement anchor;

  final GlobalKey _correctShadowKey = GlobalKey();
  final GlobalKey _wrongShadowKey = GlobalKey();
  static const double actorSize = 200;

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
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
      activity = await ApiManager.getActivity(
        ApiConstants.near_far_activityId,
        2,
        3,
      );

      actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
      final shadows = activity!.elements!.where((e) => e.role == 'Shadow').toList();
      correctShadow = shadows.first;
      wrongShadow = shadows.last;
      anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

      if (mounted) {
        // تحميل الصور
        await _preloadImages();

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }

        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> _preloadImages() async {
    final images = activity!.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }

    _imagesLoaded = true;
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
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
      // المرة الثانية: تحريك الـ Shadow الصحيح
      _startShadowAnimation();
    }
  }

  // دالة لبدء حركة الـ Shadow الصحيح
  void _startShadowAnimation() {
    if (!_isAnimatingShadow && _animationController != null) {
      setState(() {
        _isAnimatingShadow = true;
      });

      // بدء الحركة المتكررة
      _animationController!.repeat(reverse: true);

      // توقف الحركة بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingShadow) {
          setState(() {
            _isAnimatingShadow = false;
          });
          _animationController!.stop();
          _animationController!.value = 0;
        }
      });
    }
  }

  // دالة التعامل مع نهاية السحب
  void _handleDragEnd(DraggableDetails details, double actorSizeValue) {
    if (isPlacedCorrectly) return;

    final actorCenter = Offset(
      details.offset.dx + actorSizeValue / 2,
      details.offset.dy + actorSizeValue / 2,
    );

    // Shadow الغلط
    final wrongBox = _wrongShadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (wrongBox != null) {
      final wrongPos = wrongBox.localToGlobal(Offset.zero);
      final wrongRect = Rect.fromLTWH(
        wrongPos.dx,
        wrongPos.dy,
        wrongBox.size.width,
        wrongBox.size.height,
      );

      if (wrongRect.contains(actorCenter)) {
        _handleWrongAnswer();
        return;
      }
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    // استخدام LayoutBuilder للحصول على حجم الشاشة
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double anchorWidth = 250 * scale;
        final double anchorTop = 200 * scale;

        final double wrongShadowRight = 50 * scale;
        final double wrongShadowTop = 150 * scale;
        final double wrongShadowWidth = 50 * scale;
        final double wrongShadowHeight = 50 * scale;
        final double wrongBallWidth = 80 * scale;

        final double correctShadowLeft = 240 * scale;
        final double correctShadowTop = 360 * scale;
        final double correctShadowWidth = 100 * scale;
        final double correctShadowHeight = 120 * scale;
        final double correctBallWidth = 80 * scale;

        final double actorRight = 40 * scale;
        final double actorBottom = 0 * scale;
        final double actorSizeValue = 120 * scale;

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: anchorTop,
              left: 0,
              right: 0,
              child: Center(
                child: Image.network(
                  anchor.imageUrl ?? '',
                  width: anchorWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Shadow الغلط
            Positioned(
              right: wrongShadowRight,
              top: wrongShadowTop,
              child: Container(
                key: _wrongShadowKey,
                width: wrongShadowWidth,
                height: wrongShadowHeight,
                child: Image.asset(
                  AppAssets.ball_image,
                  width: wrongBallWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Shadow الصح مع الحركة
            Positioned(
              left: correctShadowLeft,
              top: correctShadowTop,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  // حساب قيمة الحركة للاهتزاز بشكل متجاوب
                  double shakeValue = 0;
                  if (_isAnimatingShadow) {
                    // استخدام نسبة من الشاشة للاهتزاز
                    shakeValue = screenWidth * 0.05 * sin(_animationController!.value *  pi);
                  }

                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Container(
                  key: _correctShadowKey,
                  width: correctShadowWidth,
                  height: correctShadowHeight,
                  child: DragTarget<String>(
                    onWillAccept: (data) => data == actor.id,
                    onAccept: (_) {
                      setState(() {
                        isPlacedCorrectly = true;
                        _wrongAttempts = 0;
                        _isAnimatingShadow = false;
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
                    builder: (context, _, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: correctBallWidth,
                            height: correctBallWidth,
                            child: Image.asset(
                              AppAssets.ball_image,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (isPlacedCorrectly)
                            Container(
                              width: actorSizeValue,
                              height: actorSizeValue,
                              child: Image.network(
                                actor.imageUrl ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            if (!isPlacedCorrectly)
              Positioned(
                right: actorRight,
                bottom: actorBottom,
                child: Draggable<String>(
                  data: actor.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: actorSizeValue,
                      height: actorSizeValue,
                      child: Image.network(
                        actor.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Container(
                    width: actorSizeValue,
                    height: actorSizeValue,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                  onDragEnd: (details) {
                    _handleDragEnd(details, actorSizeValue);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}