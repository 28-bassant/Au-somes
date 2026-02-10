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
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        1,
        2,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        // تحميل الصور أولاً
        await _preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final actorElement = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

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
        final containerLeft = actorLeft + actorWidth * 0.34;
        final containerTop = actorTop + actorHeight * 0.1;
        final containerWidth = actorWidth * 0.32;
        final containerHeight = actorHeight * 0.76;

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