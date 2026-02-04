import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel2Stage2Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  InsideLevel2Stage2ActivityState createState() =>
      InsideLevel2Stage2ActivityState();
}

class InsideLevel2Stage2ActivityState
    extends State<InsideLevel2Stage2Activity> {

  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.inside_outside_activityId,
      2,
      2,
    );

    activity = response;

    actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
    shadow = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    setState(() {
      isLoading = false;
    });

    playSound();
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        /// ===== Anchor (خلفية ثابتة) =====
        Positioned(
          left: 5,
          top: 120,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: 350,
          ),
        ),

        /// ===== Shadow (مكان الإسقاط) =====
        Positioned(
          left: 100,
          top: 320,
          child: DragTarget<String>(
            onWillAccept: (data) => data == shadow.id,
            onAccept: (data) {
              setState(() {
                isPlacedCorrectly = true;
              });
              WellDoneOverlay.show(context);
              Future.delayed(const Duration(seconds: 3), () {
                widget.onNextStage?.call();
              });
            },
            builder: (context, candidateData, rejectedData) {
              return isPlacedCorrectly
                  ?  Transform.rotate(
                angle: .3,
                    child: Image.network(
                      actor.imageUrl ?? '',
                       width: 150,
                    ),
                  )
                  : Transform.rotate(
                angle: .3,
                child: Image.network(
                  shadow.imageUrl ?? '',
                  width: 140,
                ),
              );
            },
          ),
        ),

        /// ===== Actor (اللي بيتسحب فعليًا) =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 20,
            bottom: 70,
            child: Draggable<String>(
              data: actor.targetedZoneId,
              /// 👈 ده اللي الطفل شايفه وهو بيسحب
              feedback: Material(
                color: Colors.transparent,
                child: Transform.rotate(
                  angle: .3,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: 160,
                  ),
                ),
              ),

              /// 👈 نخفي الأصل
              childWhenDragging: const SizedBox(),

              /// 👈 الشكل قبل السحب
              child: Transform.rotate(
                angle: .3,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 160,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
