import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<InsideLevel2Stage1Activity> createState() =>
      InsideLevel2Stage1ActivityState();
}

class InsideLevel2Stage1ActivityState
    extends State<InsideLevel2Stage1Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow1; // الصح
  late ActivityElement shadow2; // الغلط
  late ActivityElement anchor;

  final GlobalKey _shadow2Key = GlobalKey();
  final GlobalKey _shadow1Key = GlobalKey();

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  AnimationController? _animationController;
  bool _usedHint = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadActivity();
  }
  void resetActivity() {
    setState(() {
      isPlacedCorrectly = false;
      _wrongAttempts = 0;
      playSound();
      // أي حالة داخلية أخرى عايزة reset
    });
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.inside_outside_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // البحث عن العناصر
        actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow1 = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        shadow2 = _activity!.elements!.lastWhere((e) => e.role == 'Shadow');
        anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        // تحميل الصور أولاً
        await _preloadImages(_activity!);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
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
  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      print("RESULT: ${result?.isPassed}");

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
        final double shadow2Left = 10 * scale;
        final double shadow2Top = 180 * scale;
        final double shadow2Width = 100 * scale;
        final double anchorRight = 5 * scale;
        final double anchorTop = 130 * scale;
        final double anchorWidth = 280 * scale;
        final double shadow1Right = 132 * scale;
        final double shadow1Top = 231 * scale;
        final double shadow1Width = 50 * scale;
        final double actorPlacedWidth = 100 * scale;
        final double actorLeft = 10 * scale;
        final double actorBottom = 240 * scale;
        final double actorWidth = 100 * scale;
        final double actorFeedbackWidth = 100 * scale;
        final double actorPlacedOffset = -5 * scale;
        final double wrongPointSize = 50 * scale;
        final double shakeIntensity = 20 * scale * 0.06;

        return Stack(
          children: [
            /// ===== Shadow الغلط =====
            Positioned(
              left: shadow2Left,
              top: shadow2Top,
              child: Container(
                key: _shadow2Key,
                child: DragTarget<String>(
                  onWillAccept: (data) => data == actor.id,
                  onAccept: (_) {
                    _handleWrongAnswer();
                  },
                  builder: (context, _, __) {
                    return Image.network(
                      shadow1.imageUrl ?? '',
                      width: shadow2Width,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            /// ===== الخلفية =====
            Positioned(
              right: anchorRight,
              top: anchorTop,
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
              ),
            ),

            /// ===== Shadow الصح مع الحركة =====
            Positioned(
              right: shadow1Right,
              top: shadow1Top,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  // حساب قيمة الحركة للاهتزاز
                  double shakeValue = 0;
                  if (_isAnimatingShadow) {
                    // إنشاء حركة اهتزازية متجاوبة
                    shakeValue = shakeIntensity * sin(_animationController!.value * 2 *2* pi);
                  }

                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Container(
                  key: _shadow1Key,
                  width: shadow1Width,
                  child: DragTarget<String>(
                    onWillAccept: (data) => data == actor.id,
                    onAccept: (_) async {
                      setState(() {
                        isPlacedCorrectly = true;
                        _wrongAttempts = 0;
                        _isAnimatingShadow = false;
                      });

                      _animationController?.stop();
                      _animationController?.value = 0;

                      await _logProgress();

                      WellDoneOverlay.show(context);

                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          widget.onNextStage?.call();
                        }
                      });
                    },
                    builder: (context, _, __) {
                      return isPlacedCorrectly
                          ? Transform.translate(
                        offset: Offset(0, actorPlacedOffset),
                        child: Image.network(
                          actor.imageUrl ?? '',
                          width: actorPlacedWidth,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.network(
                        shadow2.imageUrl ?? '',
                        width: shadow1Width,
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
                left: actorLeft,
                bottom: actorBottom-50,
                child: Draggable<String>(
                  data: actor.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      AppAssets.dress_outside,
                      width: actorFeedbackWidth,
                    ),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Image.asset(
                    AppAssets.dress_outside,
                    width: actorWidth,
                  ),
                  onDragEnd: (details) async {
                    if (isPlacedCorrectly) return;

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
                        setState(() {
                          isPlacedCorrectly = true;
                          _wrongAttempts = 0;
                          _isAnimatingShadow = false;
                        });

                        _animationController?.stop();
                        _animationController?.value = 0;

                        await _logProgress();

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
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/*import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  InsideLevel2Stage1ActivityState createState() =>
      InsideLevel2Stage1ActivityState();
}

class InsideLevel2Stage1ActivityState
    extends State<InsideLevel2Stage1Activity> {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.inside_outside_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        // البحث عن العناصر
        actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        // تحميل الصور أولاً
        await _preloadImages(_activity!);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
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
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
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
        final double anchorRight = 5 * scale;
        final double anchorTop = 130 * scale;
        final double anchorWidth = 280 * scale;
        final double shadowRight = 131 * scale;
        final double shadowTop = 230 * scale;
        final double shadowWidth = 50 * scale;
        final double actorLeft = 20 * scale;
        final double actorTop = 220 * scale;
        final double actorWidth = 100 * scale;
        final double actorFeedbackWidth = 100 * scale;
        final double actorPlacedOffset = -5 * scale;

        return Stack(
          children: [
            /// ===== Anchor (خلفية ثابتة) =====
            Positioned(
              right: anchorRight,
              top: anchorTop,
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
              ),
            ),

            /// ===== Shadow (مكان الإسقاط) =====
            Positioned(
              right: shadowRight,
              top: shadowTop,
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
                    offset: Offset(0, actorPlacedOffset),
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: shadowWidth,
                    ),
                  )
                      : Image.network(
                    shadow.imageUrl ?? '',
                    width: shadowWidth,
                  );
                },
              ),
            ),

            /// ===== Actor (اللي بيتسحب فعليًا) =====
            if (!isPlacedCorrectly)
              Positioned(
                left: actorLeft,
                top: actorTop,
                child: Draggable<String>(
                  data: actor.targetedZoneId,

                  /// 👈 ده اللي الطفل شايفه وهو بيسحب
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      AppAssets.shirtOutside,
                      width: actorFeedbackWidth,
                    ),
                  ),

                  /// 👈 نخفي الأصل
                  childWhenDragging: const SizedBox(),

                  /// 👈 الشكل قبل السحب
                  child: Image.asset(
                    AppAssets.shirtOutside,
                    width: actorWidth,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

 */