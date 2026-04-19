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

class NearFarLevel4Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel4Stage3({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  NearFarLevel4Stage3State createState() => NearFarLevel4Stage3State();
}

class NearFarLevel4Stage3State extends State<NearFarLevel4Stage3>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  // لإدارة المحاولات
  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false; // تغيير الاسم من _isAnimatingActor إلى _isAnimatingShadow
  AnimationController? _animationController;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // تحميل النشاط مرة واحدة
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.near_far_activityId,
        2,
        3,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // حفظ العناصر
        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = activity.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = activity.elements!.firstWhere((e) => e.role == 'Anchor');


        await _preloadImages(activity);

        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  void _handleWrongDrop() {
    _wrongAttempts++;
    if (_wrongAttempts == 1) {
      // المرة الأولى: صوت Try Again
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      // المرة الثانية: هزة Shadow الصحيح
      _startShadowShake(); // تغيير اسم الدالة
    }
  }

  void _startShadowShake() { // تغيير اسم الدالة
    if (!_isAnimatingShadow && _animationController != null) { // تغيير الشرط
      setState(() {
        _isAnimatingShadow = true; // تغيير القيمة
      });
      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isAnimatingShadow = false; // تغيير القيمة
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double scale = screenWidth / 400.0;

    final double anchorWidth = 250 * scale;
    final double shadowLeft = 170 * scale;
    final double shadowTop = 365 * scale;
    final double shadowWidth = 80 * scale;
    final double shadowBallWidth = 70 * scale;
    final double actorRight = 165 * scale;
    final double actorBottom = -15 * scale;
    final double actorWidth = 70 * scale;
    final double actorFeedbackWidth = 80 * scale;
    final double wrongShadowLeft = screenWidth - 90 * scale;
    final double wrongShadowTop = shadowTop;

    return Stack(
      children: [
        /// ===== Anchor =====
        Align(
          alignment: Alignment.centerRight,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: anchorWidth,
            fit: BoxFit.contain,
          ),
        ),

        /// ===== Shadow wrong =====
        Positioned(
          right: shadowLeft,
          top: shadowTop,

          child: DragTarget<String>(
            onWillAccept: (data) => data == shadow.id,
            onAccept: (data) {
              _handleWrongDrop();
            },
            builder: (context, candidateData, rejectedData) {
              return Image.network(shadow.imageUrl ?? '', width: shadowBallWidth);
            },
          ),
        ),

        /// ===== Shadow correct =====
        Positioned(
          right: wrongShadowLeft,
          top: wrongShadowTop,
          child: AnimatedBuilder( // إضافة AnimatedBuilder لتحريك Shadow
            animation: _animationController!,
            builder: (context, child) {
              double shakeOffset = 0;
              if (_isAnimatingShadow) { // استخدام _isAnimatingShadow بدلاً من _isAnimatingActor
                shakeOffset = 12 * sin(_animationController!.value * pi);
              }
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: child,
              );
            },
            child: DragTarget<String>(
              onWillAccept: (data) => data == shadow.id,
              onAccept: (data) {
                setState(() {
                  isPlacedCorrectly = true;
                });
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) widget.onNextStage?.call();
                });
              },
              builder: (context, candidateData, rejectedData) {
                return isPlacedCorrectly
                    ? Container(
                  width: shadowWidth,
                  height: shadowWidth,
                  child: Image.network(actor.imageUrl ?? '',
                      fit: BoxFit.contain),
                )
                    : Image.network(shadow.imageUrl ?? '', width: shadowBallWidth);
              },
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
          Positioned(
            right: actorRight,
            bottom: actorBottom + 20,
            child: Draggable<String>( // إزالة AnimatedBuilder من هنا
              data: actor.targetedZoneId,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  width: actorFeedbackWidth,
                  height: actorFeedbackWidth,
                  child: Image.network(actor.imageUrl ?? '',
                      fit: BoxFit.contain),
                ),
              ),
              childWhenDragging: const SizedBox(),
              child: Container(
                width: actorWidth,
                height: actorWidth,
                child: Image.network(actor.imageUrl ?? '', fit: BoxFit.contain),
              ),
            ),
          ),
      ],
    );
  }
}
