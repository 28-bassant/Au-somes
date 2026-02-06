
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
class BetweenLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;
  const BetweenLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage2ActivityState createState() => BetweenLevel1Stage2ActivityState();
}

class BetweenLevel1Stage2ActivityState extends State<BetweenLevel1Stage2Activity> {
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
      ApiConstants.between_activityId,
      1,
      2,
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

    final actorElement = activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final anchorElement = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // 🪑 حجم ومكان الأنكور
        final anchorWidth = screenWidth * 2.6;
        final anchorHeight = screenHeight * 0.7;
        final anchorTop = screenHeight * 0.14;
        final anchorLeft = (screenWidth - anchorWidth) / 2 + 6;

        // 🐱 حجم ومكان الأكتور
        final actorWidth = screenWidth * 0.7;  // نسبة من عرض الشاشة
        final actorHeight = actorWidth * 220 / 300; // الحفاظ على نسبة الصورة الأصلية
        final actorTop = anchorTop + anchorHeight * 0.53 - actorHeight * 0.35;
        final actorLeft = (screenWidth - actorWidth) / 2 + 8;

        // 🌟 حجم ومكان الكونتينر الشفاف على الأكتور
        final containerLeft = actorLeft+actorWidth*.34;
        final containerTop = actorTop+actorHeight*.1;
        final containerWidth = actorWidth*.32;
        final containerHeight = actorHeight*.76;

        final containerRect = Rect.fromLTWH(
          containerLeft,
          containerTop,
          containerWidth,
          containerHeight,
        );

        return Stack(
          children: [
            // 🪑 Anchor
            Positioned(
              top: anchorTop,
              left: anchorLeft,
              child: Image.network(
                anchorElement.imageUrl ?? '',
                width: anchorWidth,
                height: anchorHeight,
                fit: BoxFit.contain,
              ),
            ),

            // 🐱 Actor
            Positioned(
              top: actorTop,
              left: actorLeft,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: actorWidth,
                height: actorHeight,
                fit: BoxFit.cover,
              ),
            ),
            // 🌟 GestureDetector على جزء الأكتور
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final tap = box.globalToLocal(details.globalPosition);

                  if (containerRect.contains(tap)) {
                    WellDoneOverlay.show(context);
                    Future.delayed(const Duration(seconds: 3), () {
                      widget.onNextStage?.call();
                    });
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}