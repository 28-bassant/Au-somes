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

  // متغيرات للتوصيل (نقطة واحدة صحيحة + 8 نقاط خاطئة)
  List<bool> _connectedPoints = List.filled(9, false);
  Map<int, bool> _soundPlayed = {};

  // متغيرات للسحب
  int? _draggingPointIndex;
  Offset? _dragStartPosition;
  Offset? _dragCurrentPosition;
  bool _isDragging = false;
  bool _hasMoved = false; // لتتبع ما إذا كان المستخدم قد سحب بالفعل

  // متغيرات للخطوط
  bool _showLine4to1 = false;
  bool _showLine1to2 = false;
  bool _showLine2to4 = true;
  bool _isFirstCorrectClick = true;
  bool _isCompleted = false;

  // لتتبع عدد مرات الخطأ
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;

  // Animation
  AnimationController? _animationController;

  // GlobalKeys للنقاط (9 نقاط)
  final GlobalKey _anchorKey = GlobalKey();
  final List<GlobalKey> _pointKeys = List.generate(9, (index) => GlobalKey());

  final double _lineOffset = -75;

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

          for (int i = 0; i < 9; i++) {
            _soundPlayed[i] = false;
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

  // دالة للتعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    if (_isCompleted) return;

    setState(() {
      _wrongAttempts++;
    });

    // تشغيل صوت Try Again في كل مرة يخطئ فيها المستخدم
    TryAgainSound.play();

    // عند المحاولة الخاطئة الثانية، نهتز النقطة الصحيحة
    if (_wrongAttempts >= 2) {
      _startCorrectPointAnimation();
    }
  }

  // دالة لبدء حركة النقطة الصحيحة
  void _startCorrectPointAnimation() {
    if (!_isAnimatingAnswer && _animationController != null && !_connectedPoints[1]) {
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

  // دالة للتعامل مع الضغط على النقاط الخاطئة (كل النقاط ما عدا النقطة 1)
  void _handleWrongContainerTap(int index) {
    if (_isCompleted) return;
    if (index == 1) return; // النقطة الصحيحة لا نتعامل معها هنا
    _handleWrongAnswer();
  }

  void _handleCorrectContainerTap() {
    if (_isCompleted) return;

    if (_isFirstCorrectClick) {
      setState(() {
        _isFirstCorrectClick = false;
        _showLine4to1 = true;
        _wrongAttempts = 0; // إعادة تعيين عدد المحاولات الخاطئة
      });

      TrueAnswerSound.play();
    } else {
      setState(() {
        _isCompleted = true;
        _showLine1to2 = true;
        _showLine4to1 = true;
        _showLine2to4 = false;
        _wrongAttempts = 0;
      });

      TrueAnswerSound.play();
      WellDoneOverlay.show(context);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onNextStage?.call();
        }
      });
    }
  }

  Offset? _getPointTopPositionWithOffset(int index) {
    if (index >= _pointKeys.length) return null;
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
    if (index >= _pointKeys.length) return;

    final startPos = _getPointTopPositionWithOffset(index);
    if (startPos == null) return;

    setState(() {
      _draggingPointIndex = index;
      _dragStartPosition = startPos;
      _dragCurrentPosition = startPos;
      _isDragging = true;
      _hasMoved = false;
    });
  }

  void _onDragUpdate(Offset position) {
    if (_isDragging) {
      setState(() {
        _dragCurrentPosition = position;
        _hasMoved = true;
      });
    }
  }

  void _onDragEnd(Offset position) {
    if (!_isDragging || _draggingPointIndex == null) {
      _resetDrag();
      return;
    }

    // إذا لم يتحرك المستخدم (مجرد ضغط)، لا نفعل شيئاً
    if (!_hasMoved) {
      _resetDrag();
      return;
    }

    // حساب المسافة التي تم سحبها
    final dragDistance = (_dragStartPosition! - position).distance;

    // إذا كانت مسافة السحب أقل من 10 بكسل، نعتبرها ضغط وليس سحب حقيقي
    if (dragDistance < 10) {
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

      // إعادة تعيين عدد المحاولات الخاطئة عند النجاح
      setState(() {
        _wrongAttempts = 0;
      });
    } else {
      // سحب خاطئ - نفس معالجة الإجابة الخاطئة
      _handleWrongAnswer();
    }

    _resetDrag();
  }

  void _resetDrag() {
    setState(() {
      _draggingPointIndex = null;
      _dragStartPosition = null;
      _dragCurrentPosition = null;
      _isDragging = false;
      _hasMoved = false;
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

    // جميع النقاط (9 نقاط) - كلها خاطئة ما عدا النقطة 1
    final List<Offset> pointPositions = [
      Offset(screenWidth * 0.17, screenHeight * 0.53),   // 0 - خاطئة
      Offset(screenWidth * 0.7, screenHeight * 0.53),    // 1 - الصحيحة الوحيدة
      Offset(screenWidth * 0.45, screenHeight * 0.37),   // 2 - خاطئة
      Offset(screenWidth * 0.72, screenHeight * 0.37),   // 3 - خاطئة
      Offset(screenWidth * 0.45, screenHeight * 0.53),   // 4 - خاطئة
      Offset(screenWidth * 0.17, screenHeight * 0.18),   // 5 - خاطئة
      Offset(screenWidth * 0.45, screenHeight * 0.18),   // 6 - خاطئة
      Offset(screenWidth * 0.72, screenHeight * 0.18),   // 7 - خاطئة
      Offset(screenWidth * 0.17, screenHeight * 0.37),   // 8 - خاطئة
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
                showFixedLine2to0: true,
                showFixedLine0to4: true,
                showFixedLine2to4: _showLine2to4,
                showLine4to1: _showLine4to1,
                showLine1to2: _showLine1to2,
              ),
            ),

            // النقطة الصحيحة (index 1) مع Animation
            if (!_connectedPoints[1])
              Positioned(
                left: pointPositions[1].dx,
                top: pointPositions[1].dy,
                child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    double shakeValue = 0;
                    if (_isAnimatingAnswer) {
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

            // جميع النقاط الأخرى (0,2,3,4,5,6,7,8) - كلها خاطئة وقابلة للسحب والضغط
            for (int i = 0; i < 9; i++)
              if (i != 1 && !_connectedPoints[i])
                Positioned(
                  left: pointPositions[i].dx,
                  top: pointPositions[i].dy,
                  child: GestureDetector(
                    onTap: () => _handleWrongContainerTap(i),
                    onPanStart: (details) => _onDragStart(i, details.localPosition),
                    onPanUpdate: (details) => _onDragUpdate(details.globalPosition),
                    onPanEnd: (details) => _onDragEnd(_dragCurrentPosition ?? Offset.zero),
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
    if (index >= pointKeys.length) return null;
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

    // الخطوط الثابتة
    if (showFixedLine2to0) {
      Offset? point2Top = _getPointTopPositionWithOffset(2);
      Offset? point0Top = _getPointTopPositionWithOffset(0);
      if (point2Top != null && point0Top != null) {
        canvas.drawLine(point2Top, point0Top, fixedLinePaint);
      }
    }

    if (showFixedLine0to4) {
      Offset? point0Top = _getPointTopPositionWithOffset(0);
      Offset? point4Top = _getPointTopPositionWithOffset(4);
      if (point0Top != null && point4Top != null) {
        canvas.drawLine(point0Top, point4Top, fixedLinePaint);
      }
    }

    if (showFixedLine2to4) {
      Offset? point2Top = _getPointTopPositionWithOffset(2);
      Offset? point4Top = _getPointTopPositionWithOffset(4);
      if (point2Top != null && point4Top != null) {
        canvas.drawLine(point2Top, point4Top, fixedLinePaint);
      }
    }

    if (showLine4to1) {
      Offset? point4Top = _getPointTopPositionWithOffset(4);
      Offset? point1Top = _getPointTopPositionWithOffset(1);
      if (point4Top != null && point1Top != null) {
        canvas.drawLine(point4Top, point1Top, fixedLinePaint);
      }
    }

    if (showLine1to2) {
      Offset? point1Top = _getPointTopPositionWithOffset(1);
      Offset? point2Top = _getPointTopPositionWithOffset(2);
      if (point1Top != null && point2Top != null) {
        canvas.drawLine(point1Top, point2Top, fixedLinePaint);
      }
    }

    // خطوط التوصيل لجميع النقاط المتصلة
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
        }
      }
    }

    // خط السحب
    if (draggingLine != null) {
      final draggingPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(draggingLine!.start, draggingLine!.end, draggingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}