import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../api/api_constants.dart';
import '../../../../../api/api_manager.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart'; // لازم للـ firstWhereOrNull
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

class VisualClosureLevel3Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const VisualClosureLevel3Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => VisualClosureLevel3Stage1State();
}

class VisualClosureLevel3Stage1State extends State<VisualClosureLevel3Stage1> {
  late AudioPlayer _player;

  ActivityElement? anchor;
  List<ActivityElement> shadows = [];
  List<ActivityElement> actors = [];

  Map<String, String> placed = {}; // shadowId -> actorImage
  Map<String, bool> actorCanTry = {}; // actorId -> true لو ممكن TryAgain
  int currentStep = 0;

  // ترتيب الإجابة الصحيحة لكل خطوة
  late List<Map<String, ActivityElement>> stepCorrect;

  // أصوات لكل خطوة
  List<String> stepInstructions = [];
  List<String> stepSuccess = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  void _resetActorTry() {
    actorCanTry.clear();
    for (var actor in actors) {
      actorCanTry[actor.id ?? ''] = true;
    }
  }

  Future<void> _playSound(String url) async {
    if (url.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> _loadActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.visual_closure_activityId,
      3,
      1,
    );

    anchor = response.elements!.firstWhere((e) => e.role == 'Anchor');
    shadows = response.elements!.where((e) => e.role == 'Shadow').toList();
    actors = response.elements!.where((e) => e.role == 'Actor').toList();

    _resetActorTry();

    // ترتيب الإجابة الصحيحة حسب المطلوب
    stepCorrect = [
      {'actor': actors[1], 'shadow': shadows[0]}, // خطوة 0
      {'actor': actors[2], 'shadow': shadows[2]}, // خطوة 1
      {'actor': actors[0], 'shadow': shadows[3]}, // خطوة 2
      {'actor': actors[3], 'shadow': shadows[1]}, // خطوة 3
    ];

    // أصوات لكل خطوة (مثال، عدّلي حسب الأصوات الحقيقية)
    stepInstructions = response.deceptionInstructions ?? [];
    stepSuccess = response.deceptionInstructions ?? [];

    // 🔹 تشغيل أول صوت عند فتح النشاط
    if (response.audioUrl != null && response.audioUrl!.isNotEmpty) {
      await _playSound(response.audioUrl!);
    }

    setState(() {});
  }

  void onActorDragEnd(ActivityElement actor, ActivityElement shadow) {
    var correctActor = stepCorrect[currentStep]['actor'];
    var correctShadow = stepCorrect[currentStep]['shadow'];

    if (actor == correctActor && shadow == correctShadow) {
      setState(() {
        placed[shadow.id!] = actor.imageUrl!;
        currentStep++;
        _resetActorTry();
      });

      WellDoneOverlay.show(context);

      // تشغيل صوت الخطوة الحالية بدون await لتجنب توقف UI
      if (stepSuccess.length >= currentStep) {
        _playSound(stepSuccess[currentStep - 1]); // currentStep بعد الزيادة، لذلك -1
      }

      // لو خلصنا كل الخطوات
      if (currentStep == stepCorrect.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          widget.onNextStage?.call();
        });
      }
    } else {
      if (actorCanTry[actor.id ?? ''] == true) {
        TryAgainSound.play();
        actorCanTry[actor.id ?? ''] = false;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
        children: [
        /// ⭐ Anchor
        if (anchor != null)
    Positioned(
      top: h * 0.1,
      left: w * 0.07,
      child: Image.network(
        anchor!.imageUrl ?? '',
        width: w * 0.9,
        height: h * 0.39,
      ),
    ),/// 🔹 Shadows مع Container وردي خلفهم
          if (shadows.length >= 4) ...[
            Positioned(top: h * 0.19,
                left: w * 0.21, width: w * 0.134,
                height: h * 0.15, child: _buildShadow(shadows[1])),

            Positioned(top: h * 0.189, left: w * 0.58, width: w * 0.12, height: h * 0.15, child: _buildShadow(shadows[3])),
            Positioned(top: h * 0.389, left: w * 0.51, width: w * 0.14, height: h * 0.15, child: _buildShadow(shadows[0])),
            Positioned(top: h * 0.306, left: w * 0.76, width: w * 0.09, height: h * 0.15, child: _buildShadow(shadows[2])),
          ],

          /// 🟠 Actors draggable
          for (int i = 0; i < actors.length; i++)
            if (!placed.values.contains(actors[i].imageUrl))
              Positioned(
                bottom: h * 0.1,
                left: w * (0.1 + i * 0.2),
                child: Draggable<ActivityElement>(
                  data: actors[i],
                  feedback: Image.network(
                    actors[i].imageUrl ?? '',
                    width: w * 0.14,
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Image.network(
                    actors[i].imageUrl ?? '',
                    width: w * 0.14,
                  ),
                ),
              ),
        ],
    );
  }

  Widget _buildShadow(ActivityElement shadow) {
    bool isPlaced = placed.containsKey(shadow.id);
    return Stack(
      children: [
        // 🔹 Container وردي أكبر من Shadow

        // 🔹 Shadow أو Actor إذا ثبت مكانه
        DragTarget<ActivityElement>(
          onWillAccept: (_) => true,
          onAccept: (actor) => onActorDragEnd(actor, shadow),
          builder: (context, candidateData, rejectedData) {
            return isPlaced
                ? Image.network(placed[shadow.id]!)
                : Image.network(shadow.imageUrl ?? '', fit: BoxFit.contain);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}