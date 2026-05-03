import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
import 'dart:math';

class OutsideLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const OutsideLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  OutsideLevel1Stage2ActivityState createState() =>
      OutsideLevel1Stage2ActivityState();
}

class OutsideLevel1Stage2ActivityState extends State<OutsideLevel1Stage2Activity>
    with SingleTickerProviderStateMixin {
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  late AudioPlayer _player;

  // متغيرات جديدة للإدارة
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
        ApiConstants.inside_outside_activityId,
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
    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    final deceptionUrl = _activity!.deceptionInstructions!.first;

    await _player.stop();
    await _player.play(UrlSource(deceptionUrl));
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

      _animationController!.repeat(reverse: true);

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activity == null) {
      return const Center(child: Text('Error loading activity'));
    }

    final firstElement = _activity!.elements!.first;
    final lastElement = _activity!.elements!.last;
    final anchorElement = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // افتراض أن التصميم الأصلي على شاشة 400px
        final double designWidth = 400.0;
        final double scale = screenWidth / designWidth;

        // تحويل القيم الثابتة إلى قيم متجاوبة
        final double wrong1Right = 0 * scale;
        final double wrong1Top = 200* scale;
        final double wrong1Width = 300 * scale;
        final double wrong1Height = 300 * scale;
        final double wrong2Left = 1 * scale;
        final double wrong2Top = 480 * scale;
        final double wrong2Width = 150 * scale;
        final double wrong2Height = 150 * scale;
        final double correctRight = 112* scale;
        final double correctTop = 330 * scale;
        final double correctWidth = 90 * scale;
        final double correctHeight = 80 * scale;
        final double shakeIntensity = 12 * scale;

        return Stack(
          alignment: Alignment.center,
          children: [
            /// الأنكور الأول
            Positioned(
              right: wrong1Right,
              top: wrong1Top,
              child: Container(
                child: Image.network(
                  anchorElement.imageUrl ?? '',
                  fit: BoxFit.fill,
                  width: wrong1Width,
                  height: wrong1Height,
                ),
              ),
            ),

            ///  ( Try Again)
            Positioned(
              left: wrong2Left,
              top: wrong2Top,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = shakeIntensity *
                        sin(_animationController!.value * 1 * pi);
                  }

                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    // إعادة تعيين المحاولات الخاطئة عند الإجابة الصحيحة
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
                child: Container(
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle: -pi/44,
                    child: Image.network(
                      lastElement.imageUrl ?? '',
                      fit: BoxFit.contain,
                      width: wrong2Width,
                      height: wrong2Height,
                    ),
                  ),
                ),
              ),
            ),),

            /// العنصر الصحيح مع الحركة
            Positioned(
              right: correctRight,
              top: correctTop,
              child: GestureDetector(
                onTap: () {
                  _handleWrongAnswer();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle:0,
                    child: Image.network(
                      lastElement.imageUrl ?? '',
                      width: correctWidth,
                      height: correctHeight,
                      fit: BoxFit.fill,

                    ),
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

/*import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class InsideLevel1Stage2Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel1Stage2Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  InsideLevel1Stage2ActivityState createState() =>
      InsideLevel1Stage2ActivityState();
}

class InsideLevel1Stage2ActivityState extends State<InsideLevel1Stage2Activity> {
  ActivityResponse? activity;
  bool isLoading = true;
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
        ApiConstants.inside_outside_activityId,
        1,
        2,
      );

      if (mounted) {
        setState(() {
          activity = response;
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
        final double anchorLeft = 25 * scale;
        final double anchorRight = 25 * scale;
        final double anchorTop = 120 * scale;
        final double actorLeft = 125 * scale;
        final double actorTop = 280 * scale;
        final double actorWidth = screenWidth * 0.32; // 32% من عرض الشاشة
        final double actorHeight = screenHeight * 0.2; // 20% من ارتفاع الشاشة

        final actorElement =
        activity!.elements!.firstWhere((e) => e.role == 'Actor');
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
                child: Container(
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle: .3,
                    child: Image.network(
                      actorElement.imageUrl ?? '',
                      width: actorWidth,
                      height: actorHeight,
                      fit: BoxFit.contain,
                    ),
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

 */