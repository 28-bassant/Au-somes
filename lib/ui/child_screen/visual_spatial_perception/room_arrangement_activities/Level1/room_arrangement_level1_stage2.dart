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
                constraints.maxWidth * 0.13,
                constraints.maxWidth * 0.13,
                constraints.maxWidth * 0.15,
              ];

              final List<double> placedActorSizes = [
                constraints.maxWidth * 0.13,
                constraints.maxWidth * 0.12,
                constraints.maxWidth * 0.12,
                constraints.maxWidth * 0.13,
              ];
              final List<double> placedActorHeight = [
                constraints.maxWidth * 0.14,
                constraints.maxWidth * 0.15,
                constraints.maxWidth * 0.15,
                constraints.maxWidth * 0.14,
              ];

              // ================= Drop Zones =================
              final List<Offset> dropPositions = [
                Offset(constraints.maxWidth * 0.02, constraints.maxHeight * 0.44),
                Offset(constraints.maxWidth * 0.75, constraints.maxHeight * 0.45),
                Offset(constraints.maxWidth * 0.88, constraints.maxHeight * 0.45),
                Offset(constraints.maxWidth * 0.02, constraints.maxHeight * 0.366),
              ];

              return Stack(
                children: [

                  // ================= Anchor =================
                  Positioned(
                    top: 230,
                    left: 0,
                    right: 0,
                    bottom: 250,
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
                        onAccept: (data) {
                          setState(() {
                            placed[i] = true;
                          });

                          // تشغيل صوت الإجابة الصحيحة إذا لم يتم تشغيله من قبل
                          if (!_soundPlayed[i]!) {
                            _soundPlayed[i] = true;
                            TrueAnswerSound.play();
                          }

                          // لو كل العناصر اتوضعت صح
                          if (placed.values.every((e) => e == true)) {
                            WellDoneOverlay.show(context);
                            Future.delayed(const Duration(seconds: 2), () {
                              widget.onNextStage?.call();
                            });
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: placedActorSizes[i],
                            height: placedActorHeight[i],
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
                                : Container(),
                          );
                        },
                      ),
                    ),

                  // ================= Draggables =================
                  for (int i = 0; i < actors.length; i++)
                    if (placed[i] != true)
                      Positioned(
                        bottom: 260,
                        left: 40.0 + (i * 90),
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