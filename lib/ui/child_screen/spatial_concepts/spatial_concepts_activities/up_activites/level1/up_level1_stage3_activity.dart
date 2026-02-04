import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
class UpLevel1Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel1Stage3Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  UpLevel1Stage3ActivityState createState() => UpLevel1Stage3ActivityState();
}

class UpLevel1Stage3ActivityState extends State<UpLevel1Stage3Activity> {
  ActivityResponse? activity;
  bool isLoading = true;
  late AudioPlayer _player;

  // نظام المساعدات
  int wrongAttempts = 0; // عدد المرات اللي ضغط فيها غلط
  bool showMoveHint = false;
  bool showBorderHint = false;
  bool showStrongHint = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.up_down_activityId,
      1,
      3,
    );

    setState(() {
      activity = response;
      isLoading = false;
    });

    playSound();
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;

    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  /// ❌ إجابة غلط
  void handleWrongAnswer() {
    wrongAttempts++;

    if (wrongAttempts == 1) {
      // أول غلط → صوت فقط
      TryAgainSound.play();
    } else if (wrongAttempts == 2) {
      // ثاني غلط → حركة خفيفة للقطه الصح
      setState(() => showMoveHint = true);
    } else if (wrongAttempts == 3) {
      // ثالث غلط → إطار حول القطه الصح
      setState(() => showBorderHint = true);
    } else if (wrongAttempts >= 4) {
      // رابع غلط → توهج قوي + إعادة النشاط إذا ما ضغطش صح بعدها
      setState(() => showStrongHint = true);
      Future.delayed(const Duration(seconds: 2), () {
        resetActivity();
      });
    }
  }

  /// ✅ إجابة صح
  void handleCorrectAnswer() {
    // الإجابة صحيحة → تنتقل المرحلة التالية مباشرة
    WellDoneOverlay.show(context);
    Future.delayed(const Duration(seconds: 3), () {
      resetActivity(); // نعيد إعداد المساعدات للمرحلة الجديدة
      widget.onNextStage?.call();
    });
  }

  void resetActivity() {
    setState(() {
      wrongAttempts = 0;
      showMoveHint = false;
      showBorderHint = false;
      showStrongHint = false;
    });
    playSound();
  }

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

    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;

      final anchorWidth = screenWidth * 2.6;
      final anchorHeight = screenHeight * 0.7;
      final anchorTop = screenHeight * 0.14;

      final actorSize = anchorWidth * 0.20;
      final seatLevel = anchorTop + anchorHeight * 0.53;
      final actorTop = seatLevel - actorSize * 0.85;
      final actorLeft = (screenWidth - actorSize) / 2 + 16;

      final bottomCatSize = actorSize * 0.8;
      final bottomCatTop = anchorTop + anchorHeight - bottomCatSize * 1.2;
      final bottomCatLeft = (screenWidth - bottomCatSize) / 2.9;

      final containerLeft = width * 0.40;
      final containerTop = height * 0.23;
      final containerWidth = width * 0.28;
      final containerHeight = height * 0.2;

      final wrongContainerLeft = bottomCatLeft + 40;
      final wrongContainerTop = bottomCatTop + 35;
      final wrongContainerWidth = containerWidth * .9;
      final wrongContainerHeight = containerHeight * .75;
      return Stack(
        children: [
          // 🪑 الكرسي
          Positioned(
            top: anchorTop,
            left: (screenWidth - anchorWidth) / 2 + 15,
            child: Image.network(anchorElement.imageUrl ?? '',
                width: anchorWidth, height: anchorHeight, fit: BoxFit.contain),
          ),

          /// ⭐ القطة الصح + الحركة
          Positioned(
            top: actorTop,
            left: actorLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: showMoveHint ? 6 : 0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(showMoveHint ? value : 0, 0),
                  child: child,
                );
              },
              child: Image.network(actorElement.imageUrl ?? '',
                  width: actorSize, height: actorSize, fit: BoxFit.contain),
            ),
          ),

          /// إطار
          if (showBorderHint)
            Positioned(
              top: actorTop - 5,
              left: actorLeft - 5,
              child: Container(
                width: actorSize + 10,
                height: actorSize + 10,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          /// توهج قوي
          if (showStrongHint)
            Positioned(
              top: actorTop - 10,
              left: actorLeft - 10,
              child: Container(
                width: actorSize + 20,
                height: actorSize + 20,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.8),
                    blurRadius: 25,
                    spreadRadius: 8,
                  )
                ]),
              ),
            ),

          /// القطة الغلط
          Positioned(
            top: bottomCatTop,
            left: bottomCatLeft,
            child: Image.network(actorElement.imageUrl ?? '',
                width: bottomCatSize, height: bottomCatSize, fit: BoxFit.contain),
          ),

          /// الضغط على الغلط
          Positioned(
            left: wrongContainerLeft,
            top: wrongContainerTop,
            child: GestureDetector(
              onTap: handleWrongAnswer,
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
              onTap: handleCorrectAnswer,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      );
    });
  }
}