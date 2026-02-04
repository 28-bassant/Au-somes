import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel2Stage1({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  NearFarLevel2Stage1State createState() =>
      NearFarLevel2Stage1State();
}

class NearFarLevel2Stage1State
    extends State<NearFarLevel2Stage1> {

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
      ApiConstants.near_far_activityId,
      2,
      1,
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
        Center(
          child: Image.network(
            anchor.imageUrl ?? '',
            width: 300,
          ),
        ),

        /// ===== Shadow (مكان الإسقاط) =====
        Positioned(
          left: 230,
          top: 380,
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
                  ? Image.network(
                                  actor.imageUrl ?? '' ,
                                  width: 100,
                                )
                  : Image.asset(
                                  AppAssets.ball_image ,
                                  width: 80,
                                );
            },
          ),
        ),

        /// ===== Actor (اللي بيتسحب فعليًا) =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 10,
            bottom: -15,
            child: Draggable<String>(
              data: actor.targetedZoneId,

              /// 👈 ده اللي الطفل شايفه وهو بيسحب
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 220,
                ),
              ),

              /// 👈 نخفي الأصل
              childWhenDragging: const SizedBox(),

              /// 👈 الشكل قبل السحب
              child: Image.network(
                actor.imageUrl ?? '',
                width: 220,
              ),
            ),
          ),
      ],
    );
  }
}
