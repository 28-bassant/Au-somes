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

class RightLeftLevel4Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel4Stage4({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<RightLeftLevel4Stage4> createState() => RightLeftLevel4Stage4State();
}

class RightLeftLevel4Stage4State extends State<RightLeftLevel4Stage4>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late ActivityElement actor;
  late ActivityElement actor2;
  late ActivityElement shadow1; // الصح
  late ActivityElement shadow2; // الغلط
  late ActivityElement anchor;

  final GlobalKey _shadow1Key = GlobalKey();
  final GlobalKey _shadow2Key = GlobalKey();

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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.right_left_activityId,
        2,
        4,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // البحث عن العناصر
        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        actor2 = activity!.elements!.lastWhere((e) => e.role == 'Actor');
        final shadows = activity.elements!.where((e) => e.role == 'Shadow').toList();
        shadow1 = shadows.first;
        shadow2 = shadows.last;
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
  void _handleDragEnd(DraggableDetails details, BuildContext context) {
    if (isPlacedCorrectly) return;

    final double scale = MediaQuery.of(context).size.width / 400.0;
    final double actorSize = 220 * scale;
    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
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
        final double anchorWidth = 350 * scale;
        final double anchorLeft = 80 * scale;
        final double anchorBottom = 100 * scale;
        final double shadow2Right = 200 * scale;
        final double shadowTop = 250 * scale;
        final double shadowWidth = 250 * scale;
        final double shadow1Left = 210 * scale;
        final double actorRight = 120 * scale;
        final double actorBottom =  scale;
        final double actorChildWidth = 150 * scale;
        final double actorFeedbackWidth = 250 * scale;
        final double shadowBigWidth = 300 * scale;
        final double shakeIntensity = 20 * scale * 0.03; // نفس نسبة التعديل

        return Stack(
          alignment: Alignment.center,
          children: [
            /// ===== Shadow correct =====
            Positioned(
              right: shadow2Right,
              top: shadowTop-100,
          child: AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              // حساب قيمة الحركة للاهتزاز
              double shakeValue = 0;
              if (_isAnimatingShadow) {
                // إنشاء حركة اهتزازية متجاوبة بنفس طريقة الكود الآخر
                shakeValue = shakeIntensity * sin(_animationController!.value * pi * .2);
              }

              return Transform.translate(
                offset: Offset(shakeValue, 0),
                child: child,
              );
            },
            child: Container(
              key: _shadow1Key,
              width: shadowWidth,
              height: shadowWidth,
              child: DragTarget<String>(
                onWillAccept: (data) => data == actor.id,
                onAccept: (_) {
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
                },
                builder: (context, _, __) {
                  return isPlacedCorrectly
                      ? Image.network(
                    actor2.imageUrl ?? '',
                    width: shadowBigWidth,
                    height: shadowBigWidth,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    shadow1.imageUrl ?? '',
                    width: shadowBigWidth,
                    height: shadowBigWidth,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
        Positioned(
        right: actorRight,
        bottom: actorBottom,
        child: Draggable<String>(
        data: actor2.id,
        feedback: Material(
        color: Colors.transparent,
        child: Image.network(
        actor2.imageUrl ?? '',
        width: actorFeedbackWidth,
        ),
        ),
        childWhenDragging: const SizedBox(),
        child: Image.network(
        actor2.imageUrl ?? '',
        width: actorChildWidth*.8,
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
                  width: anchorWidth*.4,
                ),
              ),
            ),

            /// ===== Shadow wrong مع الحركة =====
            Positioned(
              left: shadow1Left,
              top: shadowTop-100,
              child: Container(
                key: _shadow2Key,
                width: shadowWidth,
                height: shadowWidth,
                child: Image.network(
                  shadow2.imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
