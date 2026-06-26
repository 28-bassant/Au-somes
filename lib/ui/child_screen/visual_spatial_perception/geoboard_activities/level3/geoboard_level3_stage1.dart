import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class GeoboardLevel3Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const GeoboardLevel3Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  GeoboardLevel3Stage1State createState() =>
      GeoboardLevel3Stage1State();
}

class Line {
  final int start;
  final int end;
  Line(this.start, this.end);
}

Offset getCirclePosition(Size size, int index) {
  switch (index) {
    case 0:
      return Offset(size.width * 0.46, size.height * 0.125);
    case 1:
      return Offset(size.width * 0.79, size.height * 0.45);
    case 2:
      return Offset(size.width * 0.46, size.height * 0.45);
    case 3:
      return Offset(size.width * 0.79, size.height * 0.78);
    case 4:
      return Offset(size.width * 0.46, size.height * 0.78);
    default:
      return Offset.zero;
  }
}

class GeoboardLevel3Stage1State extends State<GeoboardLevel3Stage1>
    with SingleTickerProviderStateMixin {

  late AudioPlayer _player;

  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  final GlobalKey _anchorKey = GlobalKey();

  // ✅ مهم
  final List<GlobalKey> _circleKeys =
  List.generate(5, (_) => GlobalKey());

  // ✅ مهم
  final GlobalKey _stackKey = GlobalKey();

  Map<int, int> _circleWrongPressCount = {};
  List<Line> _lines = [];

  int _currentStageIndex = 0;
  bool _isCompleted = false;

  AnimationController? _circleAnimationController;
  bool _isAnimatingCircle = false;
  int? _shakingIndex;

  final List<Map<String, int>> stages = [
    {'tap': 0, 'lineTo': 1},
    {'tap': 1, 'lineTo': 2},
    {'tap': 1, 'lineTo': 3},
    {'tap': 3, 'lineTo': 4},
  ];
  bool _usedHint = false;
  bool _progressLocked = false;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _circleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    for (int i = 0; i < 5; i++) {
      _circleWrongPressCount[i] = 0;
    }

    _loadActivity();
  }

  @override
  void dispose() {
    _player.dispose();
    _circleAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.geoboard_activityId,
        3,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;
        });

        await _preloadImages(activity);

        setState(() {
          _imagesLoaded = true;
        });

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
          _dataLoaded = true;
          _imagesLoaded = true;
        });
      }
    }
  }

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    await Future.wait(
      images.map((url) => precacheImage(NetworkImage(url!), context)),
    );
  }

  Future<void> playSound() async {
    if (!_dataLoaded || !_imagesLoaded) return;
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    await _player.stop();
    await _player.play(UrlSource(_activity!.audioUrl!));
  }

  void _handleCircleTap(int index) {
    if (_isCompleted) return;
    if (_progressLocked) return;

    final stage = stages[_currentStageIndex];
    final correctIndex = stage['tap']!;
    final nextIndex = stage['lineTo']!;

    if (index != correctIndex) {
      int count = _circleWrongPressCount[index] ?? 0;
      count++;
      _circleWrongPressCount[index] = count;

      _usedHint = true;

      if (count == 1) {
        TryAgainSound.play();
      } else if (count >= 2) {
        _startCircleAnimation(correctIndex);
      }
      return;
    }

    setState(() {
      _lines.add(Line(correctIndex, nextIndex));
      _currentStageIndex++;
    });

    TrueAnswerSound.play();

    // ⭐ هنا المهم: لما يخلص كل الستيجز
    if (_currentStageIndex >= stages.length) {
      _completeLevel();
    }
  }
  Future<void> _completeLevel() async {
    if (_progressLocked) return;

    setState(() {
      _progressLocked = true;
      _isCompleted = true;
      _isAnimatingCircle = false;
    });

    _circleAnimationController?.stop();
    _circleAnimationController?.value = 0;

    await _logProgress();

    WellDoneOverlay.show(context);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onNextStage?.call();
      }
    });
  }
  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
      }
    } catch (e) {
      print("Progress error: $e");
    }
  }

  void _startCircleAnimation(int index) {
    if (!_isAnimatingCircle) {
      setState(() {
        _isAnimatingCircle = true;
        _shakingIndex = index;
      });

      _circleAnimationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isAnimatingCircle = false;
            _shakingIndex = null;
          });
          _circleAnimationController!.stop();
          _circleAnimationController!.value = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final anchorImageUrl =
    (_activity?.elements != null && _activity!.elements!.isNotEmpty)
        ? _activity!.elements!.first.imageUrl ?? ''
        : '';

    final boardSize = screenWidth * 0.9;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Stack(
              key: _stackKey, // ✅ مهم
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    anchorImageUrl,
                    fit: BoxFit.contain,
                  ),
                ),

                CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: CircleConnectionPainter(
                    circleKeys: _circleKeys,
                    stackKey: _stackKey,
                    lines: _lines,
                  ),
                ),

                ...List.generate(5, (index) {
                  Offset pos =
                  getCirclePosition(Size(boardSize, boardSize), index);

                  return Positioned(
                    left: pos.dx,
                    top: pos.dy,
                    child: AnimatedBuilder(
                      animation: _circleAnimationController!,
                      builder: (context, child) {
                        double shakeValue = 0;

                        if (_isAnimatingCircle &&
                            index == _shakingIndex) {
                          shakeValue = 10 *
                              sin(_circleAnimationController!.value * pi);
                        }

                        return Transform.translate(
                          offset: Offset(shakeValue, 0),
                          child: GestureDetector(
                            onTap: () => _handleCircleTap(index),
                            child: Container(
                              key: _circleKeys[index], // ✅ مهم
                              width: 27,
                              height: 23,
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= Painter =================

class CircleConnectionPainter extends CustomPainter {
  final List<GlobalKey> circleKeys;
  final GlobalKey stackKey;
  final List<Line> lines;

  CircleConnectionPainter({
    required this.circleKeys,
    required this.stackKey,
    required this.lines,
  });

  Offset? _getCircleCenter(int index) {
    final circleBox =
    circleKeys[index].currentContext?.findRenderObject() as RenderBox?;

    final stackBox =
    stackKey.currentContext?.findRenderObject() as RenderBox?;

    if (circleBox == null || stackBox == null) return null;

    final globalCenter =
    circleBox.localToGlobal(circleBox.size.center(Offset.zero));

    return stackBox.globalToLocal(globalCenter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      final start = _getCircleCenter(line.start);
      final end = _getCircleCenter(line.end);

      if (start != null && end != null) {
        final paint = Paint()
          ..color = (i == 0) ? Colors.red : Colors.blue
          ..strokeWidth = 3;

        canvas.drawLine(start, end, paint);
        canvas.drawCircle(start, 4, paint);
        canvas.drawCircle(end, 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}