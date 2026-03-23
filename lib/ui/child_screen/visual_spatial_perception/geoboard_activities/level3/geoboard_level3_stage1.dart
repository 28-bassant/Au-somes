import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

class GeoboardLevel3Stage1State extends State<GeoboardLevel3Stage1>
    with SingleTickerProviderStateMixin {

  late AudioPlayer _player;

  // 🔥 API DATA
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  final GlobalKey _anchorKey = GlobalKey();
  final List<GlobalKey> _circleKeys =
  List.generate(5, (_) => GlobalKey());

  Map<int, int> _circleWrongPressCount = {};
  List<Line> _lines = [];

  int _currentStageIndex = 0;
  bool _isCompleted = false;

  AnimationController? _circleAnimationController;
  bool _isAnimatingCircle = false;
  int? _shakingIndex;

  // المراحل
  final List<Map<String, int>> stages = [
    {'tap': 0, 'lineTo': 1},
    {'tap': 1, 'lineTo': 2},
    {'tap': 1, 'lineTo': 3},
    {'tap': 3, 'lineTo': 4},
  ];

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

    // تحديث حالة الدوائر بعد أول رسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    _loadActivity();

  }

  @override
  void dispose() {
    _player.dispose();
    _circleAnimationController?.dispose();
    super.dispose();
  }

  // ================= API =================

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
      print('Error loading activity: $e');
    }
  }

  Future<void> _preloadImages(ActivityResponse activity) async {
    final images = activity.elements!
        .map((e) => e.imageUrl)
        .where((url) => url != null && url!.isNotEmpty)
        .toList();

    final List<Future> futures = [];

    for (final url in images) {
      futures.add(precacheImage(NetworkImage(url!), context));
    }

    await Future.wait(futures);
  }

  Future<void> playSound() async {
    if (!_dataLoaded || !_imagesLoaded) return;
    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    try {
      await _player.stop();
      await _player.play(UrlSource(_activity!.audioUrl!));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // ================= GAME =================

  void _handleCircleTap(int index) {
    if (_isCompleted || _currentStageIndex >= stages.length) return;

    final stage = stages[_currentStageIndex];
    final correctIndex = stage['tap']!;
    final nextIndex = stage['lineTo']!;

    if (index != correctIndex) {
      int count = _circleWrongPressCount[index] ?? 0;
      count++;
      _circleWrongPressCount[index] = count;

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

    if (_currentStageIndex >= stages.length) {
      _isCompleted = true;
      WellDoneOverlay.show(context);Future.delayed(const Duration(seconds: 3), () {
        widget.onNextStage?.call();
      });
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

  Offset _getCirclePosition(int index) {
    final renderBox =
    _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;

    final size = renderBox.size;

    switch (index) {
      case 0:
        return Offset(size.width * 0.518, size.height * 0.56);
      case 1:
        return Offset(size.width * 0.85, size.height * 0.88);
      case 2:
        return Offset(size.width * 0.51, size.height * 0.88);
      case 3:
        return Offset(size.width * 0.856, size.height * 1.2);
      case 4:
        return Offset(size.width * 0.51, size.height * 1.2);
      default:
        return Offset.zero;
    }
  }

  // ================= UI =================

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

    return Scaffold(
      body: SafeArea(
      child: Center(
      child: Stack(
      children: [
    // Anchor
    Center(
    child: Container(
    key: _anchorKey,
      width: screenWidth * 0.9,
      height: screenWidth * 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:Image.network(
          anchorImageUrl,
          fit: BoxFit.contain,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            }
            return child;
          },
        )
      ),
    ),
    ),

    // Lines
    CustomPaint(
    size: Size(screenWidth, screenWidth),
    painter: CircleConnectionPainter(
    circleKeys: _circleKeys,
    lines: _lines,
    ),
    ),

    // Circles
    Positioned.fill(
    child: Stack(
    children: List.generate(5, (index) {
    Offset pos = _getCirclePosition(index);

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
    key: _circleKeys[index],
    width: 27,
    height: 23,
    decoration: const BoxDecoration(color: Colors.yellow,
      shape: BoxShape.circle,
    ),
    ),
    ),
    );
    },
    ),
    );
    }),
    ),
    ),
      ],
      ),
      ),
      ),
    );
  }
}

// ================= Painter =================

class CircleConnectionPainter extends CustomPainter {
  final List<GlobalKey> circleKeys;
  final List<Line> lines;

  CircleConnectionPainter({
    required this.circleKeys,
    required this.lines,
  });

  Offset? _getCircleCenter(int index) {
    final renderBox =
    circleKeys[index].currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return null;

    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Offset(
      pos.dx + size.width / 2,
      pos.dy + size.height / 2 - 117,
    );
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
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

        canvas.drawLine(start, end, paint);

        canvas.drawCircle(start, 4, paint..style = PaintingStyle.fill);
        canvas.drawCircle(end, 4, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ================= Dummy =================

class TryAgainSound {
  static void play() => print('Try Again Sound');
}

class TrueAnswerSound {
  static void play() => print('True Answer Sound');
}

class WellDoneOverlay {
  static void show(BuildContext context) => print('Well Done!');
}

