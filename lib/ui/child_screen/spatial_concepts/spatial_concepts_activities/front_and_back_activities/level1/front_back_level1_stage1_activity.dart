import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  FrontBackLevel1Stage1ActivityState createState() =>
      FrontBackLevel1Stage1ActivityState();
}

class FrontBackLevel1Stage1ActivityState extends State<FrontBackLevel1Stage1Activity> {
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
      ApiConstants.front_back_activityId,
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
        Image.network(anchorElement.imageUrl ?? ''),
        Positioned(
          left: 100,
          top: 300,
          child: GestureDetector(
            onTapDown: (details) {
              final tap = details.localPosition;
              final containerWidth = 250.0;
              final containerHeight = 250.0;

              // نحدد المنطقة الصح: النص لتحت مثلاً آخر ثلث من الارتفاع
              final correctAreaTop = containerHeight * 2 / 3;
              final correctAreaBottom = containerHeight;

              if (tap.dy >= correctAreaTop && tap.dy <= correctAreaBottom) {
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  widget.onNextStage?.call();
                });
              } else {
                DialogUtils.showMsg(context: context, msg: 'Try Again');
              }
            },
            child: Image.network(
              firstElement.imageUrl ?? '',
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
