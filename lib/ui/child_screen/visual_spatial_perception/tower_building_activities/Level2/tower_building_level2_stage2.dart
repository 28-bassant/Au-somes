import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class TowerBuildingLevel2Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const TowerBuildingLevel2Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<TowerBuildingLevel2Stage2> createState() =>
      TowerBuildingLevel2Stage2State();
}

class TowerBuildingLevel2Stage2State extends State<TowerBuildingLevel2Stage2> {
  late AudioPlayer _player;
  ActivityResponse? _activity;

  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  // حالة استبدال كل Shadow
  bool _firstShadowReplaced = false;   // Shadow الأول (index 1)
  bool _secondShadowReplaced = false;  // Shadow الثاني (index 0)
  bool _thirdShadowReplaced = false;   // Shadow الثالث (index 4)

  // لتتبع الأصوات التي تم تشغيلها
  bool _firstSoundPlayed = false;
  bool _secondSoundPlayed = false;
  bool _thirdSoundPlayed = false;

  // GlobalKeys لتحديد مواقع العناصر
  final GlobalKey _firstShadowKey = GlobalKey();   // Shadow الأول (index 1)
  final GlobalKey _secondShadowKey = GlobalKey();  // Shadow الثاني (index 0)
  final GlobalKey _thirdShadowKey = GlobalKey();   // Shadow الثالث (index 4)

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
        2,
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

  // دالة لمعالجة سحب Actor الأول (index 3) إلى Shadow الأول (index 1)
  void _handleFirstActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) {
    if (_firstShadowReplaced) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final shadowBox = _firstShadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowBox != null) {
      final shadowPosition = shadowBox.localToGlobal(Offset.zero);
      final shadowRect = Rect.fromLTWH(
        shadowPosition.dx,
        shadowPosition.dy,
        shadowBox.size.width,
        shadowBox.size.height,
      );

      if (shadowRect.contains(actorCenter)) {
        setState(() {
          _firstShadowReplaced = true;
        });

        // تشغيل صوت الإجابة الصحيحة
        if (!_firstSoundPlayed) {
          _firstSoundPlayed = true;
          TrueAnswerSound.play();
        }

        // التحقق من اكتمال جميع Shadows
        if (_firstShadowReplaced && _secondShadowReplaced && _thirdShadowReplaced) {
          WellDoneOverlay.show(context);
          Future.delayed(const Duration(seconds: 2), () {
            widget.onNextStage?.call();
          });
        }
      }
    }
  }

  // دالة لمعالجة سحب Actor الثاني (index 2) إلى Shadow الثاني (index 0)
  void _handleSecondActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) {
    if (_secondShadowReplaced) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final shadowBox = _secondShadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowBox != null) {
      final shadowPosition = shadowBox.localToGlobal(Offset.zero);
      final shadowRect = Rect.fromLTWH(
        shadowPosition.dx,
        shadowPosition.dy,
        shadowBox.size.width,
        shadowBox.size.height,
      );

      if (shadowRect.contains(actorCenter)) {
        setState(() {
          _secondShadowReplaced = true;
        });

        // تشغيل صوت الإجابة الصحيحة
        if (!_secondSoundPlayed) {
          _secondSoundPlayed = true;
          TrueAnswerSound.play();
        }

        // التحقق من اكتمال جميع Shadows
        if (_firstShadowReplaced && _secondShadowReplaced && _thirdShadowReplaced) {
          WellDoneOverlay.show(context);
          Future.delayed(const Duration(seconds: 2), () {
            widget.onNextStage?.call();
          });
        }
      }
    }
  }

  // دالة لمعالجة سحب Actor الثالث (index 5) إلى Shadow الثالث (index 4)
  void _handleThirdActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) {
    if (_thirdShadowReplaced) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final shadowBox = _thirdShadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowBox != null) {
      final shadowPosition = shadowBox.localToGlobal(Offset.zero);
      final shadowRect = Rect.fromLTWH(
        shadowPosition.dx,
        shadowPosition.dy,
        shadowBox.size.width,
        shadowBox.size.height,
      );

      if (shadowRect.contains(actorCenter)) {
        setState(() {
          _thirdShadowReplaced = true;
        });

        // تشغيل صوت الإجابة الصحيحة
        if (!_thirdSoundPlayed) {
          _thirdSoundPlayed = true;
          TrueAnswerSound.play();
        }

        // التحقق من اكتمال جميع Shadows
        if (_firstShadowReplaced && _secondShadowReplaced && _thirdShadowReplaced) {
          WellDoneOverlay.show(context);
          Future.delayed(const Duration(seconds: 2), () {
            widget.onNextStage?.call();
          });
        }
      }
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
    final secondActor = elements[2];  // Actor الثاني (index 2 - تالت صورة)
    final thirdActor = elements[4];   // Actor الثالث (index 5 - سادس صورة)

    final double shadowSize = screenWidth * 0.25;
    final double actorSize = screenWidth * 0.25;

    // مواقع Shadows (Containers الفارغة)
    final Offset firstShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.32);
    final Offset secondShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.2);
    final Offset thirdShadowPosition = Offset(screenWidth * 0.24, screenHeight * 0.44);

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
              height: shadowSize * 0.8,
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

          // Actor الأول - موجود وجاهز للسحب
          if (!_firstShadowReplaced)
            Positioned(
              left: screenWidth * 0.1,
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

          // Actor الثاني - موجود وجاهز للسحب
          if (!_secondShadowReplaced)
            Positioned(
              left: screenWidth * 0.1 + actorSize + 20,
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

          // Actor الثالث - موجود وجاهز للسحب
          if (!_thirdShadowReplaced)
            Positioned(
              left: screenWidth * 0.1 + (actorSize + 20) * 2,
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
        ],
      ),
    );
  }
}