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

class VisualClosureLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const VisualClosureLevel2Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => VisualClosureLevel2Stage1State();
}

class VisualClosureLevel2Stage1State extends State<VisualClosureLevel2Stage1> {
  late AudioPlayer _player;
  bool isLoading = true;

  List<ActivityElement> actors = [];
  ActivityElement? anchor;

  Map<String, String> placed = {}; // targetId -> actorImage
  Map<String, bool> actorCanTry = {}; // actorId -> true لو ممكن TryAgain

  late List<String> targetIds; // id لكل مربع (فوق، يمين، شمال أسفل)
  late List<ActivityElement> orderedActors; // ترتيب Actors بالنسبة للمربعات

  // أصوات لكل خطوة
  List<String> stepInstructions = [];
  List<String> stepSuccess = [];
  int currentStep = 0;

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
      2,
      1,
    );

    actors = response.elements!.where((e) => e.role == 'Actor').toList();
    anchor = response.elements!.firstWhere((e) => e.role == 'Anchor');

    targetIds = ['top', 'right', 'bottomLeft'];

    orderedActors = [
      actors[0], // Actor 1 → top
      actors[1], // Actor 2 → right
      actors[2], // Actor 3 → bottomLeft
    ];

    _resetActorTry();

    // أصوات لكل خطوة
    stepInstructions = response.deceptionInstructions ?? [];
    stepSuccess = response.deceptionInstructions ?? [];

    // 🔹 شغّل أول صوت عند فتح النشاط (زي Stage1)
    if (response.audioUrl != null && response.audioUrl!.isNotEmpty) {
      await _playSound(response.audioUrl!);
    }

    setState(() {
      isLoading = false;
    });
  }

  void onActorDragEnd(ActivityElement actor, String targetId) async {
    bool isCorrect = false;

    // Step 0 → Actor 1 → top
    if (currentStep == 0) {
      if (actor == actors[0] && targetId == targetIds[0]) {
        isCorrect = true;
      }
    }
    // Step 1 → Actor 2 → bottomLeft
    else if (currentStep == 1) {
      if (actor == actors[1] && targetId == targetIds[1]) {
        isCorrect = true;
      }
    }
    // Step 2 → Actor 3 → right
    else if (currentStep == 2) {
      if (actor == actors[2] && targetId == targetIds[2]) {
        isCorrect = true;
      }
    }

    if (isCorrect) {
      setState(() {
        placed[targetId] = actor.imageUrl!;
        currentStep++;
      });

      WellDoneOverlay.show(context);

      // تشغيل صوت Success
      if (currentStep - 1 < stepSuccess.length) {
        await _playSound(stepSuccess[currentStep - 1]);
      }

      // إعادة تهيئة TryAgain للخطوة التالية
      if (currentStep < actors.length) _resetActorTry();

      // تشغيل صوت Instruction للخطوة التالية
      if (currentStep < actors.length && stepInstructions.length > currentStep - 1) {
        await _playSound(stepInstructions[currentStep - 1]);
      }

      // لو خلصنا كل الخطوات
      if (currentStep == actors.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          widget.onNextStage?.call();
        });
      }
    } else {
      // ❌ إجابة غلط → TryAgain مرة واحدة لكل Actor في الخطوة الحالية
      if (actorCanTry[actor.id ?? ''] == true) {
        TryAgainSound.play();
        actorCanTry[actor.id ?? ''] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading ||anchor==null|| actors.isEmpty) {
      return const Center(child: SizedBox()); // أو CircularProgressIndicator
    }
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
        children: [
        /// ⭐ Anchor
        if (anchor != null)
    Positioned(
      top: h * 0.15,
      left: w * 0.05,
      child: Image.network(
        anchor!.imageUrl ?? '',
        width: w * 0.9,
        height: h * 0.36,
      ),
    ),/// 🟦 المربعات الثابتة
          /// 🟦 المربع الأعلى
          Positioned(
            top: h * 0.182,
            left: w * 0.256,
            width: w * 0.234,
            height: w * 0.239,
            child: DragTarget<ActivityElement>(
              onWillAccept: (_) => true,
              onAccept: (actor) => onActorDragEnd(actor, targetIds[0]),
              builder: (context, candidateData, rejectedData) {
                bool isPlaced = placed.containsKey(targetIds[0]);
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent), // border شفاف
                    color: Colors.transparent, // خلفية شفاف
                  ),
                  child: isPlaced ? Image.network(placed[targetIds[0]]!) : null,
                );
              },
            ),
          ),

          /// 🟦 المربع يمين
          Positioned(
            top: h * 0.2193,
            left: w * 0.735,
            width: w * 0.234,
            height: w * 0.239,
            child: DragTarget<ActivityElement>(
              onWillAccept: (_) => true,
              onAccept: (actor) => onActorDragEnd(actor, targetIds[1]),
              builder: (context, candidateData, rejectedData) {
                bool isPlaced = placed.containsKey(targetIds[1]);
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                  ),
                  child: isPlaced ? Image.network(placed[targetIds[1]]!) : null,
                );
              },
            ),
          ),

          /// 🟦 المربع أسفل شمال
          Positioned(
            top: h * 0.358,
            left: w * 0.135,
            width: w * 0.234,
            height: w * 0.239,
            child: DragTarget<ActivityElement>(
              onWillAccept: (_) => true,
              onAccept: (actor) => onActorDragEnd(actor, targetIds[2]),
              builder: (context, candidateData, rejectedData) {
                bool isPlaced = placed.containsKey(targetIds[2]);
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                  ),
                  child: isPlaced ? Image.network(placed[targetIds[2]]!) : null,
                );
              },
            ),
          ),

          /// 🟠 Actors draggable
          for (int i = 0; i < actors.length; i++)
            if (!placed.values.contains(actors[i].imageUrl))
              Positioned(
                bottom: h * 0.1,
                left: w * (0.1 + i * 0.25),
                child: Draggable<ActivityElement>(
                  data: actors[i],
                  feedback: Image.network(
                    actors[i].imageUrl ?? '',
                    width: w * 0.2,
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Image.network(
                    actors[i].imageUrl ?? '',
                    width: w * 0.2,
                  ),
                ),
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