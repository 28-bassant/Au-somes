
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel1Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage4Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage4ActivityState createState() =>
      BetweenLevel1Stage4ActivityState();
}

class BetweenLevel1Stage4ActivityState extends State<BetweenLevel1Stage4Activity> {
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
      ApiConstants.between_activityId,
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
    final actorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Actor');

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        /// الأنكور (لو اتداس عليه = Try Again)
        Positioned(
          left:20 ,
          top: 300,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(

              child: Image.asset(AppAssets.table,
                fit: BoxFit.contain,
                width: 140,


              ),
            ),
          ),
        ),

        Positioned(
          left:250 ,
          top: 300,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(

              child: Image.asset(AppAssets.table,
                fit: BoxFit.contain,
                width: 140,


              ),
            ),
          ),
        ),




        /// الأنكور (لو اتداس عليه = Try Again)
        Positioned(
         left:20 ,
          top: 500,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(

              child: Image.asset(AppAssets.table,
                fit: BoxFit.contain,
                width: 130,
              ),
            ),
          ),
        ),
        /// الأنكور (لو اتداس عليه = Try Again)
        Positioned(
          left:153 ,
          top: 500,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(
              child: Image.asset(AppAssets.table,
                fit: BoxFit.contain,
                width: 130,
              ),
            ),
          ),
        ),


        /// الأكتور (الإجابة الصح)
        Positioned(
          top: 190,
          child: GestureDetector(
            onTap: () {
              WellDoneOverlay.show(context);
              Future.delayed(const Duration(seconds: 3), () {
                widget.onNextStage?.call();
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: 270,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),


        /// الأكتور (الإجابة الصح)
        Positioned(
          top: 400,
          left: 200,
          child:  GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(
              color: Colors.transparent,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: 270,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}