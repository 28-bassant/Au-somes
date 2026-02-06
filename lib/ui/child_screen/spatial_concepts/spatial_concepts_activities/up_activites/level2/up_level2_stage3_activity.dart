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
class UpLevel2Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const UpLevel2Stage3Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<UpLevel2Stage3Activity> createState() => UpLevel2Stage3ActivityState();
}

class UpLevel2Stage3ActivityState extends State<UpLevel2Stage3Activity>
    with SingleTickerProviderStateMixin {
  // 🔹 النشاط نفسه
  ActivityResponse? activity;

  // 🔹 حالة التحميل
  bool isLoading = true;

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
    activity = await ApiManager.getActivity(
      ApiConstants.up_down_activityId,
      2,
      3,
    );

    // 🔹 تعيين العناصر حسب الدور
    actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
    shadowCorrect = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    shadowWrong = activity!.elements!.lastWhere((e) => e.role == 'Shadow');
    anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    // 🔹 تغيير حالة التحميل
    setState(() => isLoading = false);

    // 🔹 تشغيل الصوت بعد تحميل النشاط
    playSound();
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

    // 🔹 حساب مركز القطّة بعد السحب
    final actorCenter = Offset(
      details.offset.dx + 200 / 2,
      details.offset.dy + 200 / 2,
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
          widget.onNextStage?.call();
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

 if (isLoading || actor == null || shadowCorrect==null || shadowWrong==null ||anchor==null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
    left: 50,
    top: 390,
    child: Container(
    key: _shadowWrongKey,
    width: 230,
    height: 250,
    child: Image.network(shadowWrong!.imageUrl ?? '', fit: BoxFit.cover),
    ),
    ),

    /// ✅ Shadow الصح مع الاهتزاز
    Positioned(
    left: 100,
    top: 185,
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
    width: 250,
    height: 250,
    // 🔹 إظهار القطّة مكان الشادو عند الإجابة الصحيحة
    child: isPlacedCorrectly
    ? Transform.translate(
    offset: const Offset(0, -44),
    child: Transform.scale(
    scale: .86,
    child: Image.network(
    actor!.imageUrl ?? '',
    width: 300,
    height: 300,
    fit: BoxFit.cover,
    ),
    ),
    )
        : Image.network(
    shadowCorrect!.imageUrl ?? '',
    width: 300,
    height: 300,
    fit: BoxFit.cover,
    ),
    ),
    ),
    ),

    /// 🐱 Actor draggable
    if (!isPlacedCorrectly)
    Positioned(
    right: 0,
    bottom: -15,
    child: Draggable<String>(
    data: actor!.id,
    feedback: Material(
    color: Colors.transparent,
      child: Image.network(actor!.imageUrl ?? '', width: 200),
    ),
      childWhenDragging: const SizedBox(),
      child: Image.network(actor!.imageUrl ?? '', width: 200),
      onDragEnd: _handleDragEnd,
    ),
    ),
      ],
    );
  }
}
