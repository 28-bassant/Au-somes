
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  InsideLevel1Stage2ActivityState createState() =>
      InsideLevel1Stage2ActivityState();
}

class InsideLevel1Stage2ActivityState extends State<InsideLevel1Stage2Activity> {
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final actorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Actor');

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        /// الأنكور (لو اتداس عليه = Try Again)
        Positioned(
          left: 25,
          right: 25,
          top: 120,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(
              child: Image.network(
                anchorElement.imageUrl ?? '',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        /// الأكتور (الإجابة الصح)
        Positioned(
          left: 125,
          top: 280,
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
                  actorElement.imageUrl ?? '',
                  width: width*.32,
                  height: height*.2,
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