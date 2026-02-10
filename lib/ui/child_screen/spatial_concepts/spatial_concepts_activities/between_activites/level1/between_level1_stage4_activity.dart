import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/well_done_overlay.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/app_assets.dart';

class BetweenLevel1Stage4Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage4Activity({Key? key, this.onNextStage})
      : super(key: key);

  @override
  BetweenLevel1Stage4ActivityState createState() =>
      BetweenLevel1Stage4ActivityState();
}

class BetweenLevel1Stage4ActivityState extends State<BetweenLevel1Stage4Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  // متغيرات الإجابة الخاطئة وحركة الإجابة الصحيحة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        1,
        4,
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
    // تحميل الصور من النشاط
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

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts >= 2) {
      _startAnswerAnimation();
    }
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });
      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingAnswer) {
          _animationController!.stop();
          _animationController!.value = 0;
          setState(() {
            _isAnimatingAnswer = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null || _activity!.elements!.isEmpty) {
      return const Center(child: Text('Error loading activity'));
    }

    final actorElement = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final wrongActorElement = _activity!.elements!.lastWhere((e) => e.role == 'Actor');
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // 🪑 حجم الأنكور
        final anchorWidth = screenWidth * 0.33;
        final anchorHeight = screenHeight * 0.18;

        final anchors = [
          Offset(screenWidth * 0.05, screenHeight * 0.35),
          Offset(screenWidth * 0.60, screenHeight * 0.35),
          Offset(screenWidth * 0.05, screenHeight * 0.62),
          Offset(screenWidth * 0.39, screenHeight * 0.62),
        ];

        // 🐱 حجم الأكتور
        final actorWidth = screenWidth * 0.55;
        final actorHeight = screenHeight * 0.4;
        // موقع الأكتور الصح
        final actorOffset = Offset((screenWidth - actorWidth) / 2, screenHeight * 0.20);

        // موقع الأكتور الغلط
        final wrongOffset = Offset(screenWidth * 0.6, screenHeight * 0.48);

        // 🌟 الكونتينر الشفاف على الأكتور الصح
        final correctRect = Rect.fromLTWH(
          actorOffset.dx + actorWidth * 0.29,
          actorOffset.dy + actorHeight * 0.2,
          actorWidth * 0.4,
          actorHeight * 0.57,
        );

        // 🌟 الكونتينر الشفاف على الأكتور الخطأ
        final wrongRect = Rect.fromLTWH(
          wrongOffset.dx + actorWidth * 0.29,
          wrongOffset.dy + actorHeight * 0.2,
          actorWidth * 0.4,
          actorHeight * 0.57,
        );

        return Stack(
          children: [
            // الأنكور - Image.asset كما في الأصل
            for (final offset in anchors)
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Image.asset(
                  AppAssets.table,
                  width: anchorWidth,
                  height: anchorHeight,
                  fit: BoxFit.contain,
                ),
              ),

            // 🐱 الأكتور الصح مع الاهتزاز
            Positioned(
              left: actorOffset.dx,
              top: actorOffset.dy,
              child: AnimatedBuilder(
                animation: _animationController ?? AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = 12 * sin(_animationController!.value * pi); // تصحيح: * 2 * pi
                  }
                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: Image.network(
                  actorElement.imageUrl ?? '',
                  width: actorWidth,
                  height: actorHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 🐱 الأكتور الخطأ
            Positioned(
              left: wrongOffset.dx,
              top: wrongOffset.dy,
              child: Image.network(
                wrongActorElement.imageUrl ?? '',
                width: actorWidth,
                height: actorHeight,
                fit: BoxFit.cover,
              ),
            ),

            // 🌟 كونتينر الأكتور الصح مع GestureDetector
            Positioned(
              left: correctRect.left,
              top: correctRect.top,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _wrongAttempts = 0;
                    _isAnimatingAnswer = false;
                  });
                  _animationController?.stop();
                  _animationController?.value = 0;

                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () { // تغيير من 2 إلى 3 ثواني
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                child: Container(
                  width: correctRect.width,
                  height: correctRect.height,
                  color: Colors.transparent,
                ),
              ),
            ),

            // 🌟 كونتينر الأكتور الخطأ مع GestureDetector
            Positioned(
              left: wrongRect.left,
              top: wrongRect.top,
              child: GestureDetector(
                onTap: _handleWrongAnswer,
                child: Container(
                  width: wrongRect.width,
                  height: wrongRect.height,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}