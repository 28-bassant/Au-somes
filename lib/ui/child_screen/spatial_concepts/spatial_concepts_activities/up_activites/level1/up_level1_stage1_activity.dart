import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  UpLevel1Stage1ActivityState createState() => UpLevel1Stage1ActivityState();
}

class UpLevel1Stage1ActivityState extends State<UpLevel1Stage1Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;
  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;
  late AudioPlayer _player;

  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  late AnimationController _animationController;
  bool _usedHint = false;

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
  bool isPlacedCorrectly = false;
  void resetActivity() {
    setState(() {
      isPlacedCorrectly = false;
      _wrongAttempts = 0;
      playSound();
      // أي حالة داخلية أخرى عايزة reset
    });
  }

  void fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        1,
        1,
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
      _usedHint = true;
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
        final bottomCatTop = anchorTop + anchorHeight - bottomCatSize * 1.19;
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
                onTapDown: (details) async {
                  print(" RIGHT ANSWER CLICKED");
                  setState(() {
                    _wrongAttempts = 0;
                    _isAnimatingAnswer = false;
                  });

                  _animationController?.stop();
                  _animationController?.value = 0;

                  // 1. تسجيل المحاولة
                  final result = await ApiManager.logAttemptStatus(
                    phaseId: activity!.phaseId!,
                    userHint: _usedHint,
                  );

                  print(" RESULT: ${result?.isPassed}");

                  // 2. لو الإجابة صحيحة → حدّث التقدم
                  if (result?.isPassed == true) {
                    await ApiManager.getProgressSummary();
                  }

                  // 3. عرض النجاح
                  WellDoneOverlay.show(context);

                  // 4. الانتقال للمرحلة التالية
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

