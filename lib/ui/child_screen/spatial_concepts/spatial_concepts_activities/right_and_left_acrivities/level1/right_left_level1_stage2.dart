import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class RightLeftLevel1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const RightLeftLevel1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  RightLeftLevel1Stage2State createState() => RightLeftLevel1Stage2State();
}

class RightLeftLevel1Stage2State extends State<RightLeftLevel1Stage2> {
  late AudioPlayer _player;
  late ActivityResponse _activity;
  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.right_left_activityId,
      1,
      2,
    );

    // preload الصور
    final urls = _activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in urls) {
      await precacheImage(NetworkImage(url!), context);
    }

    _imagesLoaded = true;
    return _activity;
  }

  Future<void> playSound() async {
    if (_activity.audioUrl == null || _activity.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivityResponse>(
      future: _loadActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !_imagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        final lastElement = _activity.elements!.last;
        final anchorElement =
        _activity.elements!.firstWhere((e) => e.role == 'Anchor');

        // تشغيل الصوت مرة واحدة بعد تحميل الصور
        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        // استخدام LayoutBuilder للحصول على حجم الشاشة
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // افتراض أن التصميم الأصلي على شاشة 400px
            final double designWidth = 400.0;
            final double scale = screenWidth / designWidth;

            // تحويل القيم الثابتة إلى قيم متجاوبة
            final double anchorWidth = 600 * scale;
            final double actorLeft = 200 * scale;
            final double actorTop = 350 * scale;
            final double actorWidth = 200 * scale;
            final double actorHeight = 200 * scale;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Anchor background
                Center(
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    width: anchorWidth,
                    fit: BoxFit.contain,
                  ),
                ),

                // Actor image
                Positioned(
                  left: actorLeft,
                  top: actorTop,
                  child: GestureDetector(
                    onTapDown: (details) {
                      final local = details.localPosition;
                      final imageWidth = actorWidth;
                      final imageHeight = actorHeight;

                      // تحديد المنطقة الصح: منتصف الصورة تقريبًا (بنسب مئوية متجاوبة)
                      final correctArea = Rect.fromLTWH(
                        imageWidth * 0.25,  // 25% من العرض
                        imageHeight * 0.25, // 25% من الارتفاع
                        imageWidth * 0.5,   // 50% من العرض
                        imageHeight * 0.5,  // 50% من الارتفاع
                      );

                      if (correctArea.contains(local)) {
                        // ✅ صح
                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          widget.onNextStage?.call();
                        });
                      }
                    },
                    child: Container(
                      width: actorWidth,
                      height: actorHeight,
                      child: Image.network(
                        lastElement.imageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}