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
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
class ShapeAndShadowLevel2Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const ShapeAndShadowLevel2Stage2({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<ShapeAndShadowLevel2Stage2> createState() => ShapeAndShadowLevel2Stage2State();
}

class ShapeAndShadowLevel2Stage2State extends State<ShapeAndShadowLevel2Stage2> {
  ActivityResponse? _activity;
  bool _isLoading = true;
  late AudioPlayer _player;

  // Shadows
  ActivityElement? shadow1;
  ActivityElement? shadow2;
  ActivityElement? shadow3;

  // Actors
  ActivityElement? actor1;
  ActivityElement? actor2;
  ActivityElement? actor3;
  ActivityElement? actor4; // العنب
  ActivityElement? bagActor; // الشنطة

  Map<String, String> placed = {}; // shadowId -> actorImage

  // ✅ Track Try لكل Actor مرة واحدة
  Map<String, bool> _actorCanTry = {};

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
        2,
      );
      if (!mounted) return;
      _activity = response;
      final shadowsList =
      _activity!.elements!.where((e) => e.role == 'Shadow').toList();
      shadow1 = shadowsList[0];
      shadow2 = shadowsList[1];
      shadow3 = shadowsList[2];

      final actorsList =
      _activity!.elements!.where((e) => e.role == 'Actor').toList();
      actor1 = actorsList[0];
      actor2 = actorsList[1];
      actor3 = actorsList[2];
      actor4 = actorsList[3]; // العنب
      bagActor = actorsList[4]; // الشنطة

      // ✅ تهيئة Try لكل Actor
      _resetActorTry();

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

  void _resetActorTry() {
    for (var actor in [actor1, actor2, actor3, actor4]) {
      if (actor?.id != null) _actorCanTry[actor!.id!] = true;
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final bagTop = h * 0.12;
    final bagHeight = w * 0.67;

    return Stack(
      children: [
      // 🔴 الشنطة
      Positioned(
      top: bagTop,
      left: w * 0.17,
      child: Image.network(
        bagActor?.imageUrl ?? '',
        width: bagHeight,
        fit: BoxFit.contain,
      ),
    ),
    // 🔵 Shadows
    Positioned(top: bagTop + bagHeight * 0.6, left: w * 0.25, child: _buildShadow(shadow1, actor1, w)),
    Positioned(top: bagTop + bagHeight * 0.6, left: w * 0.41, child: _buildShadow(shadow3, actor3, w)),
    Positioned(top: bagTop + bagHeight * 0.6, left: w * 0.58, child: _buildShadow(shadow2, actor2, w)),

    // 🟠 Actors
        // 🟠 Actors في Container واحد مع إطار رمادي
        Positioned(
          bottom: h * 0.12,
          left: w * 0.1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.01),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيعهم متساوي داخل الكونتينر
              children: [
                _buildDraggableActor(actor1, w * 0.17, w * 0.20),
                SizedBox(width: w * 0.03), // مسافة بسيطة بينهم
                _buildDraggableActor(actor2, w * 0.17, w * 0.20),
                SizedBox(width: w * 0.03),
                _buildDraggableActor(actor3, w * 0.17, w * 0.20),
                SizedBox(width: w * 0.03),
                _buildDraggableActor(actor4, w * 0.20, w * 0.21),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShadow(ActivityElement? shadow, ActivityElement? actor, double w) {
    return DragTarget<ActivityElement>(
      onWillAccept: (_) => true,
      onAccept: (droppedActor) {
        if (droppedActor.targetedZoneId == shadow?.id) {
          setState(() {
            placed[shadow!.id!] = droppedActor.imageUrl ?? '';
            _resetActorTry(); // إعادة Try لكل دور جديد
          });
          WellDoneOverlay.show(context);
          if (placed.length == 3) {
            Future.delayed(const Duration(milliseconds: 700), () {
              widget.onNextStage?.call();
            });
          }
        } else {
          // ✅ Actor غلط → شغل TryOnce
          final actorId = droppedActor.id ?? '';
          if (_actorCanTry[actorId] == true) {
            TryAgainSound.play();
            _actorCanTry[actorId] = false;
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: w * 0.20,
          height: w * 0.20,
          child: Image.network(
            placed.containsKey(shadow?.id) ? placed[shadow!.id]! : shadow?.imageUrl ?? '',
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildDraggableActor(ActivityElement? actor, double width, double height) {
    final isPlaced = placed.containsValue(actor?.imageUrl ?? '');
    return Draggable<ActivityElement>(
      data: actor,
      feedback: SizedBox(
        width: width,
        height: height,
        child: Image.network(actor?.imageUrl ?? '', fit: BoxFit.contain),
      ),
      childWhenDragging: const SizedBox(),
      child: isPlaced
          ? const SizedBox()
          : SizedBox(
        width: width,
        height: height,
        child: Image.network(actor?.imageUrl ?? '', fit: BoxFit.contain),
      ),
    );
  }
}