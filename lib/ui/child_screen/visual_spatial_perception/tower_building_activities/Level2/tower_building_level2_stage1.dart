import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class TowerBuildingLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const TowerBuildingLevel2Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<TowerBuildingLevel2Stage1> createState() =>
      TowerBuildingLevel2Stage1State();
}

class TowerBuildingLevel2Stage1State extends State<TowerBuildingLevel2Stage1> {
  late AudioPlayer _player;
  late AudioPlayer _deceptionPlayer;
  ActivityResponse? _activity;

  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  // حالة استبدال كل Shadow
  bool _firstShadowReplaced = false;   // Shadow الأول (index 1)
  bool _secondShadowReplaced = false;  // Shadow الثاني (index 0)
  bool _thirdShadowReplaced = false;   // Shadow الثالث (index 4)

  // التحكم في تفعيل كل Actor (كلهم موجودين ولكن غير قابلين للسحب)
  bool _firstActorDraggable = true;    // Actor الأول قابل للسحب من البداية
  bool _secondActorDraggable = false;  // Actor الثاني غير قابل للسحب في البداية
  bool _thirdActorDraggable = false;   // Actor الثالث غير قابل للسحب في البداية

  // GlobalKeys لتحديد مواقع العناصر
  final GlobalKey _firstShadowKey = GlobalKey();   // Shadow الأول (index 1)
  final GlobalKey _secondShadowKey = GlobalKey();  // Shadow الثاني (index 0)
  final GlobalKey _thirdShadowKey = GlobalKey();   // Shadow الثالث (index 4)
  bool _usedHint = false;
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _deceptionPlayer = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.tower_building_activityId,
        2,
        1,
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

  Future<void> _playDeceptionSound(int index) async {
    if (_activity?.deceptionInstructions != null &&
        _activity!.deceptionInstructions!.length > index) {
      final url = _activity!.deceptionInstructions![index];
      if (url.isNotEmpty) {
        await _deceptionPlayer.stop();
        await _deceptionPlayer.play(UrlSource(url));
      }
    }
  }

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
    if (!_firstActorDraggable) return;

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

        // تشغيل أول صوت Deception (index 0)
        _playDeceptionSound(0);

        // تفعيل Actor الثاني بعد 0.5 ثانية (جعله قابل للسحب)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _secondActorDraggable = true;
            });
          }
        });
      }
    }
  }

  // دالة لمعالجة سحب Actor الثاني (index 2) إلى Shadow الثاني (index 0)
  void _handleSecondActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) {
    if (_secondShadowReplaced) return;
    if (!_secondActorDraggable) return;

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

        // تشغيل ثاني صوت Deception (index 1)
        _playDeceptionSound(1);

        // تفعيل Actor الثالث بعد 0.5 ثانية (جعله قابل للسحب)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _thirdActorDraggable = true;
            });
          }
        });
      }
    }
  }

  // دالة لمعالجة سحب Actor الثالث (index 5) إلى Shadow الثالث (index 4)
  Future<void> _handleThirdActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) async {
    if (_thirdShadowReplaced) return;
    if (!_thirdActorDraggable) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final shadowBox =
    _thirdShadowKey.currentContext?.findRenderObject() as RenderBox?;

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

        // التحقق من اكتمال جميع Shadows
        if (_firstShadowReplaced &&
            _secondShadowReplaced &&
            _thirdShadowReplaced) {

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
    _deceptionPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final elements = _activity!.elements!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Shadows (حسب العلاقات المطلوبة)
    final firstShadow = elements[1];   // Shadow الأول (index 1 - تاني صورة)
    final secondShadow = elements[0];  // Shadow الثاني (index 0 - اول صورة)
    final thirdShadow = elements[4];   // Shadow الثالث (index 4 - خامس صورة)

    // Actors
    final firstActor = elements[3];   // Actor الأول (index 3 - رابع صورة)
    final secondActor = elements[2];  // Actor الثاني (index 2 - تالت صورة)
    final thirdActor = elements[5];   // Actor الثالث (index 5 - سادس صورة)

    final double shadowSize = screenWidth * 0.25;
    final double actorSize = screenWidth * 0.25;

    // مواقع Shadows
    final Offset firstShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.32);
    final Offset secondShadowPosition = Offset(screenWidth * 0.34, screenHeight * 0.2);
    final Offset thirdShadowPosition = Offset(screenWidth * 0.24, screenHeight * 0.44);

    return Scaffold(
      body: Stack(
        children: [
          // Shadow الأول (index 1)
          Positioned(
            left: firstShadowPosition.dx,
            top: firstShadowPosition.dy,
            child: Container(
              key: _firstShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _firstShadowReplaced
                  ? Image.network(firstActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(firstShadow.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // Shadow الثاني (index 0)
          Positioned(
            left: secondShadowPosition.dx,
            top: secondShadowPosition.dy,
            child: Container(
              key: _secondShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _secondShadowReplaced
                  ? Image.network(secondActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(secondShadow.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // Shadow الثالث (index 4)
          Positioned(
            left: thirdShadowPosition.dx,
            top: thirdShadowPosition.dy,
            child: Container(
              key: _thirdShadowKey,
              width: shadowSize * 2,
              height: shadowSize * 0.8,
              child: _thirdShadowReplaced
                  ? Image.network(thirdActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(thirdShadow.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // Actor الأول - يظهر وممكن سحبه من البداية
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

          // Actor الثاني - يظهر لكن غير قابل للسحب في البداية
          if (!_secondShadowReplaced)
            Positioned(
              left: screenWidth * 0.1 + actorSize + 20,
              top: screenHeight * 0.65,
              child: _secondActorDraggable
                  ? Draggable<String>(
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
              )
                  : Image.network(
                secondActor.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
              ),
            ),

          // Actor الثالث - يظهر لكن غير قابل للسحب في البداية
          if (!_thirdShadowReplaced)
            Positioned(
              left: screenWidth * 0.1 + (actorSize + 20) * 2,
              top: screenHeight * 0.65,
              child: _thirdActorDraggable
                  ? Draggable<String>(
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
                onDragEnd: (details) async {
                  await _handleThirdActorDragEnd(details, actorSize);
                },
              )
                  : Image.network(
                thirdActor.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
              ),
            ),
        ],
      ),
    );
  }
}
