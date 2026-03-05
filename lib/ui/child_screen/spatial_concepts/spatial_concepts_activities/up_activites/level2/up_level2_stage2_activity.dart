import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const UpLevel2Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<UpLevel2Stage2Activity> createState() => UpLevel2Stage2ActivityState();
}

class UpLevel2Stage2ActivityState extends State<UpLevel2Stage2Activity>
    with SingleTickerProviderStateMixin {
  // 🔹 النشاط نفسه
  ActivityResponse? activity;

  // 🔹 حالة التحميل
  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;

  // 🔹 هل القطّة وضعت في مكانها الصحيح؟
  bool isPlacedCorrectly = false;

  // 🔹 مشغل الصوت
  late AudioPlayer _player;

  // 🔹 عناصر النشاط
  ActivityElement? actor;          // القطّة
  ActivityElement? shadowCorrect;  // Shadow الصح
  ActivityElement? shadowWrong;    // Shadow الغلط
  ActivityElement? anchor;         // الكرسي أو الطرابيزة

  // 🔹 مفاتيح لتحديد أماكن الـ Shadows
  final GlobalKey _shadowWrongKey = GlobalKey();
  final GlobalKey _shadowCorrectKey = GlobalKey();

  // 🔹 متغيرات لإدارة الإجابات الخاطئة وحركة الـ Shadow
  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // 🔹 تهيئة مشغل الصوت
    _player = AudioPlayer();

    // 🔹 تهيئة المتحكم في الحركة (اهتزاز الـ Shadow)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 🔹 تحميل النشاط
    fetchActivity();
  }

  // 🔹 تحميل النشاط من الـ API
  void fetchActivity() async {
    try {
      activity = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        2,
        2,
      );

      if (mounted) {
        // 🔹 تعيين العناصر حسب الدور
        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadowCorrect = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        shadowWrong = activity!.elements!.lastWhere((e) => e.role == 'Shadow');
        anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        // Preload الصور أولاً
        await preloadImages(activity!);

        // 🔹 تشغيل الصوت بعد تحميل الصور
        if (!hasPlayedSound && activity?.audioUrl != null && activity!.audioUrl!.isNotEmpty) {
          await _player.stop();
          await _player.play(UrlSource(activity!.audioUrl!));
          setState(() {
            hasPlayedSound = true;
          });
        }

        // 🔹 تغيير حالة التحميل
        setState(() {
          imagesLoaded = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  // 🔹 تشغيل الصوت
  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  // 🔹 التعامل مع إجابة خاطئة
  void _handleWrongAnswer() {
    setState(() => _wrongAttempts++);
    if (_wrongAttempts == 1) {
      // المرة الأولى: تشغيل صوت "حاول مجدداً"
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      // المرة الثانية: تشغيل اهتزاز Shadow الصحيح
      _startShadowAnimation();
    }
  }

  // 🔹 بدء حركة اهتزاز الـ Shadow الصحيح
  void _startShadowAnimation() {
    if (!_isAnimatingShadow) {
      setState(() => _isAnimatingShadow = true);
      _animationController.repeat(reverse: true);

      // التوقف بعد ثانيتين
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _animationController.stop();
          _animationController.value = 0;
          setState(() => _isAnimatingShadow = false);
        }
      });
    }
  }

  // 🔹 التعامل مع نهاية سحب القطّة
  void _handleDragEnd(DraggableDetails details) {
    if (isPlacedCorrectly) return;

    // حساب عامل القياس
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 360.0;

    // 🔹 حساب مركز القطّة بعد السحب - أصبح متناسباً
    final actorCenter = Offset(
      details.offset.dx + (200 * scale) / 2,
      details.offset.dy + (200 * scale) / 2,
    );

    // 🔹 التحقق من Shadow الصحيح
    final correctBox = _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;
    if (correctBox != null) {
      final pos = correctBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(pos.dx, pos.dy, correctBox.size.width,
          correctBox.size.height);

      if (rect.contains(actorCenter)) {
        // ✅ وضع القطّة في المكان الصحيح
        _animationController.stop();
        _animationController.value = 0;
        setState(() {
          isPlacedCorrectly = true;
          _wrongAttempts = 0;
          _isAnimatingShadow = false;
        });
        // عرض رسالة "Well Done"
        WellDoneOverlay.show(context);

        // الانتقال للمرحلة التالية بعد 3 ثواني
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
        return;
      }
    }

    // 🔹 التحقق من Shadow الغلط
    final wrongBox = _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrongBox != null) {
      final pos = wrongBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(pos.dx, pos.dy, wrongBox.size.width, wrongBox.size.height);

      if (rect.contains(actorCenter)) {
        // ❌ إذا وُضعت القطّة على المكان الغلط
        _handleWrongAnswer();
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 عرض مؤشر تحميل أثناء تحميل النشاط أو عدم تهيئة العناصر
    if (isLoading || actor == null || shadowCorrect == null || shadowWrong == null || anchor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // حساب عامل القياس بناءً على حجم الشاشة
    // 360px هو عرض الشاشة المرجعية (مثل معظم الموبايلات)
    final scale = screenWidth / 360.0;

    // 🔹 إعداد أبعاد الـ Anchor (الكرسي أو الطرابيزة)
    final anchorWidth = screenWidth * 2.6;
    final anchorHeight = screenHeight * 0.7;
    final anchorTop = screenHeight * 0.01;

    return Stack(
      children: [
        /// 🔹 عرض الـ Anchor
        Positioned(
          top: anchorTop,
          left: (screenWidth - anchorWidth) / 2 + 15,
          child: Image.network(
            anchor!.imageUrl ?? '',
            width: anchorWidth,
            height: anchorHeight,
            fit: BoxFit.contain,
          ),
        ),

        /// ❌ Shadow الغلط
        Positioned(
          left: 90 * scale, // أصبح متناسباً
          top: 340* scale, // أصبح متناسباً
          child: Container(
            key: _shadowWrongKey,
            width: 110 * scale, // أصبح متناسباً
            height: 160 * scale, // أصبح متناسباً
            child: Image.network(shadowWrong!.imageUrl ?? '', fit: BoxFit.contain),
          ),
        ),

        /// ✅ Shadow الصح مع الاهتزاز
        Positioned(
          left: 120 * scale, // أصبح متناسباً
          top: 170 * scale, // أصبح متناسباً
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double shake = 0;
              if (_isAnimatingShadow) {
                shake = 12 * sin(_animationController.value * pi);
              }
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Container(
              key: _shadowCorrectKey,
              width: 110* scale, // أصبح متناسباً
              height: 160* scale, // أصبح متناسباً
              // 🔹 إظهار القطّة مكان الشادو عند الإجابة الصحيحة
              child: isPlacedCorrectly
                  ? Transform.translate(
                offset: Offset(0, -1 * scale), // أصبح متناسباً
                child: Transform.scale(
                  scale: .98,
                  child: Image.network(
                    actor!.imageUrl ?? '',
                    width: 100* scale, // أصبح متناسباً
                    height: 160 * scale, // أصبح متناسباً
                    fit: BoxFit.contain,
                  ),
                ),
              )
                  : Image.network(
                shadowCorrect!.imageUrl ?? '',
                width: 50 * scale, // أصبح متناسباً
                height: 160 * scale, // أصبح متناسباً
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        /// 🐱 Actor draggable
        if (!isPlacedCorrectly)
          Positioned(
            right: 15*scale,
            bottom: 5 * scale, // أصبح متناسباً
            child: Draggable<String>(
              data: actor!.id,
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(actor!.imageUrl ?? '', width: 105 * scale), // أصبح متناسباً
              ),
              childWhenDragging: const SizedBox(),
              child: Image.network(actor!.imageUrl ?? '', width: 105 * scale), // أصبح متناسباً
              onDragEnd: _handleDragEnd,
            ),
          ),
      ],
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel2Stage2Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  UpLevel2Stage2ActivityState createState() =>
      UpLevel2Stage2ActivityState();
}

class UpLevel2Stage2ActivityState
    extends State<UpLevel2Stage2Activity> {

  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        2,
        2,
      );

      if (mounted) {
        activity = response;

        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        // Preload الصور أولاً
        await preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
        if (!hasPlayedSound && activity?.audioUrl != null && activity!.audioUrl!.isNotEmpty) {
          await _player.stop();
          await _player.play(UrlSource(activity!.audioUrl!));
          setState(() {
            hasPlayedSound = true;
          });
        }

        setState(() {
          imagesLoaded = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // حساب عامل القياس بناءً على حجم الشاشة
    // 360px هو عرض الشاشة المرجعية (مثل معظم الموبايلات)
    final scale = screenWidth / 360.0;

    // 🪑 حجم الطرابيزة
    final anchorWidth = screenWidth * 2.6;
    final anchorHeight = screenHeight * 0.7;
    final anchorTop = screenHeight * 0.01;

    return Stack(
      children: [
        Positioned(
          top: anchorTop,
          left: (screenWidth - anchorWidth) / 2 + 15,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: anchorWidth,
            height: anchorHeight,
            fit: BoxFit.contain,
          ),
        ),

        /// ===== Shadow (مكان الإسقاط) =====
        Positioned(
          left: 60 * scale, // أصبح متناسباً
          top: 100 * scale, // أصبح متناسباً
          child: DragTarget<String>(
            onWillAccept: (data) => data == shadow.id,
            onAccept: (data) {
              setState(() {
                isPlacedCorrectly = true;
              });

              WellDoneOverlay.show(context);

              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  widget.onNextStage?.call();
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return isPlacedCorrectly
                  ? Transform.translate(
                  offset: Offset(0, 10 * scale), // أصبح متناسباً
                  child: Transform.scale(
                    scale: .78,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: 250 * scale, // أصبح متناسباً
                      height: 250 * scale, // أصبح متناسباً
                      fit: BoxFit.cover,
                    ),
                  ))
                  : Image.network(
                shadow.imageUrl ?? '',
                width: 230 * scale, // أصبح متناسباً
              );
            },
          ),
        ),

        /// ===== Actor (اللي بيتسحب فعليًا) =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 0,
            bottom: -15 * scale, // أصبح متناسباً
            child: Draggable<String>(
              data: actor.targetedZoneId,

              /// 👈 ده اللي الطفل شايفه وهو بيسحب
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 220 * scale, // أصبح متناسباً
                ),
              ),

              /// 👈 نخفي الأصل
              childWhenDragging: const SizedBox(),

              /// 👈 الشكل قبل السحب
              child: Image.network(
                actor.imageUrl ?? '',
                width: 220 * scale, // أصبح متناسباً
              ),
            ),
          ),
      ],
    );
  }
}

 */