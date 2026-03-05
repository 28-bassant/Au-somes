import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class BetweenLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const BetweenLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  BetweenLevel1Stage1ActivityState createState() =>
      BetweenLevel1Stage1ActivityState();
}
class BetweenLevel1Stage1ActivityState extends State<BetweenLevel1Stage1Activity> with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

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

  void _handleWrongAnswer() {
    if(_wrongAttempts>=2)return;

    _wrongAttempts++;

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts >= 2) {
      // المرة الثانية: تحريك الإجابة الصحيحة
      _startAnswerAnimation();
    }
  }

  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer) {
      setState(() {
        _isAnimatingAnswer = true;
      });
      _animationController.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 3), () {
        _animationController.stop();
        _animationController.value = 0;
        setState(() {
          _isAnimatingAnswer = false;
        });
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

    final firstElement = _activity!.elements!.first;  // الصح
    final lastElement = _activity!.elements!.last;    // الخطأ
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
        builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;
      final scale = screenWidth / 400; // التصميم الأصلي 400px

      final anchorTop = 340 * scale;
      final actorLeft = 120 * scale;
      final actorTop = 320 * scale;
      final actorWidth = 80 * scale;
      final actorHeight = 85 * scale;

      return Stack(
        children: [
        // Anchor
        Positioned(
        left: 15 * scale,
        top: anchorTop,
        child: Image.network(
          anchorElement.imageUrl ?? '',
          width: 90 * scale,
          fit: BoxFit.contain,
        ),
      ),

    // الأكتور الصحيح مع اهتزاز
    Positioned(
    left: actorLeft,
    top: actorTop,
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
      child: GestureDetector(
        onTap: () {
          // الضغط على الأكتور الصح → WellDone + المرحلة التالية
          WellDoneOverlay.show(context);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) widget.onNextStage?.call();
          });
        },
        child: Image.network(
          firstElement.imageUrl ?? '',
          width: actorWidth,
          height: actorHeight,
          fit: BoxFit.cover,
        ),
      ),
    ),
    ),
    ///anchor
    Positioned(
       left: 210* scale,
          top: anchorTop,
      child: Image.network(
          anchorElement.imageUrl ?? '',
        width: 90 * scale,
           fit: BoxFit.contain,
        ),
         ),

    // الأكتور الخطأ
    Positioned(
    left: 310 * scale,
    top: actorTop,
    child: GestureDetector(
      onTap: _handleWrongAnswer,
      child: Image.network(
        lastElement.imageUrl ?? '',
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
