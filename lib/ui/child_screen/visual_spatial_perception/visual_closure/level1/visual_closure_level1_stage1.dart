import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../api/api_constants.dart';
import '../../../../../api/api_manager.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
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

  // ✅ الجديد: حفظ آخر instruction
  String? lastInstructionAudio;

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

    // ✅ أول صوت (Instruction)
    if (_activity?.audioUrl != null && _activity!.audioUrl!.isNotEmpty) {
      lastInstructionAudio = _activity!.audioUrl!;
      await _playSound(lastInstructionAudio!);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _playSound(String url) async {
    if (url.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  // ✅ repeat آخر instruction
  void repeatSound() {
    if (lastInstructionAudio != null) {
      _playSound(lastInstructionAudio!);
    }
  }

  void onActorTap(ActivityElement actor) async {
    final correctActor = orderedActors[currentStep];

    if (actor.id == correctActor.id) {
      final shadow = shadows.firstWhere((s) => s.id == actor.targetedZoneId);
      setState(() {
        placed[shadow.id!] = actor.imageUrl!;
        currentStep++;
      });

      WellDoneOverlay.show(context);

      // 🔹 صوت النجاح (مش هيتخزن)
      if (currentStep - 1 < stepSuccess.length) {
        await _playSound(stepSuccess[currentStep - 1]);
      }

      if (currentStep < actors.length) _resetActorTry();

      // ✅ الصوت الجديد (Instruction) + تخزينه
      if (currentStep < actors.length &&
          stepInstructions.length > currentStep - 1) {
        lastInstructionAudio = stepInstructions[currentStep - 1];
        await _playSound(lastInstructionAudio!);
      }

      if (currentStep == actors.length) {
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        /// ⭐ Anchor
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

        /// 🔺 Shadow فوق
        Positioned(
          top: h * 0.197,
          left: w * 0.51,
          child: _buildShadow(shadows[1], w),
        ),

        /// ⬜ Shadow تحت
        Positioned(
          top: h * 0.34,
          left: w * 0.45,
          child: _buildShadow(shadows[2], w),
        ),

        /// ⚪ Shadow شمال
        Positioned(
          top: h * 0.33,
          left: w * 0.16,
          child: _buildShadow(shadows[0], w),
        ),

        /// 🟠 Actors
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
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}