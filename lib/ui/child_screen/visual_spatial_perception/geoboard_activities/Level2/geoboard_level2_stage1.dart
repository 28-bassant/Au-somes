import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class GeoboardLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const GeoboardLevel2Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  GeoboardLevel2Stage1State createState() => GeoboardLevel2Stage1State();
}

class GeoboardLevel2Stage1State extends State<GeoboardLevel2Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  // متغيرات للتوصيل (5 نقاط)
  List<bool> _connectedPoints = List.filled(5, false);
  Map<int, bool> _soundPlayed = {};

  // متغيرات للسحب
  int? _draggingPointIndex;
  Offset? _dragStartPosition;
  Offset? _dragCurrentPosition;
  bool _isDragging = false;

  // متغيرات للخطوط (كلها ثابتة ولا تتغير)
  bool _showLine4to1 = false;        // خط بين 4 و 1 (يظهر بعد أول ضغطة)
  bool _showLine1to2 = false;// خط بين 1 و 2 (يظهر بعد الضغطة الثانية)
  bool _showLine2to4 = true;
  bool _isFirstCorrectClick = true;  // هل هذه أول ضغطة على الـ Container الصحيح
  bool _isCompleted = false;         // هل اكتملت المهمة

  // لتتبع عدد مرات الضغط على كل Container خاطئ
  Map<int, int> _wrongPressCount = {};

  // Animation للـ Container الصحيح
  AnimationController? _animationController;
  bool _isAnimatingCorrect = false;

  // GlobalKeys
  final GlobalKey _anchorKey = GlobalKey();
  final List<GlobalKey> _pointKeys = List.generate(5, (index) => GlobalKey());

  final double _lineOffset = -80;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.geoboard_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;

          for (int i = 0; i < 5; i++) {
            _soundPlayed[i] = false;
            _wrongPressCount[i] = 0;
          }
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

    final List<Future> precacheFutures = [];
    for (final url in images) {
      precacheFutures.add(precacheImage(NetworkImage(url!), context));
    }

    await Future.wait(precacheFutures);
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

  void repeatSound() {
    if (_dataLoaded && _imagesLoaded) {
      playSound();
    }
  }

  void _handleWrongContainerTap(int index) {
    if (_isCompleted) return;
    if (index == 1) return;

    int currentCount = _wrongPressCount[index] ?? 0;
    currentCount++;
    _wrongPressCount[index] = currentCount;

    if (currentCount == 1) {
      TryAgainSound.play();
    } else if (currentCount >= 2) {
      _startCorrectContainerAnimation();
    }
  }

  void _startCorrectContainerAnimation() {
    if (!_isAnimatingCorrect && _animationController != null) {
      setState(() {
        _isAnimatingCorrect = true;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingCorrect) {
          setState(() {
            _isAnimatingCorrect = false;
          });
          _animationController!.stop();
          _animationController!.value = 0;
        }
      });
    }
  }

  void _handleCorrectContainerTap() {
    if (_isCompleted) return;

    if (_isFirstCorrectClick) {
      setState(() {
        _isFirstCorrectClick = false;
        _showLine4to1 = true;
      });

      TrueAnswerSound.play(); // ✅ أول ضغطة
    } else {
      setState(() {
        _isCompleted = true;
        _showLine1to2 = true;
        _showLine4to1 = true;
        _showLine2to4 = false; // ✅ هنا بنشيله
      });

      TrueAnswerSound.play();
      WellDoneOverlay.show(context);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onNextStage?.call();
        }
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        TrueAnswerSound.play(); // ✅ نخليه بعد setState بشوية
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        WellDoneOverlay.show(context);
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onNextStage?.call();
        }
      });
    }
  }

  Offset? _getPointTopPositionWithOffset(int index) {
    final renderBox = _pointKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Offset(position.dx + size.width / 2, position.dy + _lineOffset);
  }

  Offset? _getAnchorTopPositionWithOffset() {
    final renderBox = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Offset(position.dx + size.width / 2, position.dy + _lineOffset);
  }

  bool _isOverAnchor(Offset position) {
    final anchorPos = _getAnchorTopPositionWithOffset();
    if (anchorPos == null) return false;
    final distance = (position - anchorPos).distance;
    return distance < 50;
  }

  void _onDragStart(int index, Offset position) {
    if (_connectedPoints[index] || _isCompleted) return;

    final startPos = _getPointTopPositionWithOffset(index);
    if (startPos == null) return;

    setState(() {
      _draggingPointIndex = index;
      _dragStartPosition = startPos;
      _dragCurrentPosition = startPos;
      _isDragging = true;
    });
  }

  void _onDragUpdate(Offset position) {
    if (_isDragging) {
      setState(() {
        _dragCurrentPosition = position;
      });
    }
  }

  void _onDragEnd(Offset position) {
    if (!_isDragging || _draggingPointIndex == null) {
      _resetDrag();
      return;
    }

    if (_isOverAnchor(position) && !_connectedPoints[_draggingPointIndex!]) {
      setState(() {
        _connectedPoints[_draggingPointIndex!] = true;
      });

      if (!_soundPlayed[_draggingPointIndex!]!) {
        _soundPlayed[_draggingPointIndex!] = true;
        TrueAnswerSound.play();
      }
    } else {
      TryAgainSound.play();
    }

    _resetDrag();
  }

  void _resetDrag() {
    setState(() {
      _draggingPointIndex = null;
      _dragStartPosition = null;
      _dragCurrentPosition = null;
      _isDragging = false;
    });
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

    final elements = _activity!.elements!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final anchorElement = elements[1];
    final double pointSize = screenWidth * 0.12;

    final List<Offset> pointPositions = [
      Offset(screenWidth * 0.17, screenHeight * 0.53),   // 0
      Offset(screenWidth * 0.7, screenHeight * 0.53),    // 1: الزاوية السفلى اليمنى (الصحيح)
      Offset(screenWidth * 0.45, screenHeight * 0.37),   // 2
      Offset(screenWidth * 0.72, screenHeight * 0.37),   // 3
      Offset(screenWidth * 0.45, screenHeight * 0.53),   // 4
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                key: _anchorKey,
                width: screenWidth * 0.9,
                height: screenWidth * 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    anchorElement.imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: ConnectionPainter(
                connections: _connectedPoints,
                anchorKey: _anchorKey,
                pointKeys: _pointKeys,
                draggingLine: _isDragging && _dragStartPosition != null && _dragCurrentPosition != null
                    ? DraggingLine(
                  start: _dragStartPosition!,
                  end: _dragCurrentPosition!,
                )
                    : null,
                lineOffset: _lineOffset,
                showFixedLine2to0: true,      // خط ثابت بين 2 و 0 (يظهر دائماً)
                showFixedLine0to4: true,      // خط ثابت بين 0 و 4 (يظهر دائماً)
                showFixedLine2to4: _showLine2to4,
                showLine4to1: _showLine4to1,  // خط بين 4 و 1 (يظهر بعد أول ضغطة)
                showLine1to2: _showLine1to2,  // خط بين 1 و 2 (يظهر بعد الضغطة الثانية)
              ),
            ),

            // الـ Container الصحيح (index 1) مع Animation
            if (!_connectedPoints[1])
              Positioned(
                left: pointPositions[1].dx,
                top: pointPositions[1].dy,
                child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    double shakeValue = 0;
                    if (_isAnimatingCorrect) {
                      shakeValue = 20 * sin(_animationController!.value * 3.14159);
                    }
                    return Transform.translate(
                      offset: Offset(shakeValue, 0),
                      child: GestureDetector(
                        onTap: _handleCorrectContainerTap,
                        child: Container(
                          key: _pointKeys[1],
                          width: pointSize,
                          height: pointSize,
                          child: Center(
                            child: Icon(
                              Icons.circle,
                              color: AppColors.lightPastelBlue,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // باقي الـ Containers (غير الصحيح)
            for (int i = 0; i < 5; i++)
              if (i != 1 && !_connectedPoints[i])
                Positioned(
                  left: pointPositions[i].dx,
                  top: pointPositions[i].dy,
                  child: GestureDetector(
                    onTap: () => _handleWrongContainerTap(i),
                    child: Container(
                      key: _pointKeys[i],
                      width: pointSize,
                      height: pointSize,
                      child: Center(
                        child: Icon(
                          Icons.circle,
                          color: AppColors.lightPastelBlue,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class DraggingLine {
  final Offset start;
  final Offset end;
  DraggingLine({required this.start, required this.end});
}

class ConnectionPainter extends CustomPainter {
  final List<bool> connections;
  final GlobalKey anchorKey;
  final List<GlobalKey> pointKeys;
  final DraggingLine? draggingLine;
  final double lineOffset;
  final bool showFixedLine2to0;
  final bool showFixedLine0to4;
  final bool showFixedLine2to4;
  final bool showLine4to1;
  final bool showLine1to2;

  ConnectionPainter({
    required this.connections,
    required this.anchorKey,
    required this.pointKeys,
    this.draggingLine,
    required this.lineOffset,
    required this.showFixedLine2to0,
    required this.showFixedLine0to4,
    required this.showFixedLine2to4,
    required this.showLine4to1,
    required this.showLine1to2,
  });

  Offset? _getPointTopPositionWithOffset(int index) {
    final renderBox = pointKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Offset(position.dx + size.width / 2, position.dy + lineOffset);
  }

  Offset? _getAnchorTopPositionWithOffset() {
    final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Offset(position.dx + size.width / 2, position.dy + lineOffset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fixedLinePaint = Paint()
      ..color = AppColors.lightPastelBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // الخط الثابت بين 2 و 0 (يظهر دائماً)
    if (showFixedLine2to0) {
      Offset? point2Top = _getPointTopPositionWithOffset(2);
      Offset? point0Top = _getPointTopPositionWithOffset(0);
      if (point2Top != null && point0Top != null) {
        canvas.drawLine(point2Top, point0Top, fixedLinePaint);
        final circlePaint = Paint()
          ..color = AppColors.lightPastelBlue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point2Top, 4, circlePaint);
        canvas.drawCircle(point0Top, 4, circlePaint);
      }
    }

    // الخط الثابت بين 0 و 4 (يظهر دائماً)
    if (showFixedLine0to4) {
      Offset? point0Top = _getPointTopPositionWithOffset(0);
      Offset? point4Top = _getPointTopPositionWithOffset(4);
      if (point0Top != null && point4Top != null) {
        canvas.drawLine(point0Top, point4Top, fixedLinePaint);
        final circlePaint = Paint()
          ..color = AppColors.lightPastelBlue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point0Top, 4, circlePaint);
        canvas.drawCircle(point4Top, 4, circlePaint);
      }
    }

    // الخط الثابت بين 2 و 4 (يظهر دائماً)
    if (showFixedLine2to4) {
      Offset? point2Top = _getPointTopPositionWithOffset(2);
      Offset? point4Top = _getPointTopPositionWithOffset(4);
      if (point2Top != null && point4Top != null) {
        canvas.drawLine(point2Top, point4Top, fixedLinePaint);
        final circlePaint = Paint()
          ..color = AppColors.lightPastelBlue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point2Top, 4, circlePaint);
        canvas.drawCircle(point4Top, 4, circlePaint);
      }
    }

    // خط بين 4 و 1 (يظهر بعد أول ضغطة)
    // خط بين 4 و 1 (يظهر بعد أول ضغطة)
    if (showLine4to1) {
      Offset? point4Top = _getPointTopPositionWithOffset(4);
      Offset? point1Top = _getPointTopPositionWithOffset(1);
      if (point4Top != null && point1Top != null) {
        canvas.drawLine(point4Top, point1Top, fixedLinePaint);
        final circlePaint = Paint()
          ..color = AppColors.lightPastelBlue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point4Top, 4, circlePaint);
        canvas.drawCircle(point1Top, 4, circlePaint);
      }
    }

    // خط بين 1 و 2 (يظهر بعد الضغطة الثانية)
    if (showLine1to2) {
      Offset? point1Top = _getPointTopPositionWithOffset(1);
      Offset? point2Top = _getPointTopPositionWithOffset(2);
      if (point1Top != null && point2Top != null) {
        canvas.drawLine(point1Top, point2Top, fixedLinePaint);
        final circlePaint = Paint()
          ..color = AppColors.lightPastelBlue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point1Top, 4, circlePaint);
        canvas.drawCircle(point2Top, 4, circlePaint);
      }
    }

    // خطوط التوصيل الديناميكية
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < connections.length; i++) {
      if (connections[i]) {
        final pointTop = _getPointTopPositionWithOffset(i);
        final anchorTop = _getAnchorTopPositionWithOffset();
        if (pointTop != null && anchorTop != null) {
          canvas.drawLine(pointTop, anchorTop, paint);
          final greenCirclePaint = Paint()
            ..color = Colors.green
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pointTop, 6, greenCirclePaint);
          canvas.drawCircle(anchorTop, 6, greenCirclePaint);
        }
      }
    }

    if (draggingLine != null) {
      final draggingPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(draggingLine!.start, draggingLine!.end, draggingPaint);
      final orangeCirclePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      canvas.drawCircle(draggingLine!.start, 6, orangeCirclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

