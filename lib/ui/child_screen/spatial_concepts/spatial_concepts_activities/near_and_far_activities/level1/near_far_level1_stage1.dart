

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  NearFarLevel1Stage1State createState() =>
      NearFarLevel1Stage1State();
}

class NearFarLevel1Stage1State extends State<NearFarLevel1Stage1> {
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
      children: [
        Positioned(
          right: 90,
          top: 340,
          child: InkWell(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Image.network(anchorElement.imageUrl ?? '',
              width: 80,
              ),
          ),
        ),
        Positioned(
          top: 200,
          left: 40,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              final localPos = details.localPosition;

              const imageWidth = 250.0;
              const imageHeight = 250.0; // عدليها لو مختلفة

              // ===== منطقة الصح: شريط في النص بالطول كله =====
              final correctArea = Rect.fromLTWH(
                imageWidth * 0.3, // بداية الصح أفقيًا
                0,                // من فوق (الطول كله)
                imageWidth * 0.4, // عرض منطقة الصح
                imageHeight,      // الطول كله
              );

              if (correctArea.contains(localPos)) {
                // ✅ صح
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  widget.onNextStage?.call();
                });
              } else {
                // ❌ غلط
                DialogUtils.showMsg(
                  context: context,
                  msg: 'Try Again',
                );
              }
            },
            child: Image.network(
              firstElement.imageUrl ?? '',
              width: 250,
            ),
          ),
        ),



      ],
    );
  }
}