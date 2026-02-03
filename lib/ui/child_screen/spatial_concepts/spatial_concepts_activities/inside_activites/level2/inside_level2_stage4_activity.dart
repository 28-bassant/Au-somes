import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel2Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel2Stage4Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<InsideLevel2Stage4Activity> createState() =>
      InsideLevel2Stage4ActivityState();
}

class InsideLevel2Stage4ActivityState
    extends State<InsideLevel2Stage4Activity> {
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
      ApiConstants.inside_outside_activityId,
      2,
      4,
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
      children: [
        /// ===== Shadow الغلط =====
        Positioned(
          left: 10,
          top: 380,
          child: DragTarget<String>(
            onWillAccept: (data) => data == actor.id,
            onAccept: (_) {
              showWrongDialog();
            },
            builder: (context, _, __) {
              return Transform.rotate(
                angle: .3,
                child: Image.network(
                  shadow2.imageUrl ?? '',
                  width: 140,

                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),

        /// ===== الخلفية =====
        Positioned(
          right:5,
          top: 80,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: 280,
          ),
        ),

        /// ===== Shadow الصح =====
        Positioned(
          right:110,
          top: 235,
          child: Container(
            key: _shadow1Key,
            width: 115,
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
                    ? Transform.translate(
                  offset: const Offset(0, -5),
                  child: Transform.rotate(
                    angle: .3,
                    child: Image.network(actor.imageUrl ?? '',
                        width: 130,fit: BoxFit.contain),
                  ),
                )
                    : Transform.rotate(
                      angle: .3,
                      child: Image.network(shadow1.imageUrl ?? '',
                      width: 130, fit: BoxFit.contain),
                    );
              },
            ),
          ),
        ),

        /// ===== Actor =====
        if (!isPlacedCorrectly)
          Positioned(
            left: 20,
            bottom: 140,
            child: Draggable<String>(
              data: actor.id,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.rotate(
                  angle: .3,
                  child: Image.network(
                    actor.imageUrl ?? '',
                    width: 130,
                  ),
                ),
              ),
              childWhenDragging: const SizedBox(),
              child: Transform.rotate(
                angle: .3,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 130,
                ),
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