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
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ShapeAndShadowLevel1Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const ShapeAndShadowLevel1Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => ShapeAndShadowLevel1Stage2State();
}

class ShapeAndShadowLevel1Stage2State extends State<ShapeAndShadowLevel1Stage2>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  late AudioPlayer _player;
  late AnimationController _animationController;

  List<ActivityElement> shadows = [];
  List<ActivityElement> actors = [];

  // 🟢 كل Shadow مرتبط بالأكتور الصح بتاعه
  Map<String, String> placed = {}; // shadowId -> actorImage

  int _wrongAttempts = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadActivity();
  }


  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.shape_and_shadow_activityId,
        1,
        2,
      );

      if (!mounted) return;

      _activity = response;

      shadows = _activity!.elements!
          .where((e) => e.role == 'Shadow')
          .toList();

      actors = _activity!.elements!
          .where((e) => e.role == 'Actor')
          .toList();

      await _preloadImages();
      await _playSound();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading activity: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  Future<void> _preloadImages() async {
    final images = _activity!.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty);

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }


  void onActorTap(int index) {
    final actor = actors[index];

    ActivityElement? correctShadow;

    try {
      correctShadow = shadows.firstWhere(
            (s) => s.id != null && s.id == actor.targetedZoneId,
      );
    } catch (e) {
      correctShadow = null;
    }

    if (correctShadow == null) {
      if (_wrongAttempts == 0) TryAgainSound.play();
      setState(() => _wrongAttempts++);
      return;
    }

    setState(() {
      // 🟢 نحط الأكتور في مكان الشادو الصح بس
      placed[correctShadow!.id!] = actor.imageUrl ?? '';
    });

    _animationController.forward(from: 0);
    WellDoneOverlay.show(context);

    if (placed.length == shadows.length) {
      Future.delayed(const Duration(milliseconds: 700), () {
        widget.onNextStage?.call();
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 🟢 حل مشكلة int? و double
  double safe(num? value) => (value ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final orderedActors = [
      actors[1], // تفاحة
      actors[0], // موزة
      actors[2], // عنب
    ];
    return Stack(
        children: [
    // 🔵 Shadows
    for (int i = 0; i < shadows.length; i++)
    Positioned(
        top: safe(shadows[i].y) != 0 ? h * safe(shadows[i].y) : h * 0.15,
    left: safe(shadows[i].x) != 0
    ? w * safe(shadows[i].x)
        : w * (0.2 + i * 0.35),
      width: i == 1 ? w * 0.28 : w * 0.25,
      height: i == 1 ? h * 0.22 : h * 0.2,
      child: Image.network(
        placed.containsKey(shadows[i].id)
            ? placed[shadows[i].id]! // 👈 هنا بيظهر الأكتور الصح بس
            : shadows[i].imageUrl ?? '',
        fit: BoxFit.contain,
      ),
    ),

          // 🟠 Actors
          for (int i = 0; i < orderedActors.length; i++)
            if (!placed.values.contains(orderedActors[i].imageUrl)) // ✅ شرط الاختفاء
              Positioned(
                bottom: h * 0.1,
                left: w * (0.1 + i * 0.3),
                width: w * 0.2,
                height: h * 0.18,
                child: GestureDetector(
                  onTap: () => onActorTap(actors.indexOf(orderedActors[i])),
                  child: Image.network(
                    orderedActors[i].imageUrl ?? '',
                  ),
                ),
              ),
        ],
    );
  }
}