import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../api/api_constants.dart';
import '../../../../../api/api_manager.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
import '../../../reinforcement_widgets/true_answer_sound.dart';

class VisualClosureLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const VisualClosureLevel1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => VisualClosureLevel1Stage1State();
}

class VisualClosureLevel1Stage1State extends State<VisualClosureLevel1Stage1> {
  ActivityResponse? _activity;
  bool _isLoading = true;
  late AudioPlayer _player;

  List<ActivityElement> shadows = [];
  List<ActivityElement> actors = [];
  ActivityElement? anchor;

  Map<String, String> placed = {};
  int currentStep = 0;

  List<String> stepInstructions = [];
  List<String> stepSuccess = [];

  Map<String, bool> actorCanTry = {};
  late List<ActivityElement> orderedActors;

  String? lastInstructionAudio;

  bool _allImagesLoaded = false;
  int _totalImages = 0;
  int _loadedImagesCount = 0;

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
    if (_allImagesLoaded && _activity?.audioUrl != null && _activity!.audioUrl!.isNotEmpty) {
      lastInstructionAudio = _activity!.audioUrl!;
      await _playSound(lastInstructionAudio!);
    }
  }

  Future<void> _loadActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.visual_closure_activityId,
      1,
      1,
    );

    _activity = response;
    shadows = _activity!.elements!.where((e) => e.role == 'Shadow').toList();
    actors = _activity!.elements!.where((e) => e.role == 'Actor').toList();
    anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    orderedActors = [
      actors[1],
      actors[2],
      actors[0],
    ];

    _resetActorTry();

    stepInstructions = _activity?.deceptionInstructions ?? [];
    stepSuccess = _activity?.deceptionInstructions ?? [];

    _totalImages = shadows.length + actors.length;

    setState(() => _isLoading = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  Future<void> _playSound(String url) async {
    if (url.isEmpty) return;
    if (_allImagesLoaded) {
      await _player.stop();
      await _player.play(UrlSource(url));
    }
  }

  void repeatSound() {
    if (lastInstructionAudio != null && _allImagesLoaded) {
      _playSound(lastInstructionAudio!);
    }
  }

  void onActorTap(ActivityElement actor) async {
    if (!_allImagesLoaded) return;

    final correctActor = orderedActors[currentStep];

    if (actor.id == correctActor.id) {
      final shadow = shadows.firstWhere((s) => s.id == actor.targetedZoneId);
      setState(() {
        placed[shadow.id!] = actor.imageUrl!;
        currentStep++;
      });

      // ✅ لو مش اخر خطوة → TrueAnswerSound
      if (currentStep < actors.length) {
        TrueAnswerSound.play(); // تشغيل صوت الإجابة الصحيحة

        // ✅ انتظار 300 مللي ثانية فقط بدل 500
        await Future.delayed(const Duration(milliseconds: 800));

        // صوت النجاح
        if (currentStep - 1 < stepSuccess.length && _allImagesLoaded) {
          await _playSound(stepSuccess[currentStep - 1]);
        }
      } else {
        // اخر خطوة → WellDoneOverlay
        WellDoneOverlay.show(context);
      }

      if (currentStep < actors.length) _resetActorTry();

      // الصوت الجديد (Instruction)
      if (currentStep < actors.length &&
          stepInstructions.length > currentStep - 1) {
        lastInstructionAudio = stepInstructions[currentStep - 1];
        if (_allImagesLoaded) {
          await _playSound(lastInstructionAudio!);
        }
      }

      if (currentStep == actors.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          widget.onNextStage?.call();
        });
      }
    } else {
      if (actorCanTry[actor.id ?? ''] == true) {
        if (_allImagesLoaded) {
          TryAgainSound.play();
        }
        actorCanTry[actor.id ?? ''] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned(
          top: h * 0.15,
          left: w * 0.05,
          child: Container(
            color: Colors.transparent,
            width: w * 0.9,
            child: Image.asset(
              AppAssets.star ?? '',
              width: w * 0.3,
              height: h * 0.36,
            ),
          ),
        ),

        Positioned(
          top: h * 0.197,
          left: w * 0.51,
          child: _buildShadow(shadows[1], w),
        ),

        Positioned(
          top: h * 0.34,
          left: w * 0.45,
          child: _buildShadow(shadows[2], w),
        ),

        Positioned(
          top: h * 0.33,
          left: w * 0.16,
          child: _buildShadow(shadows[0], w),
        ),

        for (int i = 0; i < actors.length; i++)
          if (!placed.values.contains(actors[i].imageUrl))
            Positioned(
              bottom: h * 0.1,
              left: w * (0.1 + i * 0.3),
              child: GestureDetector(
                onTap: () => onActorTap(actors[i]),
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

  Widget _buildShadow(ActivityElement shadow, double w) {
    return SizedBox(
      width: w * 0.2,
      height: w * 0.2,
      child: Image.network(
        placed.containsKey(shadow.id)
            ? placed[shadow.id]!
            : shadow.imageUrl ?? '',
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            _checkAllImagesLoaded();
          }
          return child;
        },
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}