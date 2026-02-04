
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel1Stage1State createState() =>
      RightLeftLevel1Stage1State();
}

class RightLeftLevel1Stage1State extends State<RightLeftLevel1Stage1> {
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
          left: 0,
          top: 100,
          child: GestureDetector(
            onTapDown: (details) {
              final tapX = details.localPosition.dx;
              final imageWidth = 450.0; // نفس width الصورة

              // المنطقة الصح هي النصف الأيمن للصورة
              if (tapX >= imageWidth / 2) {
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  widget.onNextStage?.call();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Try Again')),
                );
              }
            },
            child: Image.network(
              firstElement.imageUrl ?? '',
              width: 450,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}