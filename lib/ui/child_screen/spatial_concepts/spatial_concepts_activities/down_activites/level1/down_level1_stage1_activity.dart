import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class DownLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const DownLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  DownLevel1Stage1ActivityState createState() => DownLevel1Stage1ActivityState();
}

class DownLevel1Stage1ActivityState extends State<DownLevel1Stage1Activity> {
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
        ApiConstants.up_down_activityId,
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
    // احتفظ بـ MediaQuery هنا كما في الكود الأصلي
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');
    final actorElement = _activity!.elements!.firstWhere((e) => e.role == 'Actor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        /// 🪑 حجم الكرسي
        final anchorWidth = screenWidth * 2.6;
        final anchorHeight = screenHeight * 0.7;

        /// مكان بداية الكرسي من فوق
        final anchorTop = screenHeight * 0.14;

        /// حجم القطة
        final actorSize = anchorWidth * 0.19;

        /// مكان الجلوس على الكرسي
        final seatLevel = anchorTop + anchorHeight * 0.57;

        /// موقع القطة بحيث رجلها تلمس الكرسي
        final actorTop = seatLevel - actorSize * 0.01;
        final actorLeft = (screenWidth - actorSize) / 2 -30;

        // موقع وحجم الكونتينر الشفاف على القطة
        final containerLeft = width * 0.30;
        final containerTop = height * 0.45;
        final containerWidth = width * 0.28;
        final containerHeight = height * 0.2;

        final containerRect =
        Rect.fromLTWH(
            containerLeft, containerTop, containerWidth, containerHeight);

        return Stack(
          children: [
            // 🪑 الكرسي
            Positioned(
              top: anchorTop,
              left: (screenWidth - anchorWidth) / 2 + 15,
              child: Image.network(
                anchorElement.imageUrl ?? '',
                width: anchorWidth,
                height: anchorHeight,
                fit: BoxFit.contain,
              ),
            ),

            // 🐱 القطة
            Positioned(
              top: actorTop,
              left: actorLeft,
              child: Image.network(
                actorElement.imageUrl ?? '',
                width: actorSize,
                height: actorSize,
                fit: BoxFit.contain,
              ),
            ),

            // الكونتينر التجريبي (منطقة الضغط)
            Positioned(
              left: containerLeft,
              top: containerTop,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.transparent,
              ),
            ),

            // 🌟 GestureDetector يغطي الشاشة كلها للتحقق من الضغط
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final tap = box.globalToLocal(details.globalPosition);

                  if (containerRect.contains(tap)) {
                    // الضغط داخل القطة
                    WellDoneOverlay.show(context);
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        widget.onNextStage?.call();
                      }
                    });
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}
