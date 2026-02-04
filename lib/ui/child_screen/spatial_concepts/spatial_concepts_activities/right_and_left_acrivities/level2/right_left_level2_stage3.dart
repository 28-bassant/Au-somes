import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel2Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel2Stage3({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<RightLeftLevel2Stage3> createState() =>
      RightLeftLevel2Stage3State();
}

class RightLeftLevel2Stage3State
    extends State<RightLeftLevel2Stage3> {
  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow1; // الصح
  late ActivityElement shadow2; // الغلط
  late ActivityElement anchor;

  final GlobalKey _shadow2Key = GlobalKey();
  final GlobalKey _shadow1Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    activity = await ApiManager.getActivity(
      ApiConstants.right_left_activityId,
      2,
      3,
    );

    actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
    shadow1 = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    shadow2 = activity!.elements!.lastWhere((e) => e.role == 'Shadow');
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
    DialogUtils.showMsg(
      context: context,
      msg: 'Try Again',
    );
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
        /// ===== Shadow الغلط =====
        Positioned(
          right: 190,
          top: 300,
          child: Container(
            key: _shadow2Key,
            width: 250,
            height: 250,

            child: Image.network(
              shadow2.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// ===== الخلفية =====
        Positioned(
          left: 100,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: 300,
          ),
        ),

        /// ===== Shadow الصح =====
        Positioned(
          left: 210,
          top: 300,
          child: Container(
            key: _shadow1Key,
            width: 250,
            height: 250,

            child: DragTarget<String>(
              onWillAccept: (data) => data == actor.id,
              onAccept: (_) {
                setState(() {
                  isPlacedCorrectly = true;
                });

                WellDoneOverlay.show(context);

                Future.delayed(const Duration(seconds: 3), () {
                  widget.onNextStage?.call();
                });
              },
              builder: (context, _, __) {
                return isPlacedCorrectly
                    ? Image.network(actor.imageUrl ?? '',
                    width: 300, height: 300, fit: BoxFit.cover)
                    : Image.network(shadow1.imageUrl ?? '',
                    width: 300, height: 300, fit: BoxFit.cover);
              },
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 40,
            bottom: -15,
            child: Draggable<String>(
              data: actor.id,
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 200,
                ),
              ),
              childWhenDragging: const SizedBox(),
              child: Image.network(
                actor.imageUrl ?? '',
                width: 200,
              ),
              onDragEnd: (details) {
                final RenderBox actorBox =
                context.findRenderObject() as RenderBox; // Stack context
                final actorPos = details.offset; // Offset من الشاشة

                // مركز الـ actor
                final actorCenter = Offset(
                  actorPos.dx + 220 / 2,
                  actorPos.dy + 220 / 2,
                );

                // Shadow الصح
                final shadow1Box =
                _shadow1Key.currentContext!.findRenderObject() as RenderBox;
                final shadow1Pos = shadow1Box.localToGlobal(Offset.zero);
                final shadow1Size = shadow1Box.size;
                final shadow1Rect =
                Rect.fromLTWH(shadow1Pos.dx, shadow1Pos.dy, shadow1Size.width, shadow1Size.height);

                // لو المركز جوه Shadow الصح
                if (shadow1Rect.contains(actorCenter)) {
                  setState(() {
                    isPlacedCorrectly = true;
                  });
                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () {
                    widget.onNextStage?.call();
                  });
                  return; // ما نعملش check للغلط
                }

                // Shadow الغلط
                final shadow2Box =
                _shadow2Key.currentContext!.findRenderObject() as RenderBox;
                final shadow2Pos = shadow2Box.localToGlobal(Offset.zero);
                final shadow2Size = shadow2Box.size;

                final wrongPointSize = 50.0;
                final wrongCenter = Offset(
                  shadow2Pos.dx + shadow2Size.width / 2 - wrongPointSize / 2,
                  shadow2Pos.dy + shadow2Size.height / 2 - wrongPointSize / 2,
                );
                final wrongRect = Rect.fromLTWH(
                  wrongCenter.dx,
                  wrongCenter.dy,
                  wrongPointSize,
                  wrongPointSize,
                );

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
