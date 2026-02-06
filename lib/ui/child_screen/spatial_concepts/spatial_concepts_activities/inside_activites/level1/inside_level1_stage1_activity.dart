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
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  Uint8List? actorBytes; // الصورة بعد تحميلها

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.inside_outside_activityId,
        1,
        1,
      );

      if (mounted) {
        setState(() {
          activity = response;
        });

        // تحميل الصور أولاً
        await _preloadImages(response!);

        // ثم تحميل صورة الأكتور
        await _fetchActorImage();

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
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

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    for (final url in images) {
      await precacheImage(NetworkImage(url!), context);
    }
  }

  Future<void> _fetchActorImage() async {
    try {
      final actorElement =
      activity!.elements!.firstWhere((e) => e.role == 'Actor');
      final resp = await http.get(Uri.parse(actorElement.imageUrl!));
      if (resp.statusCode == 200 && mounted) {
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double anchorLeft = 27 * scale;
        final double anchorRight = 22 * scale;
        final double anchorTop = 70 * scale;
        final double actorLeft = 161 * scale;
        final double actorTop = 189 * scale;
        final double actorWidth = screenWidth * 0.16; // 16% من عرض الشاشة
        final double actorHeight = screenHeight * 0.2; // 20% من ارتفاع الشاشة

        final anchorElement =
        activity!.elements!.firstWhere((e) => e.role == 'Anchor');

        return Stack(
          alignment: Alignment.center,
          children: [
            /// الأنكور (لو اتداس عليه = Try Again)
            Positioned(
              left: anchorLeft,
              right: anchorRight,
              top: anchorTop,
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
                left: actorLeft,
                top: actorTop,
                child: GestureDetector(
                  onTap: () {
                    WellDoneOverlay.show(context);
                    Future.delayed(const Duration(seconds: 3), () {
                      widget.onNextStage?.call();
                    });
                  },
                  child: Image.memory(
                    actorBytes!,
                    width: actorWidth,
                    height: actorHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}