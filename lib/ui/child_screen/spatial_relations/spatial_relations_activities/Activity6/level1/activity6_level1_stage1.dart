import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity6Level1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity6Level1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => Activity6Level1Stage1State();
}

class Activity6Level1Stage1State extends State<Activity6Level1Stage1> {
  late AudioPlayer _player;
  late ActivityResponse _activity;
  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;
  bool isPlacedCorrectly = false;

  final String localTargetId = "zone1";
  bool _usedHint = false;
  bool _progressSent = false;
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.sr_between_activityId,
      2, // Stage 1
      1,
    );

    // Preload images
    final urls = _activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in urls) {
      await precacheImage(NetworkImage(url!), context);
    }
    _imagesLoaded = true;

    // ✅ تشغيل الصوت بعد تحميل الصور
    if (!_hasPlayedSound) {
      await playSound();
      _hasPlayedSound = true;
    }

    return _activity;
  }

  Future playSound() async {
    if (_activity.audioUrl == null || _activity.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity.audioUrl!));
  }

  void repeatSound() => playSound();

  Future<void> _logProgress() async {
    if (_progressSent) return;

    try {
      _progressSent = true;

      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity.phaseId}");
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
    return FutureBuilder(
      future: _loadActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !_imagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        final actor = _activity.elements!.firstWhere((e) => e.role == 'Actor');
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final targetWidth = screenWidth * 0.39;
        final targetHeight = screenHeight * 0.8; // ارتفاع كبير، يغطي معظم منتصف الشاشة

        return Stack(
          children: [
            Positioned(
              left: screenWidth / 2 - targetWidth / 2, // وسط الشاشة عرضيًا
              top: screenHeight * 0.1, // من فوق قليل
              width: targetWidth,
              height: targetHeight,
              child: DragTarget<String>(
                onWillAccept: (data) => data == localTargetId,
                onAccept: (data) async {
                  setState(() => isPlacedCorrectly = true);

                  await _logProgress();

                  WellDoneOverlay.show(context);

                  Future.delayed(const Duration(seconds: 3), () {
                    widget.onNextStage?.call();
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Center(
                    child: isPlacedCorrectly
                        ? Image.network(
                      actor.imageUrl ?? '',
                      width: targetWidth * 0.7, // حجم المكعب
                    )
                        : const SizedBox(),
                  );
                },
              ),
            ),

            // Draggable المكعب
            if (!isPlacedCorrectly)
              Positioned(
                right: 0,
                bottom: 50,
                child: Draggable<String>(
                  data: localTargetId,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.network(actor.imageUrl ?? '',
                        width: targetWidth * 0.7),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.network(actor.imageUrl ?? '',
                        width: targetWidth * 0.7),
                  ),
                  child: Image.network(actor.imageUrl ?? '',
                      width: targetWidth * 0.7),
                ),
              ),
          ],
        );
      },
    );
  }
}