import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
class Activity6Level1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity6Level1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<Activity6Level1Stage2> createState() => Activity6Level1Stage2State();
}

class Activity6Level1Stage2State extends State<Activity6Level1Stage2> {
  late AudioPlayer _player;
  late ActivityResponse _activity;

  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;
  bool isPlacedCorrectly = false;
  bool _usedHint = false;
  bool _progressSent = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.sr_right_left_activityId,
      2,
      1,
    );

    final urls = _activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in urls) {
      await precacheImage(NetworkImage(url!), context);
    }

    _imagesLoaded = true;
    return _activity;
  }

  Future<void> playSound() async {
    if (_activity.audioUrl == null || _activity.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity.audioUrl!));
  }

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
  void repeatSound() => playSound();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivityResponse>(
      future: _loadActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !_imagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        final actor = _activity.elements!.firstWhere((e) => e.role == 'Actor');
        final shadow = _activity.elements!.firstWhere((e) => e.role == 'Shadow');

        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // حجم المكعب الأصفر = 25% من عرض الشاشة
              final shadowSize = screenWidth * 0.29;

              // حجم المكعب القابل للسحب = 60% من المكعب الأصفر
              final actorSize = shadowSize * 0.7;

              final centerX = screenWidth / 2;
              final centerY = screenHeight / 2;

              return Stack(
                children: [
                  /// منطقة الإسقاط شمال المكعب وبنفس ارتفاعه
                  Positioned(
                    left: 0,
                    top: centerY - shadowSize / 2+screenHeight*.05,
                    width: centerX - shadowSize / 2,
                    height: shadowSize,
                    child: DragTarget<String>(
                      onWillAccept: (data) => data == actor.targetedZoneId,
                      onAccept: (data) async {
                        setState(() => isPlacedCorrectly = true);

                        await _logProgress();

                        WellDoneOverlay.show(context);

                        Future.delayed(const Duration(seconds: 3), () {
                          widget.onNextStage?.call();
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return isPlacedCorrectly
                            ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Image.network(
                              actor.imageUrl ?? '',
                              width: actorSize,
                            ),
                          ),
                        )
                            : const SizedBox();
                      },
                    ),
                  ),

                  /// المكعب الأصفر في منتصف الشاشة
                  Positioned(
                    left: centerX - shadowSize / 2,
                    top: centerY - shadowSize / 2+screenHeight*.05,
                    child: Image.network(
                      shadow.imageUrl ?? '',
                      width: shadowSize,
                      height: shadowSize,
                      fit: BoxFit.contain,
                    ),
                  ),

                  /// المكعب القابل للسحب
                  if (!isPlacedCorrectly)
                    Positioned(
                      right: 40,
                      bottom: 50,
                      child: Draggable<String>(
                        data: actor.targetedZoneId,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: actorSize,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: actorSize,
                          ),
                        ),
                        child: Image.network(
                          actor.imageUrl ?? '',
                          width: actorSize,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}