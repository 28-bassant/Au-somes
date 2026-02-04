import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel1Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel1Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel1Stage3State createState() => RightLeftLevel1Stage3State();
}

class RightLeftLevel1Stage3State extends State<RightLeftLevel1Stage3> {
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

    final rightElement = activity!.elements![0]; // الصورة الصحيحة
    final leftElement = activity!.elements![1];  // الصورة الغلط
    final anchorElement = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Anchor في الخلف
        Image.network(
          anchorElement.imageUrl ?? '',
          width: 250,
        ),

        // الصور فوق الـ Anchor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الصورة الغلط
            GestureDetector(
              onTapDown: (details) {
                DialogUtils.showMsg(context: context, msg: 'Try Again');
              },
              child: Image.network(
                leftElement.imageUrl ?? '',
                width: 180,
              ),
            ),

            // الصورة الصحيحة
            GestureDetector(
              onTapDown: (details) {
                final tapX = details.localPosition.dx;
                final imageWidth = 150.0; // نفس width الصورة
                // لو ضغط الطفل على الجزء الأيمن من الصورة (مثلاً آخر نصف)
                if (tapX > imageWidth / 2) {
                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () {
                    widget.onNextStage?.call();
                  });
                } else {
                  DialogUtils.showMsg(context: context, msg: 'Try Again');
                }
              },
              child: Image.network(
                rightElement.imageUrl ?? '',
                width: 180,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
