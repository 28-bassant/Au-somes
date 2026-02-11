import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
class Activity6Level1Stage4 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity6Level1Stage4({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<Activity6Level1Stage4> createState() => Activity6Level1Stage4State();
}

class Activity6Level1Stage4State extends State<Activity6Level1Stage4> {
  late AudioPlayer _player;
  late ActivityResponse _activity;

  bool _imagesLoaded = false;
  bool _hasPlayedSound = false;
  bool isPlacedCorrectly = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<ActivityResponse> _loadActivity() async {
    _activity = await ApiManager.getActivity(
      ApiConstants.sr_up_down_activityId,
      2,
      4,
    );

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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  void repeatSound() => playSound();
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

        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;
              // حجم shadow
              final shadowSize = screenWidth * 0.70;
              // حجم المكعب القابل للسحب
              final actorSize = shadowSize * 0.4;
              final centerX = screenWidth / 2;
              final centerY = screenHeight / 2;

              final containerWidth = actorSize*.7; // نفس عرض الـ actor
              final containerHeight = actorSize; // نفس ارتفاع الـ actor أو Shadow لو عايزة أكبر


              return Stack(
                children: [
                  /// shadow
                  Positioned(
                    left: centerX - shadowSize / 2,
                    top: centerY - shadowSize / 2+screenHeight*.05,
                    child: Image.network(
                      shadow.imageUrl ?? '',
                      width: shadowSize,
                      height: shadowSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  //مكان الاسقاط
                  Positioned(
                    left: centerX - shadowSize / 2+screenWidth*.01,
                    top: centerY - shadowSize / 2+screenHeight*.067,
                    width: containerWidth,
                    height: containerHeight,
                    child: DragTarget<String>(
                      onWillAccept: (data) => data == actor.targetedZoneId,
                      onAccept: (data) {
                        setState(() => isPlacedCorrectly = true);
                        WellDoneOverlay.show(context);
                        Future.delayed(const Duration(seconds: 3), () {
                          widget.onNextStage?.call();
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          color: Colors.transparent,
                          child: isPlacedCorrectly
                              ? Transform.translate(
                            offset: Offset(0,30 ),
                                child: Transform.scale(
                                  scale: 1.3,
                                  child: Image.network(
                                    actor.imageUrl ?? '',
                                    width: actorSize,
                                    height: actorSize,
                                  ),
                                ),
                              )
                              : const SizedBox(),
                        );
                      },
                    ),
                  ),


                  /// المكعب القابل للسحب
                  if (!isPlacedCorrectly)
                    Positioned(
                      right: 40,
                      bottom: 50,
                      child: Draggable<String>(
                        data: actor.targetedZoneId,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: actorSize,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: actorSize,
                          ),
                        ),
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: actorSize,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}