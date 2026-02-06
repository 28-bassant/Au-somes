import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel2Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel2Stage3Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<FrontBackLevel2Stage3Activity> createState() =>
      FrontBackLevel2Stage3ActivityState();
}

class FrontBackLevel2Stage3ActivityState extends State<FrontBackLevel2Stage3Activity>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;
  bool _isPlacedCorrectly = false;

  // keys لتحديد أماكن الـ Shadow
  final GlobalKey _shadowCorrectKey = GlobalKey();
  final GlobalKey _shadowWrongKey = GlobalKey();

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
      final activity = await ApiManager.getActivity(
        ApiConstants.front_back_activityId,
        2,
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
  void _handleDragEnd(DraggableDetails details, double actorSize) {
    if (_isPlacedCorrectly) return; // إذا كانت الإجابة صحيحة بالفعل

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    // Shadow الصح
    final shadowCorrectBox =
    _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowCorrectBox != null) {
      final shadowCorrectPos = shadowCorrectBox.localToGlobal(Offset.zero);
      final shadowCorrectRect =
      Rect.fromLTWH(
        shadowCorrectPos.dx,
        shadowCorrectPos.dy,
        shadowCorrectBox.size.width,
        shadowCorrectBox.size.height,
      );

      if (shadowCorrectRect.contains(actorCenter)) {
        // إعادة تعيين المحاولات الخاطئة عند الإجابة الصحيحة
        setState(() {
          _isPlacedCorrectly = true;
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
    final shadowWrongBox =
    _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowWrongBox != null) {
      final shadowWrongPos = shadowWrongBox.localToGlobal(Offset.zero);
      final shadowWrongRect =
      Rect.fromLTWH(
        shadowWrongPos.dx,
        shadowWrongPos.dy,
        shadowWrongBox.size.width,
        shadowWrongBox.size.height,
      );

      if (shadowWrongRect.contains(actorCenter)) {
        // عند وضع الصورة على المكان الغلط
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
    // إذا كان في مرحلة التحميل
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // إذا كان هناك خطأ في تحميل النشاط
    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final shadowCorrect = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    final shadowWrong = _activity!.elements!.lastWhere((e) => e.role == 'Shadow');
    final anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // حساب الأحجام بناءً على النسب المئوية
    final double anchorWidth = screenWidth * (600 / 400); // 600 ÷ 400 = 1.5
    final double wrongShadowLeft = screenWidth * (40 / 400); // 40 ÷ 400 = 0.1
    final double wrongShadowTop = screenHeight * (150 / 800); // 150 ÷ 800 = 0.1875
    final double wrongShadowSize = screenWidth * (250 / 400); // 250 ÷ 400 = 0.625
    final double correctShadowLeft = screenWidth * (160 / 400); // 160 ÷ 400 = 0.4
    final double correctShadowTop = screenHeight * (300 / 800); // 300 ÷ 800 = 0.375
    final double correctShadowSize = screenWidth * (300 / 400); // 300 ÷ 400 = 0.75
    final double actorRight = screenWidth * (40 / 400); // 40 ÷ 400 = 0.1
    final double actorBottom = screenHeight * (-15 / 800); // -15 ÷ 800 = -0.01875
    final double actorSize = screenWidth * (200 / 400); // 200 ÷ 400 = 0.5

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Shadow الغلط (للعرض فقط)
            Positioned(
              left: wrongShadowLeft,
              top: wrongShadowTop,
              child: Container(
                key: _shadowWrongKey,
                width: wrongShadowSize,
                height: wrongShadowSize,
                child: Image.network(
                  shadowWrong.imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Anchor
            Positioned.fill(
              child: Center(
                child: Image.network(
                  anchor.imageUrl ?? '',
                  width: anchorWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Shadow الصح مع الحركة
            Positioned(
              left: correctShadowLeft,
              top: correctShadowTop-40,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  // حساب قيمة الحركة للاهتزاز بشكل نسبي
                  double shakeValue = 0;
                  if (_isAnimatingShadow) {
                    // استخدام نسبة من عرض الشاشة للاهتزاز
                    shakeValue = screenWidth * 0.03 *
                        sin(_animationController!.value *  pi );
                  }

                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Container(
                  key: _shadowCorrectKey,
                  width: correctShadowSize,
                  height: correctShadowSize,
                  child: _isPlacedCorrectly
                      ? Image.network(actor.imageUrl ?? '', fit: BoxFit.cover)
                      : Image.network(shadowCorrect.imageUrl ?? '', fit: BoxFit.cover),
                ),
              ),
            ),

            // Actor draggable
            if (!_isPlacedCorrectly)
              Positioned(
                right: actorRight,
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Container(
                    width: actorSize,
                    height: actorSize,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  onDragEnd: (details) {
                    _handleDragEnd(details, actorSize);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}