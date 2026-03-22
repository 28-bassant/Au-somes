import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class TowerBuildingLevel1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const TowerBuildingLevel1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<TowerBuildingLevel1Stage2> createState() =>
      TowerBuildingLevel1Stage2State();
}

class TowerBuildingLevel1Stage2State extends State<TowerBuildingLevel1Stage2> {
  late AudioPlayer _player;
  ActivityResponse? _activity;

  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  bool _firstShadowReplaced = false;  // أول Shadow - يتم استبداله بـ Actor الأول
  bool _secondShadowReplaced = false; // ثاني Shadow - يتم استبداله بـ Actor الثاني

  // لتتبع الأصوات التي تم تشغيلها
  bool _firstSoundPlayed = false;
  bool _secondSoundPlayed = false;

  // GlobalKeys لتحديد مواقع العناصر
  final GlobalKey _firstShadowKey = GlobalKey();
  final GlobalKey _secondShadowKey = GlobalKey();

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
        1,
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

  void _handleFirstActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) {
    if (_firstShadowReplaced) return; // لو اتم استبداله خلاص

    // نحسب مركز الأكتور المسحوب
    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    // نحصل على موقع Shadow الأول
    final shadowBox = _firstShadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowBox != null) {
      final shadowPosition = shadowBox.localToGlobal(Offset.zero);
      final shadowRect = Rect.fromLTWH(
        shadowPosition.dx,
        shadowPosition.dy,
        shadowBox.size.width,
        shadowBox.size.height,
      );

      // نتحقق إذا كان الأكتور وقع داخل Shadow الأول
      if (shadowRect.contains(actorCenter)) {
        setState(() {
          _firstShadowReplaced = true;
        });

        // تشغيل صوت الإجابة الصحيحة
        if (!_firstSoundPlayed) {
          _firstSoundPlayed = true;
          TrueAnswerSound.play();
        }

        // نتحقق إذا كان كل الشادوز اتم استبدالهم
        if (_firstShadowReplaced && _secondShadowReplaced) {
          WellDoneOverlay.show(context);
          Future.delayed(const Duration(seconds: 2), () {
            widget.onNextStage?.call();
          });
        }
      }
    }
  }

  void _handleSecondActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) {
    if (_secondShadowReplaced) return; // لو اتم استبداله خلاص

    // نحسب مركز الأكتور المسحوب
    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    // نحصل على موقع Shadow الثاني
    final shadowBox = _secondShadowKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowBox != null) {
      final shadowPosition = shadowBox.localToGlobal(Offset.zero);
      final shadowRect = Rect.fromLTWH(
        shadowPosition.dx,
        shadowPosition.dy,
        shadowBox.size.width,
        shadowBox.size.height,
      );

      // نتحقق إذا كان الأكتور وقع داخل Shadow الثاني
      if (shadowRect.contains(actorCenter)) {
        setState(() {
          _secondShadowReplaced = true;
        });

        // تشغيل صوت الإجابة الصحيحة
        if (!_secondSoundPlayed) {
          _secondSoundPlayed = true;
          TrueAnswerSound.play();
        }

        // نتحقق إذا كان كل الشادوز اتم استبدالهم
        if (_firstShadowReplaced && _secondShadowReplaced) {
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

    // Shadows (ثابتة)
    final firstShadow = elements[0];  // أول Shadow (أول صورة)
    final secondShadow = elements[2]; // ثاني Shadow (تالت صورة)

    // Actors
    final firstActor = elements[1]; // أول Actor (تاني صورة)
    final secondActor = elements[3]; // ثاني Actor (رابع صورة)

    final double shadowSize = screenWidth * 0.25;
    final double actorSize = screenWidth * 0.25;

    // مواقع Shadows
    final Offset firstShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.2);
    final Offset secondShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.32);

    return Scaffold(
      body: Stack(
        children: [
          // Shadow الأول - يتغير إلى Actor الأول لما يتم وضعه
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
                height: 100,
                decoration: BoxDecoration(
                  // border: Border.all(
                  //     color: Colors.black
                  // )
                ),
              ),
            ),
          ),

          // Shadow الثاني - يتغير إلى Actor الثاني لما يتم وضعه
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
                height: 100,
                decoration: BoxDecoration(
                  // border: Border.all(
                  //     color: Colors.black
                  // )
                ),
              ),
            ),
          ),

          // Actor الأول (تاني صورة) - قابل للسحب دائماً
          if (!_firstShadowReplaced)
            Positioned(
              left: 90,
              top: screenHeight * 0.6,
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

          // Actor الثاني (رابع صورة) - قابل للسحب دائماً
          if (!_secondShadowReplaced)
            Positioned(
              left: 50 + actorSize + 60,
              top: screenHeight * 0.6,
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
        ],
      ),
    );
  }
}