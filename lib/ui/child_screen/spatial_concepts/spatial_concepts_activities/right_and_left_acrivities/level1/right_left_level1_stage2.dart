

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel1Stage2State createState() =>
      RightLeftLevel1Stage2State();
}

class RightLeftLevel1Stage2State extends State<RightLeftLevel1Stage2> {
  ActivityResponse? activity;
  bool isLoading = true;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.right_left_activityId,
      1,
      2,
    );

    setState(() {
      activity = response;
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final lastElement = activity!.elements!.last;
    final anchorElement = activity!.elements!.firstWhere((e) =>
    e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        InkWell(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Positioned(
                right: 50,
                top: 250,
                child: Image.network(anchorElement.imageUrl ?? ''))),
        Positioned(
          left: 200,
          top: 350,
          child: GestureDetector(
            onTap: () {
              WellDoneOverlay.show(context);
              //todo: Move to next stage via callback
              Future.delayed(const Duration(seconds: 3), () {
                widget.onNextStage?.call();
              });
            },
            child: Image.network(
              lastElement.imageUrl ?? '',
              width: 200,
            ),
          ),
        ),

      ],
    );
  }
}