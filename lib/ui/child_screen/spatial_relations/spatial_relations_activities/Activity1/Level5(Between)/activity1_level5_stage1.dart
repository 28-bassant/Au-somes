import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class Activity1Level5Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const Activity1Level5Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  Activity1Level5Stage1State createState() => Activity1Level5Stage1State();
}

class Activity1Level5Stage1State extends State<Activity1Level5Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;

  // متغيرات جديدة للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // تحميل النشاط مرة واحدة في البداية
    _loadActivity();

    // تهيئة المتحكم في الحركة
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.sr_between_activityId,
        1,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
        });

        // تحميل الصور
        await _preloadImages(activity);

        // تشغيل الصوت بعد تحميل الصور
        if (!_hasPlayedSound) {
          await playSound();
          _hasPlayedSound = true;
        }

        setState(() {
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

    _imagesLoaded = true;
  }

  Future<void> playSound() async {
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;
    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void repeatSound() => playSound();

  // دالة للتعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      // المرة الأولى: تشغيل صوت "حاول مجدداً"
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      // المرة الثانية: تحريك الإجابة الصحيحة
      _startAnswerAnimation();
    }
  }

  // دالة لبدء حركة الإجابة الصحيحة
  void _startAnswerAnimation() {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
      });

      // بدء الحركة المتكررة
      _animationController!.repeat(reverse: true);

      // توقف الحركة بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingAnswer) {
          setState(() {
            _isAnimatingAnswer = false;
          });
          _animationController!.stop();
          _animationController!.value = 0;
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
    // إذا كان في مرحلة التحميل
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // إذا كان هناك خطأ في تحميل النشاط
    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    // الحصول على العناصر
    final anchorElements = _activity!.elements!
        .where((e) => e.role == 'Anchor')
        .toList();

    final correctActor = _activity!.elements!
        .firstWhere((e) => e.isCorrect == true);

    final wrongActor = _activity!.elements!
        .firstWhere((e) => e.isCorrect == false);

    // التأكد من وجود anchorين
    if (anchorElements.length < 2) {
      return const Center(child: Text('يجب أن يكون هناك anchorين'));
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Anchor الأول (على اليسار)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.25 - 80,
            child: Image.network(
              anchorElements[0].imageUrl ?? '',
              width: 100,
              fit: BoxFit.contain,
            ),
          ),

          // Anchor الثاني (على اليمين)
          Positioned(
            right: MediaQuery.of(context).size.width * 0.25 - 40,
            top: 230,
            child: Image.network(
              anchorElements[1].imageUrl ?? '',
              width: 120,
              fit: BoxFit.contain,
            ),
          ),

          // ❌ الإجابة الخاطئة (كرة خضراء - على اليمين)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.45,
            child: GestureDetector(
              onTap: _handleWrongAnswer,
              child: Image.network(
                wrongActor.imageUrl ?? '',
                width: 60,
              ),
            ),
          ),

          // ✅ الإجابة الصحيحة (كرة برتقالية - بين Anchorين)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 60,
            top: MediaQuery.of(context).size.height * 0.45,
            child: AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                double shakeValue = 0;
                if (_isAnimatingAnswer) {
                  shakeValue = 20 * sin(_animationController!.value * pi);
                }

                return Transform.translate(
                  offset: Offset(shakeValue, 0),
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _wrongAttempts = 0;
                    _isAnimatingAnswer = false;
                  });
                  _animationController?.stop();
                  _animationController?.value = 0;

                  WellDoneOverlay.show(context);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      widget.onNextStage?.call();
                    }
                  });
                },
                child: Image.network(
                  correctActor.imageUrl ?? '',
                  width: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}