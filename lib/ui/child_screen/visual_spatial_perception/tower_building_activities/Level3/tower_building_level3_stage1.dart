import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class TowerBuildingLevel3Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const TowerBuildingLevel3Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<TowerBuildingLevel3Stage1> createState() =>
      TowerBuildingLevel3Stage1State();
}

class TowerBuildingLevel3Stage1State extends State<TowerBuildingLevel3Stage1> {
  late AudioPlayer _player;
  late AudioPlayer _deceptionPlayer;
  ActivityResponse? _activity;

  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  // حالة استبدال كل Shadow
  bool _firstShadowReplaced = false;   // Shadow الأول للـ Actor الأول (index 1)
  bool _secondShadowReplaced = false;  // Shadow الثاني (index 5)
  bool _thirdShadowReplaced = false;   // Shadow الثالث (index 6)
  bool _fourthShadowReplaced = false;  // Shadow الرابع للـ Actor الرابع (index 1 - نفس الصورة)
  bool _fifthShadowReplaced = false;   // Shadow الخامس للـ Actor الخامس (index 1 - نفس الصورة)

  // حالة اختفاء كل Actor من الأسفل
  bool _actor1Removed = false;   // Actor الأول اختفى
  bool _actor2Removed = false;   // Actor الثاني اختفى
  bool _actor3Removed = false;   // Actor الثالث اختفى
  bool _actor4Removed = false;   // Actor الرابع اختفى
  bool _actor5Removed = false;   // Actor الخامس اختفى

  // التحكم في تفعيل كل Actor (قابلية السحب)
  bool _actor1Draggable = true;   // Actor الأول قابل للسحب من البداية
  bool _actor2Draggable = false;  // Actor الثاني غير قابل للسحب في البداية
  bool _actor3Draggable = false;  // Actor الثالث غير قابل للسحب في البداية
  bool _actor4Draggable = false;  // Actor الرابع غير قابل للسحب في البداية
  bool _actor5Draggable = false;  // Actor الخامس غير قابل للسحب في البداية

  // GlobalKeys لتحديد مواقع العناصر
  final GlobalKey _firstShadowKey = GlobalKey();   // Shadow الأول (لـ Actor الأول)
  final GlobalKey _secondShadowKey = GlobalKey();  // Shadow الثاني (index 5)
  final GlobalKey _thirdShadowKey = GlobalKey();   // Shadow الثالث (index 6)
  final GlobalKey _fourthShadowKey = GlobalKey();  // Shadow الرابع (لـ Actor الرابع)
  final GlobalKey _fifthShadowKey = GlobalKey();   // Shadow الخامس (لـ Actor الخامس)
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
        3,
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

  // دالة لمعالجة سحب Actor إلى Shadow معين
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
    if (!_actor1Draggable || _firstShadowReplaced || _actor1Removed) return;

    if (_isActorOverShadow(details, actorSize, _firstShadowKey)) {
      setState(() {
        _firstShadowReplaced = true;
        _actor1Removed = true; // إخفاء Actor من الأسفل
      });

      _playDeceptionSound(0);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _actor2Draggable = true;
          });
        }
      });
    }
  }

  // معالجة Actor الثاني (index 2) - يذهب إلى Shadow الثاني (index 5)
  void _handleSecondActorDragEnd(DraggableDetails details, double actorSize) {
    if (!_actor2Draggable || _secondShadowReplaced || _actor2Removed) return;

    if (_isActorOverShadow(details, actorSize, _secondShadowKey)) {
      setState(() {
        _secondShadowReplaced = true;
        _actor2Removed = true; // إخفاء Actor من الأسفل
      });

      _playDeceptionSound(1);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _actor3Draggable = true;
          });
        }
      });
    }
  }

  // معالجة Actor الثالث (index 7) - يذهب إلى Shadow الثالث (index 6)
  void _handleThirdActorDragEnd(DraggableDetails details, double actorSize) {
    if (!_actor3Draggable || _thirdShadowReplaced || _actor3Removed) return;

    if (_isActorOverShadow(details, actorSize, _thirdShadowKey)) {
      setState(() {
        _thirdShadowReplaced = true;
        _actor3Removed = true; // إخفاء Actor من الأسفل
      });

      _playDeceptionSound(2);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _actor4Draggable = true;
          });
        }
      });
    }
  }

  // معالجة Actor الرابع (index 0) - يذهب إلى Shadow الرابع
  void _handleFourthActorDragEnd(DraggableDetails details, double actorSize) {
    if (!_actor4Draggable || _fourthShadowReplaced || _actor4Removed) return;

    if (_isActorOverShadow(details, actorSize, _fourthShadowKey)) {
      setState(() {
        _fourthShadowReplaced = true;
        _actor4Removed = true; // إخفاء Actor من الأسفل
      });

      _playDeceptionSound(3);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _actor5Draggable = true;
          });
        }
      });
    }
  }

  // معالجة Actor الخامس (index 4) - يذهب إلى Shadow الخامس
  Future<void> _handleFifthActorDragEnd(
      DraggableDetails details,
      double actorSize,
      ) async {
    if (!_actor5Draggable || _fifthShadowReplaced || _actor5Removed) return;

    if (_isActorOverShadow(details, actorSize, _fifthShadowKey)) {
      setState(() {
        _fifthShadowReplaced = true;
        _actor5Removed = true;
      });

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

    // Shadows
    final firstShadowImage = elements[1];   // Shadow (index 1 - تاني صورة) - يستخدم لثلاثة Shadows
    final secondShadow = elements[5];       // Shadow الثاني (index 5 - سادس صورة)
    final thirdShadow = elements[6];        // Shadow الثالث (index 6 - سابع صورة)

    // Actors
    final firstActor = elements[3];   // Actor الأول (index 3 - رابع صورة)
    final secondActor = elements[2];  // Actor الثاني (index 2 - تالت صورة)
    final thirdActor = elements[7];   // Actor الثالث (index 7 - تامن صورة)
    final fourthActor = elements[0];  // Actor الرابع (index 0 - اول صورة)
    final fifthActor = elements[4];   // Actor الخامس (index 4 - خامس صورة)

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
          // Shadow الأول (لـ Actor الأول)
          Positioned(
            left: firstShadowPosition.dx,
            top: firstShadowPosition.dy,
            child: Container(
              key: _firstShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _firstShadowReplaced
                  ? Image.network(firstActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(firstShadowImage.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // Shadow الثاني (index 5 - لـ Actor الثاني)
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

          // Shadow الثالث (index 6 - لـ Actor الثالث)
          Positioned(
            left: thirdShadowPosition.dx,
            top: thirdShadowPosition.dy,
            child: Container(
              key: _thirdShadowKey,
              width: shadowSize * 2,
              height: shadowSize,
              child: _thirdShadowReplaced
                  ? Image.network(thirdActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(thirdShadow.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // Shadow الرابع (لـ Actor الرابع - نفس صورة Shadow الأول)
          Positioned(
            left: fourthShadowPosition.dx,
            top: fourthShadowPosition.dy,
            child: Container(
              key: _fourthShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _fourthShadowReplaced
                  ? Image.network(fourthActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(firstShadowImage.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // Shadow الخامس (لـ Actor الخامس - نفس صورة Shadow الأول)
          Positioned(
            left: fifthShadowPosition.dx,
            top: fifthShadowPosition.dy,
            child: Container(
              key: _fifthShadowKey,
              width: shadowSize,
              height: shadowSize,
              child: _fifthShadowReplaced
                  ? Image.network(fifthActor.imageUrl ?? '', fit: BoxFit.fill)
                  : Image.network(firstShadowImage.imageUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          // جميع الأكتيورز يظهرون معاً في الأسفل، ولكن يختفون عندما يتم وضعهم
          // Actor الأول
          if (!_actor1Removed)
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.65,
              child: _actor1Draggable
                  ? Draggable<String>(
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
              )
                  : Image.network(
                firstActor.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
              ),
            ),

          // Actor الثاني
          if (!_actor2Removed)
            Positioned(
              left: screenWidth * 0.07 + actorSize + 10,
              top: screenHeight * 0.65,
              child: _actor2Draggable
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

          // Actor الثالث
          if (!_actor3Removed)
            Positioned(
              left: screenWidth * 0.07 + (actorSize + 10) * 2,
              top: screenHeight * 0.65,
              child: _actor3Draggable
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
                onDragEnd: (details) {
                  _handleThirdActorDragEnd(details, actorSize);
                },
              )
                  : Image.network(
                thirdActor.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
              ),
            ),

          // Actor الرابع
          if (!_actor4Removed)
            Positioned(
              left: screenWidth * 0.07 + (actorSize + 10) * 3,
              top: screenHeight * 0.65,
              child: _actor4Draggable
                  ? Draggable<String>(
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
              )
                  : Image.network(
                fourthActor.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
              ),
            ),

          // Actor الخامس
          if (!_actor5Removed)
            Positioned(
              left: screenWidth * 0.07 + (actorSize + 10) * 4,
              top: screenHeight * 0.65,
              child: _actor5Draggable
                  ? Draggable<String>(
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
              )
                  : Image.network(
                fifthActor.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
              ),
            ),
        ],
      ),
    );
  }
}
