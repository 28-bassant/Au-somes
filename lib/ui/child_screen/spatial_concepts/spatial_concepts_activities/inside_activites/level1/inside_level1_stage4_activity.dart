
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel1Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel1Stage4Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  InsideLevel1Stage4ActivityState createState() =>
      InsideLevel1Stage4ActivityState();
}

class InsideLevel1Stage4ActivityState extends State<InsideLevel1Stage4Activity> {
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
      ApiConstants.inside_outside_activityId,
      1,
      4,
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

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        /// الأنكور ( Try Again)
        Positioned(
          right:0,
          top: 190,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(
              child: Image.network(
                anchorElement.imageUrl ?? '',
                fit: BoxFit.contain,
                width:300,height: 300,
              ),
            ),
          ),
        ),
        Positioned(
          left: 5,
          top: 200,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(
              color: Colors.transparent,
              child: Image.network(
                lastElement.imageUrl ?? '',
                fit: BoxFit.contain,
                width: 180,height: 170,
              ),
            ),
          ),
        ),

        /// الأكتور (الصح)
        Positioned(
          right:110,
          top:316,
          child: GestureDetector(
            onTap: () {
              WellDoneOverlay.show(context);
              Future.delayed(const Duration(seconds: 3), () {
                widget.onNextStage?.call();
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Transform.rotate(
                angle: .3,
                child: Image.network(
                  firstElement.imageUrl ?? '',
                  width: 95,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}