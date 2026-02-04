import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel1Stage3Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const FrontBackLevel1Stage3Activity({Key? key,this.onNextStage}) : super(key: key);

  @override
  FrontBackLevel1Stage3ActivityState createState() =>
      FrontBackLevel1Stage3ActivityState();
}

class FrontBackLevel1Stage3ActivityState extends State<FrontBackLevel1Stage3Activity> {
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
    final anchorElement = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 100,
          bottom: 320,
          child: GestureDetector(
            onTap: () {
               //todo: try again
              TryAgainSound.play();
            },
            child: Image.network(
              firstElement.imageUrl ?? '',
              width: 350,
            ),
          ),
        ),
        IgnorePointer(
            child: Image.network(anchorElement.imageUrl ?? '')),
        Positioned(
          left: 100,
          top: 280,
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
              width: 250,
            ),
          ),
        ),
      ],
    );
  }
}
