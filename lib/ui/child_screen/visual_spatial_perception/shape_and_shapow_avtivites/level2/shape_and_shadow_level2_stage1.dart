import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ShapeAndShadowLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const ShapeAndShadowLevel2Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => ShapeAndShadowLevel2Stage1State();
}

class ShapeAndShadowLevel2Stage1State extends State<ShapeAndShadowLevel2Stage1> {
  ActivityResponse? _activity;
  bool _isLoading = true;

  late AudioPlayer _player;

  List<ActivityElement> shadows = [];
  List<ActivityElement> actors = [];

  Map<String, String> placed = {}; // shadowId -> actorImage

  // لكل Actor: هل ممكن يعمل Try في الدور الحالي
  Map<String, bool> _actorCanTry = {};

  // ترتيب محدد للActors: العنصر الأول هو العنب
  late List<ActivityElement> orderedActors;
  int _grapeTryCount = 0; // عدد محاولات Try في الدور الحالي
  bool _firstAnswerDone = false; // هل تم وضع أي Actor صح؟

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.shape_and_shadow_activityId,
        2,
        1,
      );

      if (!mounted) return;

      _activity = response;

      shadows = _activity!.elements!
          .where((e) => e.role == 'Shadow')
          .toList();

      actors = _activity!.elements!
          .where((e) => e.role == 'Actor')
          .toList();

      // ترتيب محدد: [عنب, تفاحة, موزة] حسب المثال
      orderedActors = [
        actors[1], // عنب
        actors[0], // تفاحة
        actors[2], //
      ];

      // تهيئة كل Actor للسماح بـ Try في الدور الأول
      for (var actor in actors) {
        _actorCanTry[actor.id ?? ''] = true;
      }

      await _preloadImages();
      await _playSound();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _preloadImages() async {
    final images = _activity!.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty);

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> _playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  double safe(num? value) => (value ?? 0).toDouble();

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

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
        children: [
    /// 🔵 Shadows
          Positioned(
            top: h * 0.14,
            left: w * 0.07,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 2.4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: w * 0.8,
                height: h * 0.2,
                child: Stack(
                  children: [
                    for (int i = 0; i < shadows.length; i++)
                      Positioned(
                        top: safe(shadows[i].y) != 0
                            ? h * safe(shadows[i].y)
                            : h * 0.001,
                        left: safe(shadows[i].x) != 0
                            ? w * safe(shadows[i].x)
                            : w * (0.1 + (1 - i) * 0.34),
                        child: DragTarget<ActivityElement>(
                          onWillAccept: (actor) => true,
                          onAccept: (actor) {
                            if (actor.targetedZoneId == shadows[i].id) {
                              setState(() {
                                placed[shadows[i].id!] = actor.imageUrl ?? '';
                                _firstAnswerDone = true;
                                _grapeTryCount = 0;
                              });

                              WellDoneOverlay.show(context);

                              if (placed.length == shadows.length) {
                                Future.delayed(const Duration(milliseconds: 700), () {
                                  widget.onNextStage?.call();
                                });
                              }
                            } else {
                              final isGrape = actor == orderedActors[2];

                              if (isGrape) {
                                if (!_firstAnswerDone && _grapeTryCount < 2) {
                                  TryAgainSound.play();
                                  _grapeTryCount++;
                                } else if (_firstAnswerDone && _grapeTryCount < 1) {
                                  TryAgainSound.play();
                                  _grapeTryCount++;
                                }
                              }
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return SizedBox(
                              width: w * 0.25,
                              height: h * 0.2,
                              child: Image.network(
                                placed.containsKey(shadows[i].id)
                                    ? placed[shadows[i].id]!
                                    : shadows[i].imageUrl ?? '',
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          /// 🟠 Actors
          // داخل الـ build() عند رسم Actors
          for (int i = 0; i < orderedActors.length; i++)
            if (!placed.values.contains(orderedActors[i].imageUrl))
              Positioned(
                bottom: h * 0.1,
                left: w * (0.1 + i * 0.3),
                child: Draggable<ActivityElement>(
                  data: orderedActors[i],
                  feedback: Image.network(
                    orderedActors[i].imageUrl ?? '',
                    width: w * 0.25,
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Image.network(
                    orderedActors[i].imageUrl ?? '',
                    width: w * 0.25,
                  ),
                ),
              ),
        ],
    );
  }
}