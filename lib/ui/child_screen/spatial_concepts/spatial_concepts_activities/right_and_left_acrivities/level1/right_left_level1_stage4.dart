import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel1Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel1Stage4({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel1Stage4State createState() => RightLeftLevel1Stage4State();
}

class RightLeftLevel1Stage4State extends State<RightLeftLevel1Stage4> {
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

    final firstElement = activity!.elements![1]; // الصورة الصحيحة
    final anchorElement = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Anchor في الخلف
        Positioned(
          left: 80,
          top: 80,
          child: Image.network(
            anchorElement.imageUrl ?? '',
            width: 400,
          ),
        ),

        // الصور فوق الـ Anchor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // الصورة الغلط
            GestureDetector(
              onTapDown: (details) {
                DialogUtils.showMsg(context: context, msg: 'Try Again');
              },
              child: Image.network(
                firstElement.imageUrl ?? '',
                width: 180,
              ),
            ),

            // الصورة الصحيحة
            GestureDetector(
              onTapDown: (details) {
                final tapX = details.localPosition.dx;
                final imageWidth = 180.0;
                // صح لو الضغط في منتصف الصورة تقريباً
                if (tapX > imageWidth * 0.25 && tapX < imageWidth * 0.75) {
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
                width: 180,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
