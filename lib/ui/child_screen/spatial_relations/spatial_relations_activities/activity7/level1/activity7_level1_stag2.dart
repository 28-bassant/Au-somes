import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity7Level1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const Activity7Level1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<Activity7Level1Stage2> createState() => Activity7Level1Stage2State();
}

class Activity7Level1Stage2State extends State<Activity7Level1Stage2>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  late ActivityResponse _activity;
  ActivityResponse? _loadedActivity;

  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;
  bool isPlacedCorrectly = false;

  final ValueNotifier<double> ballScale = ValueNotifier(1.0);
  late Offset basketCenter;

  int _wrongAttempts = 0;
  bool _isAnimatingBasket = false;
  AnimationController? _basketAnimationController;
  Animation<Offset>? _basketOffsetAnimation;
  bool _usedHint = false;
  bool _progressSent = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();

    _basketAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<void> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.sr_right_left_activityId,
      2,
      3,
    );

    final urls = _activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in urls) {
      await precacheImage(NetworkImage(url!), context);
    }

    setState(() {
      _imagesLoaded = true;
      _loadedActivity = _activity;
    });
  }

  Future<void> playSound() async {
    if (_activity.audioUrl == null || _activity.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity.audioUrl!));
  }

  void repeatSound() => playSound();

  // دالة للتعامل مع الخطأ
  void _handleWrongAnswer() {
    _wrongAttempts++;

    if (_wrongAttempts == 1) {
      TryAgainSound.play(); // الصوت عند الخطأ الأول
    } else if (_wrongAttempts == 2) {
      _startBasketAnimation(); // تحريك السلّة عند الخطأ الثاني
    }
  }

  void _startBasketAnimation() {
    if (_isAnimatingBasket || _basketAnimationController == null) return;

    _basketOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0), // تحريك بسيط لليمين (5% من الشاشة)
    ).animate(
      CurvedAnimation(
        parent: _basketAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    _basketAnimationController!.repeat(reverse: true);

    setState(() {
      _isAnimatingBasket = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      _basketAnimationController?.stop();
      _basketAnimationController?.value = 0;
      setState(() => _isAnimatingBasket = false);
    });
  }
  Future<void> _logProgress() async {
    if (_progressSent) return;

    try {
      _progressSent = true;

      final result = await ApiManager.logAttemptStatus(
        phaseId: _loadedActivity!.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_loadedActivity!.phaseId}");
      print("RESULT = ${result?.isPassed}");

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
      }
    } catch (e) {
      print("Progress error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    ballScale.dispose();
    _basketAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagesLoaded || _loadedActivity == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final actor =
    _loadedActivity!.elements!.firstWhere((e) => e.role == 'Actor');
    final shadow = _loadedActivity!.elements!.firstWhere((e) => e.role == 'Shadow');
    final anchors =
    _loadedActivity!.elements!.where((e) => e.role == 'Anchor').toList();
    final childAnchor = anchors[0]; // الطفل
    final court = anchors[1]; // الملعب

    if (!_hasPlayedSound) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        playSound();
        _hasPlayedSound = true;
      });
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final basketSize = screenWidth * 0.35;
          final childSize = screenWidth * 0.28;
          final ballSize = screenWidth * 0.17;
          final basketTop = screenHeight * 0.18;
          final childLeft = screenWidth / 2 - childSize / 2;
          final childTop = screenHeight * 0.55;
          final ballStartLeft = childLeft + childSize * 0.001;
          final ballStartTop = childTop + childSize * 1.55;

          basketCenter = Offset(
            screenWidth - (screenWidth * 0.08) - basketSize / 2,
            basketTop + basketSize / 2,
          );

          return Stack(
            children: [
              /// ملعب الخلفية
              Positioned.fill(
                child: Image.network(
                  court.imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),

              ///  سلة الشمال (غلط)
              Positioned(
                left: screenWidth * 0.02,
                top: basketTop,
                child: Image.network(
                  shadow.imageUrl ?? '',
                  width: basketSize,
                ),
              ),

              /// سلة اليمين (الصح) مع تحريك عند الخطأ الثاني
              Positioned(
                right: screenWidth * 0.02,
                top: basketTop,
                child: AnimatedBuilder(
                  animation: _basketAnimationController!,
                  builder: (context, child) {
                    Offset offset = Offset.zero;
                    if (_isAnimatingBasket && _basketOffsetAnimation != null) {
                      offset = _basketOffsetAnimation!.value;
                    }
                    return Transform.translate(
                      offset: Offset(offset.dx * screenWidth, 0), // نحرك في المحور X
                      child: child,
                    );
                  },
                  child: Image.network(shadow.imageUrl ?? '', width: basketSize),
                ),
              ),
              
              /// DragTarget صغير عند فتحة السلة فقط
              Positioned(
                right:screenWidth*.07,
                top: basketTop + basketSize * 0.15,
                width: basketSize * 0.71,   // عرض صغير
                height: basketSize * 0.33, // ارتفاع صغير
                child: !isPlacedCorrectly
                    ? DragTarget<String>(
                  onWillAccept: (data) => true,
                  onAccept: (data) async {
                    if (data == actor.targetedZoneId) {
                      setState(() {
                        isPlacedCorrectly = true;
                      });

                      await _logProgress();

                      WellDoneOverlay.show(
                        context,
                        duration: const Duration(seconds: 2),
                      );

                      Future.delayed(const Duration(seconds: 2), () {
                        widget.onNextStage?.call();
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(


                      color: Colors.transparent,
                    );
                  },
                )
                    : const SizedBox(),
              ),

              // DragTarget على سلّة الشمال (الغلط)
              Positioned(
                left:screenWidth*.07,
                top: basketTop + basketSize * 0.15,
                width: basketSize * 0.71,   // عرض صغير
                height: basketSize * 0.33,
                child: !isPlacedCorrectly
                    ? DragTarget<String>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    _usedHint = true;
                    _handleWrongAnswer();
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(color: Colors.transparent);
                  },
                )
                    : const SizedBox(),
              ),

              ///  الطفل في النص
              Positioned(
                left: childLeft,
                top: childTop,
                child: Image.network(
                  childAnchor.imageUrl ?? '',
                  width: childSize,
                ),
              ),

              ///  الكرة قبل السحب
              if (!isPlacedCorrectly)
                Positioned(
                  left: ballStartLeft,
                  top: ballStartTop,
                  child: Draggable<String>(
                    data: actor.targetedZoneId,
                    onDragUpdate: (details) {
                      final dx = details.globalPosition.dx - basketCenter.dx;
                      final dy = details.globalPosition.dy - basketCenter.dy;
                      final distance = math.sqrt(dx * dx + dy * dy);
                      double scale = (distance / (screenWidth * 1.1)).clamp(0.6, 1.0);
                      ballScale.value = scale;
                    },
                    onDraggableCanceled: (_, __) {
                      ballScale.value = 1.0;
                    },
                    onDragEnd: (_) {
                      ballScale.value = 1.0;
                    },
                    feedback: ValueListenableBuilder<double>(
                      valueListenable: ballScale,
                      builder: (context, scale, child) {
                        return Material(
                          color: Colors.transparent,
                          child: Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                        );
                      },
                      child: Image.network(actor.imageUrl ?? '', width: ballSize),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: Image.network(actor.imageUrl ?? '', width: ballSize),
                    ),
                    child: Image.network(actor.imageUrl ?? '', width: ballSize),
                  ),
                ),

              ///  الكرة داخل السلّة بعد النجاح
              if (isPlacedCorrectly)
                Positioned(
                  right: screenWidth * 0.08 + basketSize * 0.19,
                  top: basketTop + basketSize * 0.37,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: ballSize * 0.57,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
