import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity5Level1Stage5 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity5Level1Stage5({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  State<Activity5Level1Stage5> createState() =>
      Activity5Level1Stage5State();
}

class Activity5Level1Stage5State extends State<Activity5Level1Stage5> {
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
      ApiConstants.sr_up_down_activityId,
      2,
      3,
    );

    // preload all images
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

        if (!_hasPlayedSound) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playSound();
            _hasPlayedSound = true;
          });
        }

        bool isPlacedCorrectly = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // صورة الـ Shadow - في الخلفية
                    Center(
                      child: Image.network(
                        shadow.imageUrl ?? '',
                        width: 500,
                        height: 500,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // DragTarget - حاوية فارغة
                    Positioned(
                      left: 110,
                      top: 320,
                      child: Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black
                            )
                        ),
                        child: DragTarget<String>(
                          onWillAccept: (data) => data == actor.targetedZoneId,
                          onAccept: (data) {
                            setState(() {
                              isPlacedCorrectly = true;
                            });
                            WellDoneOverlay.show(context);
                            Future.delayed(const Duration(seconds: 3), () {
                              widget.onNextStage?.call();
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Center(
                              child: isPlacedCorrectly
                                  ? Image.network(
                                actor.imageUrl ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              )
                                  : Container(
                                padding: EdgeInsets.all(8),

                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Draggable العنصر
                    if (!isPlacedCorrectly)
                      Positioned(
                        right: 40,
                        bottom: 0,
                        child: Draggable<String>(
                          data: actor.targetedZoneId,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.network(
                                actor.imageUrl ?? '',
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.network(
                              actor.imageUrl ?? '',
                              width: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: Image.network(
                            actor.imageUrl ?? '',
                            width: 50,
                            fit: BoxFit.contain,
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
