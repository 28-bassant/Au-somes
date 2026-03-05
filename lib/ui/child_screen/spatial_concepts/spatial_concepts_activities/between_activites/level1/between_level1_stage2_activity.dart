import 'dart:math';

import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage2ActivityState createState() => BetweenLevel1Stage2ActivityState();
}
class BetweenLevel1Stage2ActivityState extends State<BetweenLevel1Stage2Activity>
    with SingleTickerProviderStateMixin {

  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  // 👇 لإدارة الأخطاء والتحريك
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadActivity();
  }


  Future<void> _loadActivity() async {
    try {
      final response = await ApiManager.getActivity(
        ApiConstants.between_activityId,
        1,
        2,
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

  void _handleWrongAnswer() {
    if (_wrongAttempts >= 2) return; // بعد المرة الثانية مش يحصل حاجة
    _wrongAttempts++;

    if (_wrongAttempts == 1) {
      // المرة الأولى: صوت Try Again
     TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      // المرة الثانية: اهتزاز الأكتور الصح
      _startAnswerAnimation();
    }
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer) {
      setState(() => _isAnimatingAnswer = true);
      _animationController.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 3), () {
        _animationController.stop();
        _animationController.value = 0;
        setState(() => _isAnimatingAnswer = false);
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activity == null) return const Center(child: Text('Error loading activity'));

    final firstElement = _activity!.elements!.first;  // الأكتور الصح
    final lastElement = _activity!.elements!.last;    // الأكتور الخطأ
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
        builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;

      // Anchor
      final anchorWidth = screenWidth * 1.8;
      final anchorHeight = screenHeight * 0.6;
      final anchorTop = screenHeight * 0.19;
      final anchorLeft = (screenWidth - anchorWidth) / 2 - (screenWidth * .098);

      // Actor
      final actorWidth = screenWidth * 0.7;
      final actorHeight = actorWidth * 220 / 300;
      final actorTop = anchorTop + anchorHeight * 0.53 - actorHeight * 0.35;
      final actorLeft = (screenWidth - actorWidth) / 2 - (screenWidth * .09);

      // Container على الأكتور الصح
      final containerLeft = actorLeft + actorWidth * 0.364;
      final containerTop = actorTop + actorHeight * 0.16;
      final containerWidth = actorWidth * 0.26;
      final containerHeight = actorHeight * 0.64;
      final containerRect = Rect.fromLTWH(containerLeft, containerTop, containerWidth, containerHeight);

      return Stack(
        children: [
        // Anchor
        Positioned(
        top: anchorTop,
        left: anchorLeft,
        child: Image.network(
          anchorElement.imageUrl ?? '',
          width: anchorWidth,
          height: anchorHeight,
          fit: BoxFit.contain,
        ),
      ),

    // Actor الصح مع اهتزاز
    Positioned(
    top: actorTop,
    left: actorLeft,
    child: AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
      double shakeValue = 0;
      if (_isAnimatingAnswer) {
        shakeValue = 12 * sin(_animationController.value * pi);
      }
      return Transform.translate(
        offset: Offset(shakeValue, 0),
        child: child,
      );
    },
      child: Image.network(
        firstElement.imageUrl ?? '',
        width: actorWidth,
        height: actorHeight,
        fit: BoxFit.cover,
      ),
    ),
    ),

          // Actor الخطأ
          Positioned(
            top: actorTop,
            right: screenWidth * 0.02,
            child: GestureDetector(
              onTap: _handleWrongAnswer,
              child: Image.network(
                lastElement.imageUrl ?? '',
                width: actorWidth * 0.27,
                height: actorHeight,
              ),
            ),
          ),

          // GestureDetector على الكونتينر الصح
          Positioned(
            left: containerLeft,
            top: containerTop,
            child: GestureDetector(
              onTap: () {
                WellDoneOverlay.show(context);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) widget.onNextStage?.call();
                });
              },
              child: Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.transparent, // لو عايزة تشوفيه خليها Colors.red.withOpacity(.3)
              ),
            ),
          ),
        ],
      );
        },
    );
  }
}
