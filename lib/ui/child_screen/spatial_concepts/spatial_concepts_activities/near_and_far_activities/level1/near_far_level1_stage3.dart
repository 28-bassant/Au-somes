

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel1Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel1Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  NearFarLevel1Stage3State createState() =>
      NearFarLevel1Stage3State();
}

class NearFarLevel1Stage3State extends State<NearFarLevel1Stage3> {
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
      ApiConstants.near_far_activityId,
      1,
      3,
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

    final firstElement = activity!.elements!.first;
    final lastElement = activity!.elements!.last;
    final anchorElement = activity!.elements!.firstWhere((e) =>
    e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ الصورة الصح (الأولى)
            GestureDetector(
                onTap: () {
                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () {
                    widget.onNextStage?.call();
                  });
                },
                child: Image.network(
                  lastElement.imageUrl ?? '',
                  width: 200,
                ),
              ),
            SizedBox(height: 30,),


            // ❌ الصورة الغلط (التانية)
           GestureDetector(
                onTap: () {
                  DialogUtils.showMsg(
                    context: context,
                    msg: 'Try Again',
                  );
                },
                child: Image.network(
                  firstElement.imageUrl ?? '',
                  width: 300,
                ),
              ),

          ],
        )
      ],
    );
  }
}