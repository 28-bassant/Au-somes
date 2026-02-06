import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel1Stage2Activity({Key? key, this.onNextStage})
      : super(key: key);

  @override
  State<FrontBackLevel1Stage2Activity> createState() => FrontBackLevel1Stage2ActivityState();
}

class FrontBackLevel1Stage2ActivityState extends State<FrontBackLevel1Stage2Activity> {
  late AudioPlayer _player;
  late ActivityResponse _activity;
  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> fetchActivity() async {
    return await ApiManager.getActivity(
      ApiConstants.front_back_activityId,
      1,
      2,
    );
  }

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }

    _imagesLoaded = true;
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
      future: fetchActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Error loading activity'));
        }

        _activity = snapshot.data!;

        final firstElement = _activity.elements!.first;
        final anchorElement =
        _activity.elements!.firstWhere((e) => e.role == 'Anchor');

        // تحميل الصور الأول
        if (!_imagesLoaded) {
          _preloadImages(_activity).then((_) {
            if (!_hasPlayedSound) {
              playSound();
              _hasPlayedSound = true;
            }
            setState(() {});
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // صورة الخلفية (Anchor) - تملأ الشاشة مع الحفاظ على النسبة
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.network(
                      anchorElement.imageUrl ?? '',
                      width: 400, // الحجم الأصلي للصورة
                      height: 800,
                    ),
                  ),
                ),

                // العنصر المتحرك - باستخدام نسب مئوية
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // حساب النسب المئوية بناءً على حجم الصورة الأصلي (400×800)
                      final double leftPercent = 160 / 400;    // 40% من العرض
                      final double topPercent = 300 / 800;     // 37.5% من الارتفاع
                      final double widthPercent = 140 / 400;   // 35% من العرض
                      final double heightPercent = 250 / 800;  // 31.25% من الارتفاع

                      // الحجم الحقيقي لصورة الخلفية بعد FittedBox
                      final double imageWidth = constraints.maxWidth;
                      final double imageHeight = constraints.maxHeight;

                      // حساب المواقع الفعلية
                      final double actualLeft = imageWidth * leftPercent;
                      final double actualTop = imageHeight * topPercent;
                      final double actualWidth = imageWidth * widthPercent;
                      final double actualHeight = imageHeight * heightPercent;

                      return Stack(
                        children: [
                          Positioned(
                            left: actualLeft,
                            top: actualTop,
                            child: GestureDetector(
                              onTapDown: (details) {
                                final tap = details.localPosition;
                                final double containerHeight = actualHeight;

                                // المنطقة الصحيحة للنقر: آخر نصف ارتفاع الصورة
                                final correctTop = containerHeight / 2;
                                final correctBottom = containerHeight;

                                if (tap.dy >= correctTop && tap.dy <= correctBottom) {
                                  WellDoneOverlay.show(context);
                                  Future.delayed(const Duration(seconds: 3), () {
                                    widget.onNextStage?.call();
                                  });
                                }
                              },
                              child: Container(
                                width: actualWidth,
                                height: actualHeight,
                                child: Image.network(
                                  firstElement.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}