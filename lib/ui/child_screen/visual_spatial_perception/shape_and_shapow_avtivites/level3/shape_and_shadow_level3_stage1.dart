import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../reinforcement_widgets/true_answer_sound.dart';
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

class ShapeAndShadowLevel3Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;
  const ShapeAndShadowLevel3Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  State createState() => ShapeAndShadowLevel3Stage1State();
}

class ShapeAndShadowLevel3Stage1State extends State<ShapeAndShadowLevel3Stage1> {
  Map<String, String> placed = {}; // shadowId -> actorImage

  // Shadows
  late ActivityElement shadowSquareLarge;
  late ActivityElement shadowSquareSmall;
  late ActivityElement shadowTriangleLarge;
  late ActivityElement shadowTriangleSmall;

  // Actors
  late ActivityElement actorSquareRed;
  late ActivityElement actorSquareBlue;
  late ActivityElement actorTriangleRed;
  late ActivityElement actorTriangleBlue;
  late AudioPlayer _player;
  bool hasPlayedSound = false;
  String? audioUrl;
  Map<String, bool> wrongPlayed = {};
  bool _isCompleted = false;
  String audioAsset = 'sounds/sound.mp3';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _loadActivity();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSound();
    });
  }


  void _loadActivity() {
    // Shadows
    shadowSquareLarge = ActivityElement(
      id: 'square_large_shadow',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959524/activities/images/f3qaaioxxy2rmp08r4po.png',
      role: 'Shadow',
    );
    shadowSquareSmall = ActivityElement(
      id: 'square_small_shadow',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959524/activities/images/f3qaaioxxy2rmp08r4po.png',
      role: 'Shadow',
    );
    shadowTriangleLarge = ActivityElement(
      id: 'triangle_large_shadow',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959525/activities/images/dlfbuhheschxfdw1sgqd.png',
      role: 'Shadow',
    );
    shadowTriangleSmall = ActivityElement(
      id: 'triangle_small_shadow',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959525/activities/images/dlfbuhheschxfdw1sgqd.png',
      role: 'Shadow',
    );

    // Actors (مراعاة اللون من Postman)
    actorSquareRed = ActivityElement(
      id: 'square_red',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959524/activities/images/y9jm6jzrjkm6wc2zkyi9.png',
      targetedZoneId: 'square_large_shadow',
      role: 'Actor',
    );
    actorSquareBlue = ActivityElement(
      id: 'square_blue',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959526/activities/images/stytwokeh76ltgu6higp.png',
      targetedZoneId: 'square_small_shadow',
      role: 'Actor',
    );
    actorTriangleRed = ActivityElement(
      id: 'triangle_red',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959523/activities/images/pztakjabuwepudeqd7cz.png',
      targetedZoneId: 'triangle_large_shadow',
      role: 'Actor',
    );
    actorTriangleBlue = ActivityElement(
      id: 'triangle_blue',
      imageUrl: 'https://res.cloudinary.com/au-some/raw/upload/v1773959523/activities/images/pztakjabuwepudeqd7cz.png',
      targetedZoneId: 'triangle_small_shadow',
      role: 'Actor',
    );

    setState(() {});
  }
  Widget buildActorImage(String url, {double? width, double? height}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
      Container(color: Colors.red.shade700,),
    );
  }

  Widget _buildShadow(ActivityElement shadow, double w, double h) {
    return DragTarget<ActivityElement>(
      onWillAccept: (_) => !_isCompleted,
      onAccept: (actor) {
        if (_isCompleted) return;

        final isCorrect = actor.targetedZoneId == shadow.id;

        if (isCorrect) {
          setState(() {
            placed[shadow.id!] = actor.imageUrl!;
          });

          // reset wrong attempts for better UX
          wrongPlayed.clear();

          final isLast = placed.length == 4;

          if (isLast) {
            if (!_isCompleted) {
              _isCompleted = true;

              WellDoneOverlay.show(context);

              Future.delayed(const Duration(seconds: 2), () {
                widget.onNextStage?.call();
              });
            }
          } else {
            TrueAnswerSound.play();
          }

          return;
        }

        // ❌ Wrong answer
        final actorId = actor.id ?? '';

        if (wrongPlayed[actorId] != true) {
          TryAgainSound.play();
          wrongPlayed[actorId] = true;
        }
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: w,
          height: h,
          child: buildActorImage(
            placed.containsKey(shadow.id)
                ? placed[shadow.id]!
                : shadow.imageUrl!,
            width: w,
            height: h,
          ),
        );
      },
    );
  }
  Widget _buildDraggableActor(ActivityElement actor, {double? width, double? height}) {
    final isPlaced = placed[actor.targetedZoneId] == actor.imageUrl;
    return Draggable<ActivityElement>(
      data: actor,
      feedback: SizedBox(width: width, height: height, child: buildActorImage(actor.imageUrl!, width: width, height: height)),
      childWhenDragging: const SizedBox(),
      child: isPlaced
          ? const SizedBox()
          : SizedBox(width: width, height: height, child: buildActorImage(actor.imageUrl!, width: width, height: height)),
    );
  }

  Future playSound() async {
    try {
      debugPrint("PLAY SOUND START");

      await _player.stop();
      await _player.play(AssetSource(audioAsset));

      debugPrint("PLAY SOUND DONE");
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  void repeatSound() => playSound();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;

    // Actor إضافي لو محتاج
    final customActor = ActivityElement(
      id: 'triangle_custom',
      imageUrl: AppAssets.dress_outside,
      targetedZoneId: actorTriangleBlue.targetedZoneId,
      role: 'Actor',
    );

    return Stack(
      children: [
        // 🔵 Shadows
        Positioned(
          top: h * 0.2,
          left: w * 0.015,
          child: _buildShadow(shadowSquareLarge, w * 0.26, w * 0.25),
        ),
        Positioned(
          top: h * 0.196,
          left: w * 0.7,
          child: _buildShadow(shadowTriangleLarge, w * 0.25, w * 0.25),
        ),
        Positioned(
          top: h * 0.228,
          left: w * 0.5,
          child: _buildShadow(shadowSquareSmall, w * 0.18, w * 0.18),
        ),
        Positioned(
          top: h * 0.227,
          left: w * 0.29,
          child: _buildShadow(shadowTriangleSmall, w * 0.18, w * 0.18),
        ),

        // 🟠 Actors draggable
        Positioned(
          bottom: h * 0.12,
          left: w * 0.04,
          child: _buildDraggableActor(
              actorSquareRed, width: w * 0.238, height: w * 0.238),
        ),
        Positioned(
          bottom: h * 0.12,
          left: w * 0.3,
          child: _buildDraggableActor(
              actorSquareBlue, width: w * 0.18, height: w * 0.18),
        ),
        Positioned(
          bottom: h * 0.12,
          left: w * 0.51,
          child: _buildDraggableActor(
              actorTriangleRed, width: w * 0.234, height: w * 0.234),
        ),
        Positioned(
          bottom: h * 0.12,
          left: w * 0.78,
          child: _buildDraggableActor(
              customActor, width: w * 0.18, height: w * 0.18),
        ),
      ],
    );
  }}

