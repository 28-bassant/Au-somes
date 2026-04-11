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
class ShapeAndShadowLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const ShapeAndShadowLevel1Stage1({Key? key, this.onNextStage})
      : super(key: key);

  @override
  ShapeAndShadowLevel1Stage1State createState() =>
      ShapeAndShadowLevel1Stage1State();
}

class ShapeAndShadowLevel1Stage1State extends State<ShapeAndShadowLevel1Stage1>
    with SingleTickerProviderStateMixin {
  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;
  bool hasPlayedSound = false;
  late AudioPlayer _player;
  late AnimationController _animationController;
  ActivityElement? shadowElement;
  List<ActivityElement>? actors;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fetchActivity();
  }

  Future fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.shape_and_shadow_activityId,
        1,
        1,
      );
      if (!mounted) return;

      activity = response;
      shadowElement = activity!.elements!
          .firstWhere((e) => e.role == 'Shadow', orElse: () => activity!.elements!.first);
      actors = activity!.elements!.where((e) => e.role == 'Actor').toList();

      await preloadImages();

      // تشغيل الصوت عند التحميل
      await playSound();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading activity: $e");
    }
  }

  Future preloadImages() async {
    final images = activity!.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty);
    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  /// تشغيل الصوت الأساسي مرة واحدة
  Future playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
    hasPlayedSound = true;
  }


  int _wrongAttempts = 0; // عدد مرات الضغط على Actors الغلط

  void onActorTap(ActivityElement actor) {
    if (isPlacedCorrectly || shadowElement == null) return;

    // -------------------- Actor صح --------------------
    if (actor.targetedZoneId != null &&
        actor.targetedZoneId == shadowElement!.id) {
      setState(() => isPlacedCorrectly = true);

      // تشغيل حركة بسيطة
      _animationController.forward(from: 0);

      // بعد فترة قصيرة الانتقال للمرحلة التالية
      Future.delayed(const Duration(milliseconds: 700), () {
        widget.onNextStage?.call();
      });
    } else {
      // -------------------- Actor غلط --------------------
      if (_wrongAttempts == 0) {
        TryAgainSound.play(); // شغل الصوت لأول مرة فقط
      }

      // زيادة العدادات
      setState(() {
        _wrongAttempts++;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading ||shadowElement==null||  actors == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
      /// Shadow أو الإجابة الصحيحة
      Positioned(
      top: h * 0.15,
      left: w * 0.35,
      child: SizedBox(
        width: w * 0.3,
        height: h * 0.25,
        child: Image.network(
          isPlacedCorrectly
              ? actors!
              .firstWhere(
                  (a) => a.targetedZoneId == shadowElement!.id)
              .imageUrl ?? ''
              : shadowElement!.imageUrl ?? '',
          fit: BoxFit.contain,
        ),
      ),
    ),/// Actors draggable أو tappable
        for (int i = 0; i < actors!.length; i++)
        // ارسم Actor فقط لو لم يتحط بعد في الـ Shadow
          if (!isPlacedCorrectly ||
              actors![i].targetedZoneId != shadowElement!.id)
            Positioned(
              bottom: h * 0.1,
              left: w * (0.15 + i * 0.45),
              child: GestureDetector(
                onTap: () => onActorTap(actors![i]),
                child: SizedBox(
                  width: w * 0.2,
                  height: h * 0.18,
                  child: Image.network(
                    actors![i].imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}