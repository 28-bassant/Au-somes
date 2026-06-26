import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel4Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel4Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<RightLeftLevel4Stage2> createState() => RightLeftLevel4Stage2State();
}

class RightLeftLevel4Stage2State extends State<RightLeftLevel4Stage2>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late ActivityElement actor1;
  late ActivityElement actor2;
  late ActivityElement shadow1; // الصح
  late ActivityElement shadow2; // الغلط
  late ActivityElement anchor;

  final GlobalKey _shadow1Key = GlobalKey();
  final GlobalKey _shadow2Key = GlobalKey();

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  bool _usedHint = false;
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
        2,
        2,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // البحث عن العناصر
        final actors = activity!.elements!.where((e) => e.role == 'Actor').toList();
        final shadows = activity.elements!.where((e) => e.role == 'Shadow').toList();
        shadow1 = shadows.first;
        shadow2 = shadows.last;
        actor1 = actors.last;
        actor2 = actors.first;
        anchor = activity.elements!.firstWhere((e) => e.role == 'Anchor');

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
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startShadowAnimation();
    }
  }

  // دالة لبدء حركة الـ Shadow الصحيح
  void _startShadowAnimation() {
    print('Starting shadow animation'); // للتتبع
    if (!_isAnimatingShadow && _animationController != null) {
      setState(() {
        _isAnimatingShadow = true;
      });

      // بدء الحركة المتكررة
      _animationController!.repeat(reverse: true);

      // توقف الحركة بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingShadow) {
          print('Stopping shadow animation'); // للتتبع
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
  void _handleDragEnd(DraggableDetails details, BuildContext context) {
    if (isPlacedCorrectly) return;

    final double scale = MediaQuery.of(context).size.width / 400.0;
    final double shadowSize = 150 * scale;
    final actorCenter = Offset(
      details.offset.dx + shadowSize / 2,
      details.offset.dy + shadowSize / 2,
    );

    // Shadow الصح
    final shadow1Box = _shadow1Key.currentContext?.findRenderObject() as RenderBox?;

    if (shadow1Box != null) {
      final shadow1Pos = shadow1Box.localToGlobal(Offset.zero);
      final shadow1Size = shadow1Box.size;
      final shadow1Rect = Rect.fromLTWH(
          shadow1Pos.dx, shadow1Pos.dy, shadow1Size.width, shadow1Size.height
      );

      if (shadow1Rect.contains(actorCenter)) {
        // إعادة تعيين المحاولات الخاطئة عند الإجابة الصحيحة
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
        return;
      }
    }

    // Shadow الغلط
    final shadow2Box = _shadow2Key.currentContext?.findRenderObject() as RenderBox?;

    if (shadow2Box != null) {
      final shadow2Pos = shadow2Box.localToGlobal(Offset.zero);
      final shadow2Size = shadow2Box.size;

      final double wrongPointSize = 50 * scale;
      final wrongCenter = Offset(
        shadow2Pos.dx + shadow2Size.width / 2 - wrongPointSize / 2,
        shadow2Pos.dy + shadow2Size.height / 2 - wrongPointSize / 2,
      );
      final wrongRect = Rect.fromLTWH(
        wrongCenter.dx,
        wrongCenter.dy,
        wrongPointSize,
        wrongPointSize,
      );

      if (wrongRect.contains(actorCenter)) {
        _handleWrongAnswer();
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double anchorWidth = 120 * scale;

        final double shadow2Right = 250 * scale;
        final double shadowTop = 130 * scale;
        final double shadowWidth = 170 * scale;
        final double shadowHeight = 400 * scale;
        final double shadow1Left = 250 * scale;
        final double actorRight = 110 * scale;
        final double actorBottom =  scale;
        final double actorSize = 250 * scale;
        // تعديل شدة الاهتزاز لتكون أوضح
        final double shakeIntensity = 20.0; // قيمة ثابتة للاهتزاز

        return Stack(
          alignment: Alignment.center,
          children: [
            /// ===== Shadow correct =====
            Positioned(
              right: shadow2Right,
              top: shadowTop,
          child: AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              // حساب قيمة الحركة للاهتزاز
              double shakeValue = 0;
              if (_isAnimatingShadow) {
                // حركة اهتزازية واضحة
                shakeValue = shakeIntensity * sin(_animationController!.value * pi );
                print('Shaking: $shakeValue'); // للتتبع
              }

              return Transform.translate(
                offset: Offset(shakeValue, 0),
                child: child,
              );
            },
            child: Container(
              key: _shadow1Key,
              width: shadowWidth,
              height: shadowHeight,
              child: DragTarget<String>(
                onWillAccept: (data) => data == actor1.id,
                onAccept: (_) async {
                  print("👉 RIGHT ANSWER CLICKED");

                  _animationController?.stop();
                  _animationController?.value = 0;

                  setState(() {
                    isPlacedCorrectly = true;
                    _isAnimatingShadow = false;
                  });

                  final result = await ApiManager.logAttemptStatus(
                    phaseId: _activity!.phaseId!,
                    userHint: _usedHint,
                  );

                  print("RESULT: ${result?.isPassed}");

                  if (result?.isPassed == true) {
                    await ApiManager.getProgressSummary();
                  }

                  setState(() {
                    _wrongAttempts = 0;
                  });

                  WellDoneOverlay.show(context);

                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                builder: (context, _, __) {
                  return isPlacedCorrectly
                      ? Image.network(
                    actor2.imageUrl ?? '',
                    width: shadowWidth,
                    height: shadowHeight,
                    fit: BoxFit.contain,
                  )
                      : Image.network(
                    shadow2.imageUrl ?? '',
                    width: shadowWidth,
                    height: shadowHeight,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
        Positioned(
        left: actorRight,
        bottom: actorBottom,
        child: Draggable<String>(
        data: actor1.id,
        feedback: Material(
        color: Colors.transparent,
        child: Container(
        width: actorSize,
        height: actorSize,
        child: Image.network(
        actor2.imageUrl ?? '',
        fit: BoxFit.contain,
        ),
        ),
        ),
        childWhenDragging: const SizedBox(),
        child: Container(
        width: actorSize*.6,
        height: actorSize*.6,
        child: Image.network(
        actor2.imageUrl ?? '',
        fit: BoxFit.contain,
        ),
        ),
        onDragEnd: (details) {
        _handleDragEnd(details, context);
        },
        ),
        ),


            /// ===== الخلفية =====
            Center(
              child: Transform.scale(
                scaleX: -1,
                child: Image.network(
                  anchor.imageUrl ?? '',
                  width: anchorWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// ===== Shadow الصح مع الحركة =====
            Positioned(
              left: shadow1Left,
              top: shadowTop,
              child: Container(
                key: _shadow2Key,
                width: shadowWidth,
                height: shadowHeight,
                child: Image.network(
                  shadow1.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
