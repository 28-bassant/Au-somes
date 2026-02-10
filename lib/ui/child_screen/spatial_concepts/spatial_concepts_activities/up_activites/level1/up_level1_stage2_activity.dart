import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  UpLevel1Stage2ActivityState createState() => UpLevel1Stage2ActivityState();
}

class UpLevel1Stage2ActivityState extends State<UpLevel1Stage2Activity> {
  ActivityResponse? activity;
  bool isLoading = true;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        1,
        2,
      );

      if (mounted) {
        setState(() {
          activity = response;
        });

        // Preload الصور أولاً
        await preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
        if (!hasPlayedSound && activity?.audioUrl != null && activity!.audioUrl!.isNotEmpty) {
          await _player.stop();
          await _player.play(UrlSource(activity!.audioUrl!));
          setState(() {
            hasPlayedSound = true;
          });
        }

        setState(() {
          imagesLoaded = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final actorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Actor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        /// 🪑 حجم الكرسي
        final anchorWidth = screenWidth * 2.6;
        final anchorHeight = screenHeight * 0.7;

        /// مكان بداية الكرسي من فوق
        final anchorTop = screenHeight * 0.14;

        /// حجم القطة
        final actorSize = anchorWidth * 0.20;

        /// مكان الجلوس على الكرسي
        final seatLevel = anchorTop + anchorHeight * 0.53;

        /// موقع القطة بحيث رجلها تلمس الكرسي
        final actorTop = seatLevel - actorSize * 0.85;
        final actorLeft = (screenWidth - actorSize) / 2 + 16;

        // موقع وحجم الكونتينر الشفاف على القطة
        final containerLeft = width * 0.40;
        final containerTop = height * 0.23;
        final containerWidth = width * 0.28;
        final containerHeight = height * 0.2;

        final containerRect =
        Rect.fromLTWH(containerLeft, containerTop, containerWidth, containerHeight);

        return Stack(
          children: [
            // 🪑 الكرسي
            Positioned(
              top: anchorTop,
              left: (screenWidth - anchorWidth) / 2 + 15,
              child: Image.network(
                anchorElement.imageUrl ?? '',
                width: anchorWidth,
                height: anchorHeight,
                fit: BoxFit.contain,
              ),
            ),

            // 🐱 القطة
            Positioned(
              top: actorTop,
              left: actorLeft,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
                fit: BoxFit.contain,
              ),
            ),

            // 🌟 GestureDetector يغطي الشاشة كلها للتحقق من الضغط
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final tap = box.globalToLocal(details.globalPosition);

                  if (containerRect.contains(tap)) {
                    // الضغط داخل القطة
                    WellDoneOverlay.show(context);
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        widget.onNextStage?.call();
                      }
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