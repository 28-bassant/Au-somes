import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
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

  @override
  void initState() {
    super.initState();
    _loadActivity();
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
      onWillAccept: (actor) => actor?.targetedZoneId == shadow.id,
      onAccept: (actor) {
        setState(() {
          placed[shadow.id!] = actor!.imageUrl!;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: w,
          height: h,
          child: buildActorImage(
            placed.containsKey(shadow.id) ? placed[shadow.id]! : shadow.imageUrl!,
            width: w,
            height: h,
          ),
        );
      },
    );
  }Widget _buildDraggableActor(ActivityElement actor, {double? width, double? height}) {
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

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;final customActor = ActivityElement(
      id: 'triangle_custom',
      imageUrl: AppAssets.dress_outside, // الصورة اللي حطيتيها
      targetedZoneId: actorTriangleBlue.targetedZoneId, // نخلي الـ Shadow نفسه
      role: 'Actor',
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShadow(shadowSquareLarge, w * 0.25, w * 0.25),

            _buildShadow(shadowTriangleLarge, w * 0.25, w * 0.25),
            _buildShadow(shadowSquareSmall, w * 0.18, w * 0.18),
            _buildShadow(shadowTriangleSmall, w * 0.18, w * 0.18),
          ],
        ),
        const SizedBox(height: 50),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDraggableActor(actorSquareRed, width: w * 0.22, height: w * 0.22),

            _buildDraggableActor(actorSquareBlue, width: w * 0.18, height: w * 0.18),
            _buildDraggableActor(actorTriangleRed, width: w * 0.22, height: w * 0.22),
            _buildDraggableActor(customActor, width: w * 0.18, height: w * 0.18),
          ],
        ),
      ],
    );
  }
}

// Dummy classes
class ActivityElement {
  final String? id;
  final String? imageUrl;
  final String? role;
  final String? targetedZoneId;
  ActivityElement({this.id, this.imageUrl, this.role, this.targetedZoneId});
}