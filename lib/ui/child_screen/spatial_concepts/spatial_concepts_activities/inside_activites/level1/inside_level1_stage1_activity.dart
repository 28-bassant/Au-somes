
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class InsideLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  InsideLevel1Stage1ActivityState createState() =>
      InsideLevel1Stage1ActivityState();
}

class InsideLevel1Stage1ActivityState extends State<InsideLevel1Stage1Activity> {
  ActivityResponse? activity;
  bool isLoading = true;
  late AudioPlayer _player;

  Uint8List? actorBytes; // الصورة بعد تحميلها

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchActivity();
  }

  void fetchActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.inside_outside_activityId,
      1,
      1,
    );

    setState(() {
      activity = response;
      isLoading = false;
    });

    playSound();
    fetchActorImage();
  }

  Future<void> fetchActorImage() async {
    try {
      final actorElement =
      activity!.elements!.firstWhere((e) => e.role == 'Actor');
      final resp = await http.get(Uri.parse(actorElement.imageUrl!));
      if (resp.statusCode == 200) {
        setState(() {
          actorBytes = resp.bodyBytes;
        });
      }
    } catch (e) {
      print("Error loading actor image: $e");
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final anchorElement =
    activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return Stack(
      alignment: Alignment.center,
      children: [
        /// الأنكور (لو اتداس عليه = Try Again)
        Positioned(
          left: 27,
          right:22,
          top: 70,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showMsg(context: context, msg: 'Try Again');
            },
            child: Container(
              child: Image.network(
                anchorElement.imageUrl ?? '',
                fit: BoxFit.contain,

              ),
            ),
          ),
        ),

        /// الأكتور (الإجابة الصح)
        if (actorBytes != null)
          Positioned(
            left: 161,
            top: 189,
            child: GestureDetector(
              onTap: () {
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  widget.onNextStage?.call();
                });
              },
              child: Image.memory(
                actorBytes!,
                width: width*.16,
                height: height*.2,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}