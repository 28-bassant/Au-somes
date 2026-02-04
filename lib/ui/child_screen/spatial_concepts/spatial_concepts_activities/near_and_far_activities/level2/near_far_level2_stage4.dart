import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class NearFarLevel2Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const NearFarLevel2Stage4({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<NearFarLevel2Stage4> createState() => NearFarLevel2Stage4State();
}

class NearFarLevel2Stage4State extends State<NearFarLevel2Stage4> {
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
      4,
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
          right: 10,
          top: 80,
          child: Container(
            key: _wrongShadowKey,
            width: 80,
            height: 80,
            child: Image.network(
              wrongShadow.imageUrl ?? '',
              fit: BoxFit.contain,
            ),
          ),
        ),

        /// ===== Shadow الصح =====
        Positioned(
          left: 240,
          top: 320,
          child: Container(
            key: _correctShadowKey,
            width: 100,
            height: 120,

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
                  width: 200,
                  height: 120,
                  fit: BoxFit.contain,
                )
                    : Image.network(
                  correctShadow.imageUrl ?? '',
                  width: 200,
                  height: 120,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 40,
            bottom: 10,
            child: Draggable<String>(
              data: actor.id,
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 100,
                ),
              ),
              childWhenDragging: const SizedBox(),
              child: Image.network(
                actor.imageUrl ?? '',
                width: 100,
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
