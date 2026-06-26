import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class TowerBuildingLevel3Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const TowerBuildingLevel3Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<TowerBuildingLevel3Stage2> createState() =>
      TowerBuildingLevel3Stage2State();
}

class TowerBuildingLevel3Stage2State extends State<TowerBuildingLevel3Stage2> {
  late AudioPlayer _player;
  ActivityResponse? _activity;

  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  // حالة استبدال كل Shadow
  bool _firstShadowReplaced = false;   // Shadow الأول
  bool _secondShadowReplaced = false;  // Shadow الثاني
  bool _thirdShadowReplaced = false;   // Shadow الثالث
  bool _fourthShadowReplaced = false;  // Shadow الرابع
  bool _fifthShadowReplaced = false;   // Shadow الخامس

  // لتتبع الأصوات التي تم تشغيلها
  bool _firstSoundPlayed = false;
  bool _secondSoundPlayed = false;
  bool _thirdSoundPlayed = false;
  bool _fourthSoundPlayed = false;
  bool _fifthSoundPlayed = false;

  // GlobalKeys لتحديد مواقع العناصر
  final GlobalKey _firstShadowKey = GlobalKey();
  final GlobalKey _secondShadowKey = GlobalKey();
  final GlobalKey _thirdShadowKey = GlobalKey();
  final GlobalKey _fourthShadowKey = GlobalKey();
  final GlobalKey _fifthShadowKey = GlobalKey();
  bool _usedHint = false;
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.tower_building_activityId,
        3,
        2,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

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
      print('Error loading activity: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    await Future.wait(images.map((url) => precacheImage(NetworkImage(url!), context)));
    setState(() => _imagesLoaded = true);
  }

  bool _isActorOverShadow(
      DraggableDetails details,
      double actorSize,
      GlobalKey shadowKey) {
    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final shadowBox = shadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowBox != null) {
      final shadowPosition = shadowBox.localToGlobal(Offset.zero);
      final shadowRect = Rect.fromLTWH(
        shadowPosition.dx,
        shadowPosition.dy,
        shadowBox.size.width,
        shadowBox.size.height,
      );

      return shadowRect.contains(actorCenter);
    }
    return false;
  }

  // معالجة Actor الأول (index 3) - يذهب إلى Shadow الأول
  void _handleFirstActorDragEnd(DraggableDetails details, double actorSize) {
    if (_firstShadowReplaced) return;

    if (_isActorOverShadow(details, actorSize, _firstShadowKey)) {
      setState(() {
        _firstShadowReplaced = true;
      });

      // تشغيل صوت الإجابة الصحيحة
      if (!_firstSoundPlayed) {
        _firstSoundPlayed = true;
        TrueAnswerSound.play();
      }

      // التحقق من اكتمال جميع Shadows
      if (_firstShadowReplaced && _secondShadowReplaced &&
          _thirdShadowReplaced && _fourthShadowReplaced && _fifthShadowReplaced) {
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 2), () {
          widget.onNextStage?.call();
        });
      }
    }
  }

  // معالجة Actor الثاني (index 2) - يذهب إلى Shadow الثاني
  void _handleSecondActorDragEnd(DraggableDetails details, double actorSize) {
    if (_secondShadowReplaced) return;

    if (_isActorOverShadow(details, actorSize, _secondShadowKey)) {
      setState(() {
        _secondShadowReplaced = true;
      });

      // تشغيل صوت الإجابة الصحيحة
      if (!_secondSoundPlayed) {
        _secondSoundPlayed = true;
        TrueAnswerSound.play();
      }

      if (_firstShadowReplaced && _secondShadowReplaced &&
          _thirdShadowReplaced && _fourthShadowReplaced && _fifthShadowReplaced) {
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 2), () {
          widget.onNextStage?.call();
        });
      }
    }
  }

  // معالجة Actor الثالث (index 7) - يذهب إلى Shadow الثالث
  void _handleThirdActorDragEnd(DraggableDetails details, double actorSize) {
    if (_thirdShadowReplaced) return;

    if (_isActorOverShadow(details, actorSize, _thirdShadowKey)) {
      setState(() {
        _thirdShadowReplaced = true;
      });

      // تشغيل صوت الإجابة الصحيحة
      if (!_thirdSoundPlayed) {
        _thirdSoundPlayed = true;
        TrueAnswerSound.play();
      }

      if (_firstShadowReplaced && _secondShadowReplaced &&
          _thirdShadowReplaced && _fourthShadowReplaced && _fifthShadowReplaced) {
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 2), () {
          widget.onNextStage?.call();
        });
      }
    }
  }

  // معالجة Actor الرابع (index 0) - يذهب إلى Shadow الرابع
  void _handleFourthActorDragEnd(DraggableDetails details, double actorSize) {
    if (_fourthShadowReplaced) return;

    if (_isActorOverShadow(details, actorSize, _fourthShadowKey)) {
      setState(() {
        _fourthShadowReplaced = true;
      });

      // تشغيل صوت الإجابة الصحيحة
      if (!_fourthSoundPlayed) {
        _fourthSoundPlayed = true;
        TrueAnswerSound.play();
      }

      if (_firstShadowReplaced && _secondShadowReplaced &&
          _thirdShadowReplaced && _fourthShadowReplaced && _fifthShadowReplaced) {
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 2), () {
          widget.onNextStage?.call();
        });
      }
    }
  }

  // معالجة Actor الخامس (index 4) - يذهب إلى Shadow الخامس
  Future<void> _handleFifthActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) async {
    if (_fifthShadowReplaced) return;

    if (_isActorOverShadow(details, actorSize, _fifthShadowKey)) {
      setState(() {
        _fifthShadowReplaced = true;
      });

      // تشغيل صوت الإجابة الصحيحة
      if (!_fifthSoundPlayed) {
        _fifthSoundPlayed = true;
        TrueAnswerSound.play();
      }

      if (_firstShadowReplaced &&
          _secondShadowReplaced &&
          _thirdShadowReplaced &&
          _fourthShadowReplaced &&
          _fifthShadowReplaced) {

        await _logProgress();

        WellDoneOverlay.show(context);

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
      }
    }
  }

  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity!.phaseId}");
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final elements = _activity!.elements!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Actors
    final firstActor = elements[5];   // Actor الأول (index 3 - رابع صورة)
    final secondActor = elements[6];  // Actor الثاني (index 2 - تالت صورة)
    final thirdActor = elements[3];   // Actor الثالث (index 7 - تامن صورة)
    final fourthActor = elements[4];  // Actor الرابع (index 0 - اول صورة)
    final fifthActor = elements[2];   // Actor الخامس (index 4 - خامس صورة)

    final double shadowSize = screenWidth * 0.25;
    final double actorSize = screenWidth * 0.15;

    // مواقع Shadows المختلفة
    final Offset firstShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.32);
    final Offset secondShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.2);
    final Offset thirdShadowPosition = Offset(screenWidth * 0.24, screenHeight * 0.44);
    final Offset fourthShadowPosition = Offset(screenWidth * 0.6, screenHeight * 0.32);
    final Offset fifthShadowPosition = Offset(screenWidth * 0.08, screenHeight * 0.32);

    return Scaffold(
      body: Stack(
        children: [
          // Shadow الأول - Container فارغ
          Positioned(
            left: firstShadowPosition.dx,
            top: firstShadowPosition.dy,
            child: Container(
              key: _firstShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _firstShadowReplaced
                  ? Image.network(firstActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black, width: 2),
                  // borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Shadow الثاني - Container فارغ
          Positioned(
            left: secondShadowPosition.dx,
            top: secondShadowPosition.dy,
            child: Container(
              key: _secondShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _secondShadowReplaced
                  ? Image.network(secondActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black, width: 2),
                  // borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Shadow الثالث - Container فارغ
          Positioned(
            left: thirdShadowPosition.dx,
            top: thirdShadowPosition.dy,
            child: Container(
              key: _thirdShadowKey,
              width: shadowSize * 2,
              height: shadowSize,
              child: _thirdShadowReplaced
                  ? Image.network(thirdActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black, width: 2),
                  // borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Shadow الرابع - Container فارغ
          Positioned(
            left: fourthShadowPosition.dx,
            top: fourthShadowPosition.dy,
            child: Container(
              key: _fourthShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _fourthShadowReplaced
                  ? Image.network(fourthActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black, width: 2),
                  // borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Shadow الخامس - Container فارغ
          Positioned(
            left: fifthShadowPosition.dx,
            top: fifthShadowPosition.dy,
            child: Container(
              key: _fifthShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _fifthShadowReplaced
                  ? Image.network(fifthActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black, width: 2),
                  // borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // جميع الأكتيورز يظهرون في الأسفل وجميعهم Draggable
          // Actor الأول
          if (!_firstShadowReplaced)
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.65,
              child: Draggable<String>(
                data: firstActor.id!,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    firstActor.imageUrl ?? '',
                    width: actorSize,
                    height: actorSize,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  firstActor.imageUrl ?? '',
                  width: actorSize,
                  height: actorSize,
                ),
                onDragEnd: (details) {
                  _handleFirstActorDragEnd(details, actorSize);
                },
              ),
            ),

          // Actor الثاني
          if (!_secondShadowReplaced)
            Positioned(
              left: screenWidth * 0.07 + actorSize + 10,
              top: screenHeight * 0.65,
              child: Draggable<String>(
                data: secondActor.id!,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    secondActor.imageUrl ?? '',
                    width: actorSize,
                    height: actorSize,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  secondActor.imageUrl ?? '',
                  width: actorSize,
                  height: actorSize,
                ),
                onDragEnd: (details) {
                  _handleSecondActorDragEnd(details, actorSize);
                },
              ),
            ),

          // Actor الثالث
          if (!_thirdShadowReplaced)
            Positioned(
              left: screenWidth * 0.07 + (actorSize + 10) * 2,
              top: screenHeight * 0.65,
              child: Draggable<String>(
                data: thirdActor.id!,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    thirdActor.imageUrl ?? '',
                    width: actorSize,
                    height: actorSize,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  thirdActor.imageUrl ?? '',
                  width: actorSize,
                  height: actorSize,
                ),
                onDragEnd: (details) {
                  _handleThirdActorDragEnd(details, actorSize);
                },
              ),
            ),

          // Actor الرابع
          if (!_fourthShadowReplaced)
            Positioned(
              left: screenWidth * 0.07 + (actorSize + 10) * 3,
              top: screenHeight * 0.65,
              child: Draggable<String>(
                data: fourthActor.id!,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    fourthActor.imageUrl ?? '',
                    width: actorSize,
                    height: actorSize,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  fourthActor.imageUrl ?? '',
                  width: actorSize,
                  height: actorSize,
                ),
                onDragEnd: (details) {
                  _handleFourthActorDragEnd(details, actorSize);
                },
              ),
            ),

          // Actor الخامس
          if (!_fifthShadowReplaced)
            Positioned(
              left: screenWidth * 0.07 + (actorSize + 10) * 4,
              top: screenHeight * 0.65,
              child: Draggable<String>(
                data: fifthActor.id!,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    fifthActor.imageUrl ?? '',
                    width: actorSize,
                    height: actorSize,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  fifthActor.imageUrl ?? '',
                  width: actorSize,
                  height: actorSize,
                ),
                onDragEnd: (details) async {
                  await _handleFifthActorDragEnd(details, actorSize);
                },
              ),
            ),
        ],
      ),
    );
  }
}