import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class RoomArrangementLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RoomArrangementLevel2Stage1({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<RoomArrangementLevel2Stage1> createState() =>
      RoomArrangementLevel2Stage1State();
}

class RoomArrangementLevel2Stage1State
    extends State<RoomArrangementLevel2Stage1> {

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

        final anchor = _activity.elements!.firstWhere((e) => e.role == 'Anchor');

        final actors = _activity.elements!.where((e) => e.role == 'Actor').toList();

        // تهيئة حالة الـ placed و _soundPlayed
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
                constraints.maxWidth * 0.12,
                constraints.maxWidth * 0.065,
                constraints.maxWidth * 0.1,
                constraints.maxWidth * 0.12,
                constraints.maxWidth * 0.14,
                constraints.maxWidth * 0.10,
                constraints.maxWidth * 0.14,
              ];

              final List<double> placedActorWidths = [
                constraints.maxWidth * 0.13,
                constraints.maxWidth * 0.11,
                constraints.maxWidth * 0.12,
                constraints.maxWidth * 0.25,
                constraints.maxWidth * 0.15,
                constraints.maxWidth * 0.12,
                constraints.maxWidth * 0.1,
              ];

              final List<double> placedActorHeights = [
                constraints.maxWidth * 0.14,
                constraints.maxWidth * 0.09,
                constraints.maxWidth * 0.15,
                constraints.maxWidth * 0.16,
                constraints.maxWidth * 0.15,
                constraints.maxWidth * 0.13,
                constraints.maxWidth * 0.12,
              ];

              // ================= Drop Zones =================
              // ممكن بعدين تستخدم targetedZoneId لتحديد مكان كل Actor بالضبط
              final List<Offset> dropPositions = [
                Offset(constraints.maxWidth * 0.05, constraints.maxHeight * 0.46),
                Offset(constraints.maxWidth * 0.52, constraints.maxHeight * 0.47),
                Offset(constraints.maxWidth * 0.86, constraints.maxHeight * 0.47),
                Offset(constraints.maxWidth * 0.68, constraints.maxHeight * 0.52),
                Offset(constraints.maxWidth * 0.35, constraints.maxHeight * 0.46),
                Offset(constraints.maxWidth * 0.06, constraints.maxHeight * 0.39),
                Offset(constraints.maxWidth * 0.73, constraints.maxHeight * 0.46),
              ];

              // ================= Initial positions لكل Actor قبل السحب =================
              final List<Offset> initialPositions = [
                Offset(35, constraints.maxHeight * 0.58), // Actor 0
                Offset(75, constraints.maxHeight * 0.45), // Actor 1
                Offset(100, constraints.maxHeight * 0.5), // Actor 2
                Offset(87, constraints.maxHeight * 0.52), // Actor 3
                Offset(320, constraints.maxHeight * 0.58), // Actor 4
                Offset(300, constraints.maxHeight * 0.48), // Actor 5
                Offset(200, constraints.maxHeight * 0.58), // Actor 6
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
                            width: placedActorWidths[i],
                            height: placedActorHeights[i],
                            decoration: BoxDecoration(
                              // border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: placed[i] == true
                                ? Image.network(
                              actors[i].imageUrl ?? '',
                              width: placedActorWidths[i],
                              height: placedActorHeights[i],
                              fit: BoxFit.contain,
                            )
                                : Container(),
                          );
                        },
                      ),
                    ),

                  // ================= Draggables =================
                  for (int i = 0; i < actors.length; i++)
                    if (placed[i] != true)
                      Positioned(
                        left: initialPositions[i].dx,
                        top: initialPositions[i].dy,
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