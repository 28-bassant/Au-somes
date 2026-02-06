import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel2Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const UpLevel2Stage4Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<UpLevel2Stage4Activity> createState() => UpLevel2Stage4ActivityState();
}

class UpLevel2Stage4ActivityState extends State<UpLevel2Stage4Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  ActivityElement? actor;
  ActivityElement? shadowCorrect;
  ActivityElement? shadowWrong;
  ActivityElement? anchor;

  final GlobalKey _shadowWrongKey = GlobalKey();
  final GlobalKey _shadowCorrectKey = GlobalKey();

  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;

  // Nullable AnimationController لتجنب LateInitializationError
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // تهيئة AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fetchActivity();
  }

  // جلب بيانات النشاط
  void fetchActivity() async {
    activity = await ApiManager.getActivity(
      ApiConstants.up_down_activityId,
      2,
      4,
    );

    actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
    shadowCorrect = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    shadowWrong = activity!.elements!.lastWhere((e) => e.role == 'Shadow');
    anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    setState(() => isLoading = false);
    playSound();
  }

  // تشغيل صوت النشاط
  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  // التعامل مع الإجابة الغلط
  void _handleWrongAnswer() {
    setState(() => _wrongAttempts++);
    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startShadowAnimation();
    }
  }

  // بدء اهتزاز الـ Shadow الصح عند المحاولة الثانية
  void _startShadowAnimation() {
    if (!_isAnimatingShadow) {
      setState(() => _isAnimatingShadow = true);
      _animationController?.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _animationController?.stop();
          _animationController?.value = 0;
          setState(() => _isAnimatingShadow = false);
        }
      });
    }
  }

  // التعامل مع نهاية السحب
  void _handleDragEnd(DraggableDetails details) {
    if (isPlacedCorrectly) return;

    final actorCenter = Offset(
      details.offset.dx + 200 / 2,
      details.offset.dy + 200 / 2,
    );

    // Shadow الصح
    final correctBox =
    _shadowCorrectKey.currentContext?.findRenderObject() as RenderBox?;
    if (correctBox != null) {
      final pos = correctBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        correctBox.size.width,
        correctBox.size.height,
      );
      if (rect.contains(actorCenter)) {
        _animationController?.stop();
        _animationController?.value = 0;
        setState(() {
          isPlacedCorrectly = true;
          _wrongAttempts = 0;
          _isAnimatingShadow = false;
        });
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 3), () {
          widget.onNextStage?.call();
        });
        return;
      }
    }

    // Shadow الغلط
    final wrongBox =
    _shadowWrongKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrongBox != null) {
      final pos = wrongBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        wrongBox.size.width,
        wrongBox.size.height,
      );
      if (rect.contains(actorCenter)) {
        _handleWrongAnswer();
      }
    }
  }
  void showWrongDialog() {
    DialogUtils.showMsg(
      context: context,
      msg: 'Try Again',
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading ||
        actor == null ||
        shadowCorrect == null ||
        shadowWrong == null ||
        anchor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 🪑 حجم الطرابيزة
    final anchorWidth = screenWidth * 2.6;
    final anchorHeight = screenHeight * 0.7;
    final anchorTop = screenHeight * 0.01;

    return Stack(
      children: [
        // Anchor
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
          top: 380,
          child: Container(
            key: _shadowWrongKey,
            width: 220,
            height: 240,
            child: Image.network(shadowWrong!.imageUrl ?? '', fit: BoxFit.cover),
          ),
        ),

        /// ✅ Shadow الصح مع اهتزاز
        Positioned(
          left: 100,
          top: 194,
          child: AnimatedBuilder(
            animation: _animationController ?? AlwaysStoppedAnimation(0),
            builder: (context, child) {
              double shake = 0;
              if (_isAnimatingShadow) {
                shake = 12 * sin((_animationController?.value ?? 0) * pi);
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
              child: isPlacedCorrectly
                  ? Transform.translate(
                offset: const Offset(0, -44),
                child: Transform.scale(
                  scale: .86,
                  child: Image.network(
                    actor!.imageUrl ?? '',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Image.network(
                shadowCorrect!.imageUrl ?? '',
                width: 250,
                height: 250,
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