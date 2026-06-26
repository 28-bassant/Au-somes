import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../api/api_constants.dart';
import '../../../../../api/api_manager.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
import '../../../reinforcement_widgets/true_answer_sound.dart';

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

  Map<String, String> placed = {};
  Map<String, bool> actorCanTry = {};

  late List<String> targetIds;
  late List<ActivityElement> orderedActors;

  List<String> stepInstructions = [];
  List<String> stepSuccess = [];
  int currentStep = 0;

  // ✅ تخزين آخر instruction
  String? lastInstructionAudio;

  // ✅ متغيرات تتبع تحميل الصور
  Map<String, bool> _imagesLoaded = {};
  bool _allImagesLoaded = false;
  int _totalImages = 0;
  int _loadedImagesCount = 0;
  bool _usedHint = false;
  ActivityResponse? _activity;

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

  void _checkAllImagesLoaded() {
    _loadedImagesCount++;
    if (_loadedImagesCount >= _totalImages && !_allImagesLoaded) {
      _allImagesLoaded = true;
      _playInitialSoundIfReady();
    }
  }

  Future<void> _playInitialSoundIfReady() async {
    if (_allImagesLoaded && lastInstructionAudio != null) {
      await _playSound(lastInstructionAudio!);
    }
  }

  Future<void> _playSound(String url) async {
    if (url.isEmpty) return;
    // ✅ فقط شغل الصوت لو كل الصور تحملت
    if (_allImagesLoaded) {
      await _player.stop();
      await _player.play(UrlSource(url));
    }
  }

  // ✅ repeat
  void repeatSound() {
    if (lastInstructionAudio != null && _allImagesLoaded) {
      _playSound(lastInstructionAudio!);
    }
  }

  Future<void> _loadActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.visual_closure_activityId,
      2,
      1,
    );
    _activity = response;
    actors = response.elements!.where((e) => e.role == 'Actor').toList();
    anchor = response.elements!.firstWhere((e) => e.role == 'Anchor');

    targetIds = ['top', 'right', 'bottomLeft'];

    orderedActors = [
      actors[0],
      actors[1],
      actors[2],
    ];

    _resetActorTry();

    stepInstructions = response.deceptionInstructions ?? [];
    stepSuccess = response.deceptionInstructions ?? [];

    // ✅ تخزين أول instruction بدون تشغيله حالياً
    if (response.audioUrl != null && response.audioUrl!.isNotEmpty) {
      lastInstructionAudio = response.audioUrl!;
    }

    // ✅ حساب العدد الإجمالي للصور
    _totalImages = 1 + actors.length; // Anchor + Actors

    // ✅ تحميل صورة الـ Anchor
    if (anchor?.imageUrl != null) {
      _preloadImage(anchor!.imageUrl!, 'anchor');
    }

    // ✅ تحميل صور Actors
    for (var actor in actors) {
      if (actor.imageUrl != null) {
        _preloadImage(actor.imageUrl!, 'actor_${actor.id}');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void _preloadImage(String url, String key) {
    if (_imagesLoaded.containsKey(key)) return;

    _imagesLoaded[key] = false;

    Image.network(
      url,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _checkAllImagesLoaded();
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        _checkAllImagesLoaded(); // Count as loaded even if error
        return const SizedBox.shrink();
      },
    );
  }

  void onActorDragEnd(ActivityElement actor, String targetId) async {
    if (!_allImagesLoaded) return;

    bool isCorrect = false;

    if (currentStep == 0) {
      if (actor == actors[0] && targetId == targetIds[0]) {
        isCorrect = true;
      }
    } else if (currentStep == 1) {
      if (actor == actors[1] && targetId == targetIds[1]) {
        isCorrect = true;
      }
    } else if (currentStep == 2) {
      if (actor == actors[2] && targetId == targetIds[2]) {
        isCorrect = true;
      }
    }

    if (isCorrect) {
      setState(() {
        placed[targetId] = actor.imageUrl!;
        currentStep++;
      });

      if (currentStep < actors.length) {
        TrueAnswerSound.play();

        await Future.delayed(const Duration(milliseconds: 800));

        if (currentStep - 1 < stepSuccess.length) {
          await _playSound(stepSuccess[currentStep - 1]);
        }
      } else {
        // ✅ تسجيل الـ Progress قبل إنهاء المرحلة
        await _logProgress();

        WellDoneOverlay.show(context);
      }

      if (currentStep < actors.length) {
        _resetActorTry();
      }

      if (currentStep < actors.length &&
          stepInstructions.length > currentStep - 1) {
        lastInstructionAudio = stepInstructions[currentStep - 1];
        await _playSound(lastInstructionAudio!);
      }

      if (currentStep == actors.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
      }
    } else {
      if (actorCanTry[actor.id ?? ''] == true) {
        if (_allImagesLoaded) {
          TryAgainSound.play();
        }

        actorCanTry[actor.id ?? ''] = false;

        // ✅ تسجيل أن المستخدم أخطأ
        _usedHint = true;
      }
    }
  }

  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity!.phaseId}");
      print("RESULT = ${result?.isPassed}");

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
      }
    } catch (e) {
      print("Progress error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || anchor == null || actors.isEmpty) {
      return const Center(child: SizedBox());
    }

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        /// ⭐ Anchor
        Positioned(
          top: h * 0.15,
          left: w * 0.05,
          child: Image.network(
            anchor!.imageUrl ?? '',
            width: w * 0.9,
            height: h * 0.36,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                _checkAllImagesLoaded();
              }
              return child;
            },
          ),
        ),

        /// 🟦 المربعات
        Positioned(
          top: h * 0.182,
          left: w * 0.256,
          width: w * 0.234,
          height: w * 0.239,
          child: DragTarget<ActivityElement>(
            onWillAccept: (_) => _allImagesLoaded,
            onAccept: (actor) => onActorDragEnd(actor, targetIds[0]),
            builder: (context, _, __) {
              return placed.containsKey(targetIds[0])
                  ? Image.network(placed[targetIds[0]]!)
                  : const SizedBox();
            },
          ),
        ),

        Positioned(
          top: h * 0.2193,
          left: w * 0.735,
          width: w * 0.234,
          height: w * 0.239,
          child: DragTarget<ActivityElement>(
            onWillAccept: (_) => _allImagesLoaded,
            onAccept: (actor) => onActorDragEnd(actor, targetIds[1]),
            builder: (context, _, __) {
              return placed.containsKey(targetIds[1])
                  ? Image.network(placed[targetIds[1]]!)
                  : const SizedBox();
            },
          ),
        ),

        Positioned(
          top: h * 0.358,
          left: w * 0.135,
          width: w * 0.234,
          height: w * 0.239,
          child: DragTarget<ActivityElement>(
            onWillAccept: (_) => _allImagesLoaded,
            onAccept: (actor) => onActorDragEnd(actor, targetIds[2]),
            builder: (context, _, __) {
              return placed.containsKey(targetIds[2])
                  ? Image.network(placed[targetIds[2]]!)
                  : const SizedBox();
            },
          ),
        ),

        /// 🟠 Actors
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      _checkAllImagesLoaded();
                    }
                    return child;
                  },
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  actors[i].imageUrl ?? '',
                  width: w * 0.2,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      _checkAllImagesLoaded();
                    }
                    return child;
                  },
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