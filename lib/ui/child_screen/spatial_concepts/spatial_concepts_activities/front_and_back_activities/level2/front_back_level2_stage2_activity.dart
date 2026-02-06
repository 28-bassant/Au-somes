import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel2Stage2Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<FrontBackLevel2Stage2Activity> createState() =>
      FrontBackLevel2Stage2ActivityState();
}

class FrontBackLevel2Stage2ActivityState
    extends State<FrontBackLevel2Stage2Activity> {
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
      ApiConstants.front_back_activityId,
      2,
      2,
    );

    // preload جميع الصور
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

        final actor = _activity.elements!.firstWhere((e) => e.role == 'Actor');
        final shadow = _activity.elements!.firstWhere((e) => e.role == 'Shadow');
        final anchor = _activity.elements!.firstWhere((e) => e.role == 'Anchor');

        // تشغيل الصوت مرة واحدة بعد تحميل الصور
        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        bool isPlacedCorrectly = false;

        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Anchor - متجاوب مع الشاشة
                    Positioned.fill(
                      child: Center(
                        child: Image.network(
                          anchor.imageUrl ?? '',
                          width: screenWidth * (600 / 400), // 600 ÷ 400 = 1.5
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // DragTarget (Shadow) - باستخدام نسب مئوية
                    Positioned(
                      left: screenWidth * (150 / 400),  // 150 ÷ 400 = 0.375
                      top: screenHeight * (300 / 800),  // 300 ÷ 800 = 0.375
                      child: DragTarget<String>(
                        onWillAccept: (data) => data == shadow.id,
                        onAccept: (_) {
                          setState(() => isPlacedCorrectly = true);
                          WellDoneOverlay.show(context);
                          Future.delayed(const Duration(seconds: 3), () {
                            widget.onNextStage?.call();
                          });
                        },
                        builder: (context, _, __) {
                          return Container(
                            width: screenWidth * (250 / 400), // 250 ÷ 400 = 0.625
                            height: screenWidth * (250 / 400),
                            child: isPlacedCorrectly
                                ? Image.network(
                              actor.imageUrl ?? '',
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              shadow.imageUrl ?? '',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                    // Draggable Actor - باستخدام نسب مئوية
                    if (!isPlacedCorrectly)
                      Positioned(
                        right: screenWidth * (40 / 400),     // 40 ÷ 400 = 0.1
                        bottom: screenHeight * (-15 / 800),  // -15 ÷ 800 = -0.01875
                        child: Draggable<String>(
                          data: actor.targetedZoneId,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: screenWidth * (220 / 400), // 220 ÷ 400 = 0.55
                              height: screenWidth * (220 / 400),
                              child: Image.network(
                                actor.imageUrl ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          childWhenDragging: const SizedBox(),
                          child: Container(
                            width: screenWidth * (220 / 400),
                            height: screenWidth * (220 / 400),
                            child: Image.network(
                              actor.imageUrl ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}