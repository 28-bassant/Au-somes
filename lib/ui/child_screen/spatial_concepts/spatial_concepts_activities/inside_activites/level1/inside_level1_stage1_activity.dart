import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../api/api_constants.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../../../ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import '../../../../../../utils/dialog_utils.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';
import 'dart:math';

class InsideLevel1Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const InsideLevel1Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  InsideLevel1Stage1ActivityState createState() =>
      InsideLevel1Stage1ActivityState();
}

class InsideLevel1Stage1ActivityState extends State<InsideLevel1Stage1Activity>
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
        final double anchorLeft = 120 * scale;
        final double anchorRight = 10 * scale;
        final double anchorTop = 130 * scale;
        final double wrongLeft = 0 * scale;
        final double wrongTop = 250 * scale;
        final double wrongWidth = 140 * scale;
        final double wrongHeight = 140 * scale;
        final double correctLeft = 192 * scale;
        final double correctTop = 230 * scale;
        final double correctWidth = 120 * scale;
        final double correctHeight = 120 * scale;
        final double shakeIntensity = 27 * scale*.09;

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
                  _handleWrongAnswer();
                },
                child: Container(
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// العنصر الخطأ الأول
            Positioned(
              left: wrongLeft,
              top: wrongTop,
              child: GestureDetector(
                onTap: () {
                  _handleWrongAnswer();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Image.network(
                    firstElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                    width: wrongWidth,
                    height: wrongHeight,
                  ),
                ),
              ),
            ),

            /// العنصر الصحيح مع الحركة
            Positioned(
              left: correctLeft-7,
              top: correctTop,
              child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer) {
                    shakeValue = shakeIntensity *
                        sin(_animationController!.value * pi);
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
                    child: Image.network(
                      lastElement.imageUrl ?? '',
                      width: correctWidth,
                      height: correctHeight,
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
/*
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

 */