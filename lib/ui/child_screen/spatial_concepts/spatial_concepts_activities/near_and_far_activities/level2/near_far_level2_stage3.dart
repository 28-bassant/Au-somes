import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../utils/app_assets.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel2Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel2Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<NearFarLevel2Stage3> createState() => NearFarLevel2Stage3State();
}

class NearFarLevel2Stage3State extends State<NearFarLevel2Stage3> {
  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement correctShadow;
  late ActivityElement wrongShadow;
  late ActivityElement anchor;

  final GlobalKey _correctShadowKey = GlobalKey();
  final GlobalKey _wrongShadowKey = GlobalKey();

  static const double actorSize = 200;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    activity = await ApiManager.getActivity(
      ApiConstants.near_far_activityId,
      2,
      3,
    );

    actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');

    final shadows =
    activity!.elements!.where((e) => e.role == 'Shadow').toList();

    // ⚠️ افترضي إن أول شادو صح والتاني غلط (أضمن من first/lastWhere)
    correctShadow = shadows.first;
    wrongShadow = shadows.last;

    anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    setState(() => isLoading = false);
    playSound();
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }
  void repeatSound() => playSound();

  void showWrongDialog() {
    DialogUtils.showMsg(context: context, msg: 'Try Again');
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 200,
          left: 0,
          right: 0,
          child: Center(
            child: Image.network(
              anchor.imageUrl ?? '',
              width: 250,
            ),
          ),
        ),

        /// ===== Shadow الغلط =====
        Positioned(
          right: 50,
          top: 150,
          child: Container(

            key: _wrongShadowKey,
            width: 50,
            height: 50,
            child: Image.asset(
              AppAssets.ball_image ,
              width: 80,
            )
          ),
        ),

        /// ===== Shadow الصح =====
        Positioned(
          left: 240,
          top: 360,
          child: Container(
            key: _correctShadowKey,

            child: DragTarget<String>(
              onWillAccept: (data) => data == actor.id,
              onAccept: (_) {
                setState(() => isPlacedCorrectly = true);
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  widget.onNextStage?.call();
                });
              },
              builder: (context, _, __) {
                return isPlacedCorrectly
                    ? Image.network(
                  actor.imageUrl ?? '',

                  fit: BoxFit.contain,
                )
                    :Image.asset(
                  AppAssets.ball_image ,
                  width: 80,
                );
              },
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 40,
            bottom: 0,
            child: Draggable<String>(
              data: actor.id,
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: actorSize,
                ),
              ),
              childWhenDragging: const SizedBox(),
              child: Image.network(
                actor.imageUrl ?? '',
                width: actorSize,
              ),
              onDragEnd: (details) {
                final actorCenter = Offset(
                  details.offset.dx + actorSize / 2,
                  details.offset.dy + actorSize / 2,
                );

                /// check wrong shadow
                final wrongBox = _wrongShadowKey.currentContext!
                    .findRenderObject() as RenderBox;
                final wrongPos = wrongBox.localToGlobal(Offset.zero);
                final wrongRect =
                wrongPos & wrongBox.size;

                if (wrongRect.contains(actorCenter)) {
                  showWrongDialog();
                }
              },
            ),
          ),
      ],
    );
  }
}
