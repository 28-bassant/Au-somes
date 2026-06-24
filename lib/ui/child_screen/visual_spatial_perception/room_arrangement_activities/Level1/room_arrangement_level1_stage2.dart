import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class RoomArrangementLevel1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RoomArrangementLevel1Stage2({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<RoomArrangementLevel1Stage2> createState() =>
      RoomArrangementLevel1Stage2State();
}

class RoomArrangementLevel1Stage2State
    extends State<RoomArrangementLevel1Stage2> {

  late AudioPlayer _player;
  late ActivityResponse _activity;

  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;

  late Future<ActivityResponse> _activityFuture;
  Map<int, bool> placed = {};
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
      2,
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

              // ================= Sizes =================
              final List<double> actorSizes = List.generate(
                actors.length,
                    (i) => constraints.maxWidth * 0.13,
              );

              final List<double> placedActorSizes = List.generate(
                actors.length,
                    (i) => constraints.maxWidth * 0.12,
              );

              final List<double> placedActorHeight = List.generate(
                actors.length,
                    (i) => constraints.maxWidth * 0.15,
              );

              // ================= Drop Zones =================
              final List<Offset> dropPositions = [
                Offset(constraints.maxWidth * 0.06, constraints.maxHeight * 0.46),
                Offset(constraints.maxWidth * 0.75, constraints.maxHeight * 0.46),
                Offset(constraints.maxWidth * 0.88, constraints.maxHeight * 0.47),
                Offset(constraints.maxWidth * 0.06, constraints.maxHeight * 0.39),
              ];

              // ================= التحكم في مكان كل Actor =================
              final List<double> actorLeft = [
                constraints.maxWidth * 0.26, // Actor 0
                constraints.maxWidth * 0.25, // Actor 1
                constraints.maxWidth * 0.55, // Actor 2
                constraints.maxWidth * 0.8,  // Actor 3
              ];

              final List<double> actorBottom = [
                constraints.maxHeight * 0.47, // Actor 0
                constraints.maxHeight * 0.38, // Actor 1
                constraints.maxHeight * 0.38, // Actor 2
                constraints.maxHeight * 0.47, // Actor 3
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
                          return data == i && placed[i] != true;
                        },
                        onAccept: (data) async {
                          setState(() {
                            placed[i] = true;
                          });

                          if (!_soundPlayed[i]!) {
                            _soundPlayed[i] = true;
                            TrueAnswerSound.play();
                          }

                          if (placed.values.every((e) => e == true)) {

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
                            height: placedActorHeight[i],
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Colors.black
                            //   )
                            // ),
                            child: placed[i] == true
                                ? Image.network(
                              actors[i].imageUrl ?? '',
                              fit: BoxFit.contain,
                            )
                                : const SizedBox(),
                          );
                        },
                      ),
                    ),

                  // ================= Draggables =================
                  for (int i = 0; i < actors.length; i++)
                    if (placed[i] != true)
                      Positioned(
                        left: actorLeft[i],
                        bottom: actorBottom[i],
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