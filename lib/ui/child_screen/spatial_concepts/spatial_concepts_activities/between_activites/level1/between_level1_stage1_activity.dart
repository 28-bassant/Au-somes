
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage1ActivityState createState() =>
      BetweenLevel1Stage1ActivityState();
}

class BetweenLevel1Stage1ActivityState extends State<BetweenLevel1Stage1Activity> {
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
      1,
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
    final anchorElement = activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    return Stack(
      alignment: Alignment.center,
      children: [
        /// الأنكور (لو اتداس عليه = Try Again)
        Positioned(
          left: 0,
          right: 0,
          top: 70,

            child: Container(
              child: Image.network(
                anchorElement.imageUrl ?? '',
                fit: BoxFit.contain,

              ),
            ),
          ),


        /// الأكتور (الإجابة الصح)
        Positioned(
          left: 144,
          top: 320,
          child: GestureDetector(
            onTap: () {
              WellDoneOverlay.show(context);
              Future.delayed(const Duration(seconds: 3), () {
                widget.onNextStage?.call();
              });
            },
            child: Container(
              child: Image.network(
                firstElement.imageUrl ?? '',
                width: 115,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}