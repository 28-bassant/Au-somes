import 'dart:async';
import 'dart:math' as math;
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../reinforcement_widgets/true_answer_sound.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class ShapeAndShadowLevel3Stage2 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const ShapeAndShadowLevel3Stage2({Key? key, this.onNextStage})
      : super(key: key);

  @override
  State createState() => ShapeAndShadowLevel3Stage2State();
}

class ShapeAndShadowLevel3Stage2State
    extends State<ShapeAndShadowLevel3Stage2> {
  ActivityResponse? _activity;
  bool _isLoading = true;
  late AudioPlayer _player;

  // Shadows
  ActivityElement? shadow1;
  ActivityElement? shadow2;

  // Actors
  ActivityElement? actor1;
  ActivityElement? actor2;
  ActivityElement? actor3;

  // shadowId -> actor
  Map<String, ActivityElement> placed = {};

  // rotation لكل actor
  Map<String, double> actorRotation = {};

  // لكل actor محاولة واحدة فقط
  Map<String, int> actorTryCount = {};
  bool _isCompleted = false;
  Map<String, bool> wrongPlayed = {};
  bool _usedHint = false;
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
        3,
        2,
      );

      if (!mounted) return;

      _activity = response;

      final shadowsList =
      _activity!.elements!.where((e) => e.role == 'Shadow').toList();
      shadow1 = shadowsList[0];
      shadow2 = shadowsList[1];

      final actorsList =
      _activity!.elements!.where((e) => e.role == 'Actor').toList();
      actor1 = actorsList[0];
      actor2 = actorsList[1];
      actor3 = actorsList[2];

      // 🎯 rotations
      actorRotation[actor1!.id!] = 0;
      actorRotation[actor2!.id!] = -math.pi / 4;
      actorRotation[actor3!.id!] = math.pi;

      // 🔥 reset try لكل actor
      actorTryCount[actor1!.id!] = 0;
      actorTryCount[actor2!.id!] = 0;
      actorTryCount[actor3!.id!] = 0;

      await _preloadImages();

      //  تشغيل الصوت بعد تحميل الصور
      await _playSound();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _preloadImages() async {
    final images = _activity!.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> _playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    try {
      // ✅ الطريقة الأضمن: setSourceUrl ثم play
      await _player.stop();
      await _player.setSourceUrl(_activity!.audioUrl!);
      await _player.resume();
    } catch (e) {
      print("خطأ في تشغيل الصوت: $e");
      // محاولة بديلة
      try {
        await _player.stop();
        await _player.play(UrlSource(_activity!.audioUrl!));
      } catch (e2) {
        print("خطأ في المحاولة البديلة: $e2");
      }
    }
  }

  void repeatSound() {
    _playSound();
  }

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
        // 🔵 Shadows
        Positioned(
          top: h * 0.2,
          left: w * 0.2,
          child: _buildShadow(shadow1, w),
        ),
        Positioned(
          top: h * 0.2,
          left: w * 0.55,
          child: _buildShadow(shadow2, w),
        ),

        // 🟠 Actors
        Positioned(
          bottom: h * 0.1,
          left: w * 0.1,
          child: _buildDraggableActor(actor1),
        ),
        Positioned(
          bottom: h * 0.04,
          left: w * 0.4,
          width: w * .23,
          height: h * .21,
          child: _buildDraggableActor(actor2),
        ),
        Positioned(
          bottom: h * 0.1,
          left: w * 0.7,
          child: _buildDraggableActor(actor3),
        ),
      ],
    );
  }

  Widget _buildShadow(ActivityElement? shadow, double w) {
    return DragTarget<ActivityElement>(
      onWillAccept: (_) => !_isCompleted,
      onAccept: (actor) async {
        if (_isCompleted) return;

        final isCorrect = actor.targetedZoneId == shadow?.id;

        if (isCorrect) {
          setState(() {
            placed[shadow!.id!] = actor;
          });

          wrongPlayed.clear();

          final isLast = placed.length == 2;

          if (isLast) {
            if (!_isCompleted) {
              _isCompleted = true;

              // تسجيل النجاح
              final result = await ApiManager.logAttemptStatus(
                phaseId: _activity!.phaseId!,
                userHint: _usedHint,
              );

              print("RESULT: ${result?.isPassed}");

              // تحديث الـ Progress
              if (result?.isPassed == true) {
                await ApiManager.getProgressSummary();
              }

              WellDoneOverlay.show(context);

              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  widget.onNextStage?.call();
                }
              });
            }
          } else {
            TrueAnswerSound.play();
          }

          return;
        }

        final actorId = actor.id ?? '';

        if (wrongPlayed[actorId] != true) {
          setState(() {
            _usedHint = true;
          });

          TryAgainSound.play();
          wrongPlayed[actorId] = true;
        }
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: w * 0.22,
          height: w * 0.22,
          child: placed.containsKey(shadow?.id)
              ? Builder(
            builder: (_) {
              final placedActor = placed[shadow!.id]!;
              final isActor2 = placedActor.id == actor2?.id;
              return Transform.rotate(
                angle: actorRotation[placedActor.id!] ?? 0,
                child: Transform.scale(
                  scale: isActor2 ? 1.22 : 1.0,
                  child: Image.network(
                    placedActor.imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          )
              : Image.network(
            shadow?.imageUrl ?? '',
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildDraggableActor(
      ActivityElement? actor, {
        double? width,
        double? height,
      }) {
    final isPlaced = placed.containsValue(actor);
    final w = MediaQuery.of(context).size.width;
    final finalWidth = width ?? w * 0.21;
    final finalHeight = height ?? w * 0.20;
    final isActor2 = actor?.id == actor2?.id;

    return Draggable<ActivityElement>(
      data: actor,
      feedback: Transform.rotate(
        angle: actorRotation[actor?.id ?? ''] ?? 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: isActor2 ? finalWidth * 1.4 : finalWidth,
            height: isActor2 ? finalHeight * 1.4 : finalHeight,
            child: Image.network(
              actor?.imageUrl ?? '',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox(),
      child: isPlaced
          ? const SizedBox()
          : SizedBox(
        width: finalWidth,
        height: finalHeight,
        child: Image.network(
          actor?.imageUrl ?? '',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}