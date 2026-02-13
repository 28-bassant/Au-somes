import 'package:flutter/material.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/well_done_overlay.dart';
import '../../../../../../models/activities/activity_response.dart';
class DownLevel1Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const DownLevel1Stage4Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  DownLevel1Stage4ActivityState createState() => DownLevel1Stage4ActivityState();
}

class DownLevel1Stage4ActivityState extends State<DownLevel1Stage4Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;
  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;
  late AudioPlayer _player;

  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

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
        4,
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
    if (_wrongAttempts == 0) {
      // أول مرة: صوت Try Again
      TryAgainSound.play();
      setState(() {
        _wrongAttempts = 1;
      });
    } else if (_wrongAttempts == 1 && !_isAnimatingAnswer) {
      // المرة الثانية: شغل حركة الإجابة الصحيحة مرة واحدة
      _startAnswerAnimation();
      setState(() {
        _wrongAttempts = 2; // تمنع إعادة الحركة في أي ضغط بعد كده
      });
    }
  }


  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() => _isAnimatingAnswer = true);
      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _animationController!.stop();
          _animationController!.value = 0;
          setState(() => _isAnimatingAnswer = false);
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    final anchorElement = activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    final actorElement = activity!.elements!.firstWhere((e) => e.role == 'Actor');

    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;

      // 🪑 حجم ومكان الكرسي
      final anchorWidth = screenWidth * 2.6;
      final anchorHeight = screenHeight * 0.7;
      final anchorTop = screenHeight * 0.14;

      //  حجم ومكان القطة الخطا
      final actorSize = anchorWidth * 0.19;
      final seatLevel = anchorTop + anchorHeight * 0.53;
      final actorTop = seatLevel - actorSize * 0.85;
      final actorLeft = (screenWidth - actorSize) / 2 + 16;

      //  حجم ومكان القطة الصح
      final bottomCatSize = actorSize * 0.88;
      final bottomCatTop = anchorTop + anchorHeight - bottomCatSize * 1.2;
      final bottomCatLeft = (screenWidth - bottomCatSize) / 2.9;

      //  الكونتينر على القطة الخطا
      final  wrongContainerLeft = width * 0.41;
      final  wrongContainerTop = height * 0.258;
      final  wrongContainerWidth = width * 0.28;
      final  wrongContainerHeight = height * 0.172;
      final wrongRect =
      Rect.fromLTWH(wrongContainerLeft, wrongContainerTop, wrongContainerWidth, wrongContainerHeight);

      //  الكونتينر على القطة الصح
      final containerLeft = bottomCatLeft + 40;
      final containerTop = bottomCatTop + 34;
      final containerWidth = wrongContainerWidth * 0.9;
      final containerHeight = wrongContainerHeight * 0.94;
      final containerRect = Rect.fromLTWH(
          containerLeft, containerTop, containerWidth, containerHeight);
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

          /// ✅ القطة الخطا
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

          /// ❌ القطة الصح مع اهتزاز
          Positioned(
            top: bottomCatTop,
            left: bottomCatLeft,
            child: AnimatedBuilder(
              animation: _animationController ?? AlwaysStoppedAnimation(0),
              builder: (context, child) {
                double shake = 0;
                if (_isAnimatingAnswer) {
                  shake = 12 * sin((_animationController?.value ?? 0) * pi);
                }
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
            child: Image.network(
              actorElement.imageUrl ?? '',
              width: bottomCatSize,
              height: bottomCatSize,
              fit: BoxFit.contain,
            ),
          ),),

          /// 🌟 الضغط على القطة الخطأ
          Positioned(
            left: wrongContainerLeft,
            top: wrongContainerTop,
            child: GestureDetector(
              onTap: _handleWrongAnswer,
              child: Container(
                color: Colors.transparent,
                width: wrongContainerWidth,
                height: wrongContainerHeight,
              ),
            ),
          ),

          /// 🌟 الضغط على القطة الصحيحة
          Positioned(
            left: containerLeft,
            top: containerTop,
            child: GestureDetector(
              onTap: () {
                _animationController?.stop();
                _animationController?.value = 0;
                setState(() {
                  _wrongAttempts = 0;
                  _isAnimatingAnswer = false;
                });
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    widget.onNextStage?.call();
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                width: containerWidth,
                height: containerHeight,
              ),
            ),
          ),
        ],
      );
    });
  }
}