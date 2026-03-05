import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  UpLevel1Stage2ActivityState createState() => UpLevel1Stage2ActivityState();
}

class UpLevel1Stage2ActivityState extends State<UpLevel1Stage2Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;
  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;
  late AudioPlayer _player;

  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fetchActivity();
  }

  void fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        1,
        2,
      );

      if (mounted) {
        setState(() {
          activity = response;
        });

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

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startAnswerAnimation();
    }
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer) {
      setState(() => _isAnimatingAnswer = true);

      _animationController.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _animationController.stop();
          _animationController.value = 0;
          setState(() => _isAnimatingAnswer = false);
        }
      });
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    final actorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Actor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final anchorWidth = screenWidth * 2.6;
        final anchorHeight = screenHeight * 0.7;
        final anchorTop = screenHeight * 0.14;

        final actorSize = anchorWidth * 0.15;
        final seatLevel = anchorTop + anchorHeight * 0.53;
        final actorTop = seatLevel - actorSize * 0.85;
        final actorLeft = (screenWidth - actorSize) / 2 ;

        final bottomCatSize = actorSize * 0.9;
        final bottomCatTop = anchorTop + anchorHeight - bottomCatSize * 1.25;
        final bottomCatLeft = (screenWidth - bottomCatSize) / 2.9;

        final containerLeft = width * 0.35;
        final containerTop = height * 0.26;
        final containerWidth = width * 0.31;
        final containerHeight = height * 0.18;

        final wrongContainerLeft = bottomCatLeft + 15;
        final wrongContainerTop = bottomCatTop +2;
        final wrongContainerWidth = containerWidth * .9;
        final wrongContainerHeight = containerHeight * .83;
        return Stack(
          children: [
            /// 🪑 الكرسي
            Positioned(
              top: anchorTop,
              left: (screenWidth - anchorWidth) / 2 + 15,
              child: Image.network(
                anchorElement.imageUrl ?? '',
                width: anchorWidth,
                height: anchorHeight,
                fit: BoxFit.contain,
              ),
            ),

            /// ✅ القطة الصح (مع اهتزاز)
            Positioned(
              top: actorTop,
              left: actorLeft,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double shake = 0;
                  if (_isAnimatingAnswer) {
                    shake = 12 * sin(_animationController.value * pi);
                  }
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: Image.network(
                  actorElement.imageUrl ?? '',
                  width: actorSize,
                  height: actorSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// ❌ القطة الغلط
            Positioned(
              top: bottomCatTop,
              left: bottomCatLeft,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: bottomCatSize,
                height: bottomCatSize,
                fit: BoxFit.contain,
              ),
            ),

            /// الضغط على الغلط
            Positioned(
              left: wrongContainerLeft,
              top: wrongContainerTop,
              child: GestureDetector(
                onTap: _handleWrongAnswer,
                child: Container(
                  width: wrongContainerWidth,
                  height: wrongContainerHeight,
                  color: Colors.transparent,
                ),
              ),
            ),

            /// الضغط على الصح
            Positioned(
              left: containerLeft,
              top: containerTop,
              child: GestureDetector(
                onTap: () {
                  _animationController.stop();
                  _animationController.value = 0;

                  setState(() {
                    _wrongAttempts = 0;
                    _isAnimatingAnswer = false;
                  });

                  WellDoneOverlay.show(context);

                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


/*
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  UpLevel1Stage2ActivityState createState() => UpLevel1Stage2ActivityState();
}

class UpLevel1Stage2ActivityState extends State<UpLevel1Stage2Activity> {
  ActivityResponse? activity;
  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;
  late AudioPlayer _player;

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
        1,
        2,
      );

      if (mounted) {
        setState(() {
          activity = response;
        });

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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final actorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Actor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        /// 🪑 حجم الكرسي
        final anchorWidth = screenWidth * 2.6;
        final anchorHeight = screenHeight * 0.7;

        /// مكان بداية الكرسي من فوق
        final anchorTop = screenHeight * 0.14;

        /// حجم القطة
        final actorSize = anchorWidth * 0.20;

        /// مكان الجلوس على الكرسي
        final seatLevel = anchorTop + anchorHeight * 0.53;

        /// موقع القطة بحيث رجلها تلمس الكرسي
        final actorTop = seatLevel - actorSize * 0.85;
        final actorLeft = (screenWidth - actorSize) / 2 + 16;

        // موقع وحجم الكونتينر الشفاف على القطة
        final containerLeft = width * 0.40;
        final containerTop = height * 0.23;
        final containerWidth = width * 0.28;
        final containerHeight = height * 0.2;

        final containerRect =
        Rect.fromLTWH(containerLeft, containerTop, containerWidth, containerHeight);

        return Stack(
          children: [
            // 🪑 الكرسي
            Positioned(
              top: anchorTop,
              left: (screenWidth - anchorWidth) / 2 + 15,
              child: Image.network(
                anchorElement.imageUrl ?? '',
                width: anchorWidth,
                height: anchorHeight,
                fit: BoxFit.contain,
              ),
            ),

            // 🐱 القطة
            Positioned(
              top: actorTop,
              left: actorLeft,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
                fit: BoxFit.contain,
              ),
            ),

            // 🌟 GestureDetector يغطي الشاشة كلها للتحقق من الضغط
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final tap = box.globalToLocal(details.globalPosition);

                  if (containerRect.contains(tap)) {
                    // الضغط داخل القطة
                    WellDoneOverlay.show(context);
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        widget.onNextStage?.call();
                      }
                    });
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

 */