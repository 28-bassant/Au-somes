import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel2Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel2Stage1Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  InsideLevel2Stage1ActivityState createState() =>
      InsideLevel2Stage1ActivityState();
}

class InsideLevel2Stage1ActivityState
    extends State<InsideLevel2Stage1Activity> {

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
        Positioned(
          right:5,
          top: 130,
            child: Image.network(
              anchor.imageUrl ?? '',
              width: 280,
            ),
          ),

        /// ===== Shadow (مكان الإسقاط) =====
        Positioned(
          right:131,
          top: 230,
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
                  ? Transform.translate(
                offset: const Offset(0, -5),
                    child: Image.network(
                                    actor.imageUrl ?? '',
                                    width: 50,
                                  ),
                  )
                  : Image.network(
                shadow.imageUrl ?? '',
                width: 50,
              );
            },
          ),
        ),

        /// ===== Actor (اللي بيتسحب فعليًا) =====
        if (!isPlacedCorrectly)
          Positioned(
            left: 20,
            top: 220,
            child: Draggable<String>(
              data: actor.targetedZoneId,

              /// 👈 ده اللي الطفل شايفه وهو بيسحب
              feedback: Material(
                color: Colors.transparent,
                child: Image.asset(
                  AppAssets.shirtOutside,
                  width: 100,
                ),
              ),

              /// 👈 نخفي الأصل
              childWhenDragging: const SizedBox(),

              /// 👈 الشكل قبل السحب
              child: Image.asset(
                AppAssets.shirtOutside,
                width: 100,
              ),
            ),
          ),
      ],
    );
  }
}