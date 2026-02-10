import 'package:flutter/material.dart';
import 'dart:async';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../models/activities/activity_element.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class UpLevel2Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const UpLevel2Stage2Activity({
    Key? key,
    this.onNextStage,
  }) : super(key: key);

  @override
  UpLevel2Stage2ActivityState createState() =>
      UpLevel2Stage2ActivityState();
}

class UpLevel2Stage2ActivityState
    extends State<UpLevel2Stage2Activity> {

  ActivityResponse? activity;
  bool isLoading = true;
  bool isPlacedCorrectly = false;
  bool hasPlayedSound = false;
  bool imagesLoaded = false;

  late AudioPlayer _player;

  late ActivityElement actor;
  late ActivityElement shadow;
  late ActivityElement anchor;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.up_down_activityId,
        2,
        2,
      );

      if (mounted) {
        activity = response;

        actor = activity!.elements!.firstWhere((e) => e.role == 'Actor');
        shadow = activity!.elements!.firstWhere((e) => e.role == 'Shadow');
        anchor = activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        // Preload الصور أولاً
        await preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
        if (!hasPlayedSound && activity?.audioUrl != null && activity!.audioUrl!.isNotEmpty) {
          await _player.stop();
          await _player.play(UrlSource(activity!.audioUrl!));
          setState(() {
            hasPlayedSound = true;
          });
        }

        setState(() {
          imagesLoaded = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading activity: $e');
    }
  }

  Future<void> preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> playSound() async {
    if (activity?.audioUrl == null || activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // حساب عامل القياس بناءً على حجم الشاشة
    // 360px هو عرض الشاشة المرجعية (مثل معظم الموبايلات)
    final scale = screenWidth / 360.0;

    // 🪑 حجم الطرابيزة
    final anchorWidth = screenWidth * 2.6;
    final anchorHeight = screenHeight * 0.7;
    final anchorTop = screenHeight * 0.01;

    return Stack(
      children: [
        Positioned(
          top: anchorTop,
          left: (screenWidth - anchorWidth) / 2 + 15,
          child: Image.network(
            anchor.imageUrl ?? '',
            width: anchorWidth,
            height: anchorHeight,
            fit: BoxFit.contain,
          ),
        ),

        /// ===== Shadow (مكان الإسقاط) =====
        Positioned(
          left: 60 * scale, // أصبح متناسباً
          top: 80 * scale, // أصبح متناسباً
          child: DragTarget<String>(
            onWillAccept: (data) => data == shadow.id,
            onAccept: (data) {
              setState(() {
                isPlacedCorrectly = true;
              });

              WellDoneOverlay.show(context);

              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  widget.onNextStage?.call();
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return isPlacedCorrectly
                  ? Transform.translate(
                  offset: Offset(0, 20 * scale), // أصبح متناسباً
                  child: Transform.scale(
                    scale: .86,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      width: 250 * scale, // أصبح متناسباً
                      height: 250 * scale, // أصبح متناسباً
                      fit: BoxFit.cover,
                    ),
                  ))
                  : Image.network(
                shadow.imageUrl ?? '',
                width: 250 * scale, // أصبح متناسباً
              );
            },
          ),
        ),

        /// ===== Actor (اللي بيتسحب فعليًا) =====
        if (!isPlacedCorrectly)
          Positioned(
            right: 0,
            bottom: -15 * scale, // أصبح متناسباً
            child: Draggable<String>(
              data: actor.targetedZoneId,

              /// 👈 ده اللي الطفل شايفه وهو بيسحب
              feedback: Material(
                color: Colors.transparent,
                child: Image.network(
                  actor.imageUrl ?? '',
                  width: 220 * scale, // أصبح متناسباً
                ),
              ),

              /// 👈 نخفي الأصل
              childWhenDragging: const SizedBox(),

              /// 👈 الشكل قبل السحب
              child: Image.network(
                actor.imageUrl ?? '',
                width: 220 * scale, // أصبح متناسباً
              ),
            ),
          ),
      ],
    );
  }
}