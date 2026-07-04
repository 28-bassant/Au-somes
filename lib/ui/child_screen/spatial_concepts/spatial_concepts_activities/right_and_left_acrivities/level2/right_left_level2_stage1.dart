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

class RightLeftLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel2Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<RightLeftLevel2Stage1> createState() => RightLeftLevel2Stage1State();
}

class RightLeftLevel2Stage1State extends State<RightLeftLevel2Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late ActivityElement actor;
  late ActivityElement shadow1;
  late ActivityElement shadow2;
  late ActivityElement anchor;

  final GlobalKey _shadow1Key = GlobalKey();
  final GlobalKey _shadow2Key = GlobalKey();

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
      final activity = await ApiManager.getActivity(
        ApiConstants.right_left_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // البحث عن العناصر
        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
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
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    await _player.stop();
    await _player.play(
      UrlSource(_activity!.deceptionInstructions![0]!),
    );
  }

  void repeatSound() => playSound();

  // دالة للتعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    print('Wrong answer attempt: $_wrongAttempts'); // للتتبع
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
        final double anchorWidth = 150 * scale;

        final double shadow2Right = 250 * scale;
        final double shadowTop = 300 * scale;
        final double shadowWidth = 150 * scale;
        final double shadow1Left = 250 * scale;
        final double actorRight = 150 * scale;
        final double actorBottom =   scale;
        final double actorSize = 150 * scale;
        // تعديل شدة الاهتزاز لتكون أوضح
        final double shakeIntensity = 20.0; // قيمة ثابتة للاهتزاز

        return Stack(
          alignment: Alignment.center,
          children: [
            /// ===== Shadow الغلط =====
            Positioned(
              right: shadow2Right,
              top: shadowTop,
              child: Container(
                key: _shadow2Key,
                width: shadowWidth,
                height: shadowWidth,
                child: Image.network(
                  shadow2.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// ===== الخلفية =====
            Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
                fit: BoxFit.contain,
              ),
            ),

            /// ===== Shadow الصح مع الحركة =====
            Positioned(
              left: shadow1Left,
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
                        actor.imageUrl ?? '',
                        width: shadowWidth,
                        height: shadowWidth,
                        fit: BoxFit.contain,
                      )
                          : Image.network(
                        shadow1.imageUrl ?? '',
                        width: shadowWidth,
                        height: shadowWidth,
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
                  data: actor.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: actorSize,
                      height: actorSize,
                      child: Image.network(
                        actor.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Container(
                    width: actorSize*.8,
                    height: actorSize*.8,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                  onDragEnd: (details) {
                    _handleDragEnd(details, context);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
