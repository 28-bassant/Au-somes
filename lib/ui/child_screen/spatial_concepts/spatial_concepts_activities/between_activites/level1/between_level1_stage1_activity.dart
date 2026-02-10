import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage1ActivityState createState() =>
      BetweenLevel1Stage1ActivityState();
}

class BetweenLevel1Stage1ActivityState extends State<BetweenLevel1Stage1Activity> {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        1,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = response;
        });

        // تحميل الصور أولاً
        await _preloadImages(response!);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          setState(() {
            _hasPlayedSound = true;
          });
        }

        setState(() {
          _imagesLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

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

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final firstElement = _activity!.elements!.first;
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double anchorLeft = 0 * scale;
        final double anchorRight = 0 * scale;
        final double anchorTop = 70 * scale;
        final double actorLeft = 144 * scale;
        final double actorTop = 320 * scale;
        final double actorWidth = 115 * scale;
        final double actorHeight = 110 * scale;

        return Stack(
          alignment: Alignment.center,
          children: [
            /// الأنكور
            Positioned(
              left: anchorLeft,
              right: anchorRight,
              top: anchorTop,
              child: Container(
                child: Image.network(
                  anchorElement.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// الأكتور (الإجابة الصح)
            Positioned(
              left: actorLeft,
              top: actorTop,
              child: GestureDetector(
                onTap: () {
                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                child: Container(
                  child: Image.network(
                    firstElement.imageUrl ?? '',
                    width: actorWidth,
                    height: actorHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
