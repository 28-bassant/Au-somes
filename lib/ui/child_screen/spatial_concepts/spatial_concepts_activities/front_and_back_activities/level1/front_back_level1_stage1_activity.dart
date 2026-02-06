import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel1Stage1Activity({Key? key, this.onNextStage})
      : super(key: key);

  @override
  State<FrontBackLevel1Stage1Activity> createState() =>
      FrontBackLevel1Stage1ActivityState();
}

class FrontBackLevel1Stage1ActivityState
    extends State<FrontBackLevel1Stage1Activity> {
  late AudioPlayer _player;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late ActivityResponse _activity;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> fetchActivity() async {
    return await ApiManager.getActivity(
      ApiConstants.front_back_activityId,
      1,
      1,
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
                // صورة الخلفية (Anchor) - متجاوبة مع الشاشة
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.network(anchorElement.imageUrl!),
                  ),
                ),

                // العنصر المتحرك - باستخدام نسب مئوية مع تعديل الموقع للأعلى
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // حساب النسب المئوية مع رفع العنصر للأعلى
                      final double leftPercent = 160 / 400;    // 40% من العرض
                      final double topPercent = 280 / 800;     // 35% من الارتفاع (بدلاً من 37.5%)
                      final double widthPercent = 140 / 400;   // 35% من العرض
                      final double heightPercent = 250 / 800;  // 31.25% من الارتفاع

                      final double actualLeft = constraints.maxWidth * leftPercent;
                      final double actualTop = constraints.maxHeight * topPercent;
                      final double actualWidth = constraints.maxWidth * widthPercent;
                      final double actualHeight = constraints.maxHeight * heightPercent;

                      return Stack(
                        children: [
                          Positioned(
                            left: actualLeft,
                            top: actualTop+80, // تم رفعه للأعلى
                            child: GestureDetector(
                              onTapDown: (details) {
                                final tap = details.localPosition;
                                final double containerHeight = actualHeight;
                                final correctTop = containerHeight * 2 / 4;
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
                                  firstElement.imageUrl!,
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