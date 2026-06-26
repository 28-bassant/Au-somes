import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class RoomArrangementLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RoomArrangementLevel1Stage1({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<RoomArrangementLevel1Stage1> createState() =>
      RoomArrangementLevel1Stage1State();
}

class RoomArrangementLevel1Stage1State
    extends State<RoomArrangementLevel1Stage1> {

  late AudioPlayer _player;
  late ActivityResponse _activity;

  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;

  late Future<ActivityResponse> _activityFuture;
  Map<int, bool> placed = {};

  // لتتبع عدد الإجابات الصحيحة لمنع تشغيل الصوت أكثر من مرة لنفس العنصر
  Map<int, bool> _soundPlayed = {};
  bool _usedHint = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _activityFuture = _loadActivity();
  }

  Future<ActivityResponse> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.room_arrangement_activityId,
      1,
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

  void repeatSound() => playSound();
  Future<void> _logProgress() async {
    try {
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
    return FutureBuilder<ActivityResponse>(
      future: _activityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !_imagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        final anchor = _activity.elements!
            .firstWhere((e) => e.role == 'Anchor');

        final actors = _activity.elements!
            .where((e) => e.role == 'Actor')
            .toList();

        for (int i = 0; i < actors.length; i++) {
          placed.putIfAbsent(i, () => false);
          _soundPlayed.putIfAbsent(i, () => false);
        }

        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {

              // ================= أحجام مختلفة لكل Actor =================
              final List<double> actorSizes = [
                constraints.maxWidth * 0.12, // Actor 0 قبل السحب
                constraints.maxWidth * 0.14, // Actor 1 قبل السحب
              ];

              final List<double> placedActorSizes = [
                constraints.maxWidth * 0.20, // Actor 0 بعد السحب
                constraints.maxWidth * 0.22, // Actor 1 بعد السحب
              ];

              // ================= أماكن Drop Zones =================
              List<Offset> dropPositions = [
                Offset(constraints.maxWidth * 0.32, constraints.maxHeight * 0.44),
                Offset(constraints.maxWidth * 0.7, constraints.maxHeight * 0.49),
              ];

              return Stack(
                children: [

                  // ================= Anchor =================
                  Center(

                    child: Image.network(
                      anchor.imageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // ================= Drop Zones =================
                  for (int i = 0; i < actors.length; i++)
                    Positioned(
                      left: dropPositions[i].dx,
                      top: dropPositions[i].dy,
                      child: DragTarget<int>(
                        onWillAccept: (data) {
                          return data == i && placed[i] == false;
                        },
                        onAccept: (data) async {
                          setState(() {
                            placed[i] = true;
                          });

                          if (!_soundPlayed[i]!) {
                            _soundPlayed[i] = true;
                            TrueAnswerSound.play();
                          }

                          if (placed.values.every((e) => e)) {

                            await _logProgress();

                            WellDoneOverlay.show(context);

                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                widget.onNextStage?.call();
                              }
                            });
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: placedActorSizes[i],
                            height: placedActorSizes[i],
                            decoration: BoxDecoration(
                              // border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: placed[i] == true
                                ? Image.network(
                              actors[i].imageUrl ?? '',
                              width: placedActorSizes[i],
                              height: placedActorSizes[i],
                              fit: BoxFit.contain,
                            )
                                : Container(), // 👈 آمن بدل null
                          );
                        },
                      ),
                    ),

                  // ================= Draggables =================
                  for (int i = 0; i < actors.length; i++)
                    if (placed[i] != true)
                      Positioned(
                        bottom: constraints.maxHeight * 0.38 + (i * constraints.maxHeight * 0.08),
                        left: constraints.maxWidth * 0.08 + (i * constraints.maxWidth * 0.15),
                        child: Draggable<int>(
                          data: i,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Image.network(
                              actors[i].imageUrl ?? '',
                              width: actorSizes[i],
                              fit: BoxFit.contain,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.network(
                              actors[i].imageUrl ?? '',
                              width: actorSizes[i],
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: Image.network(
                            actors[i].imageUrl ?? '',
                            width: actorSizes[i],
                            fit: BoxFit.contain,
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
