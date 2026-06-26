import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class MentalCuttingLevel3Stage3 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const MentalCuttingLevel3Stage3({Key? key, this.onNextStage}) : super(key: key);

  @override
  MentalCuttingLevel3Stage3State createState() => MentalCuttingLevel3Stage3State();
}

class MentalCuttingLevel3Stage3State extends State<MentalCuttingLevel3Stage3>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  // قائمة لتتبع الـ Anchors التي تم توصيلها
  Map<String, bool> _connectedAnchors = {};
  Map<String, String?> _anchorImages = {};
  Map<String, String?> _actorImages = {};
  Map<String, String?> _actorTargetAnchor = {}; // الـ Anchor المستهدف لكل Actor

  // لتتبع الأصوات التي تم تشغيلها لكل Anchor
  Map<String, bool> _soundPlayed = {};

  // التوصيلات (Actor -> Anchor)
  Map<String, String> _connections = {};

  // متغيرات للسحب
  String? _draggingActorId;
  Offset? _dragStartPosition;
  Offset? _dragCurrentPosition;
  bool _isDragging = false;

  // تخزين مواضع الخطوط الثابتة
  Map<String, Offset> _connectionStartPositions = {};
  Map<String, Offset> _connectionEndPositions = {};

  // GlobalKeys للحصول على المواضع
  final Map<String, GlobalKey> _actorKeys = {};
  final Map<String, GlobalKey> _anchorKeys = {};
  bool _usedHint = false;
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await ApiManager.getActivity(
        ApiConstants.mental_cutting_activityId,
        3,
        3,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;

          final elements = activity.elements!;

          // تجهيز Anchors و Actors
          for (var element in elements) {
            if (element.role == 'Anchor') {
              _connectedAnchors[element.id!] = false;
              _anchorImages[element.id!] = element.imageUrl;
              _anchorKeys[element.id!] = GlobalKey();
              _soundPlayed[element.id!] = false;
            } else if (element.role == 'Actor') {
              _actorImages[element.id!] = element.imageUrl;
              _actorTargetAnchor[element.id!] = element.targetedZoneId;
              _actorKeys[element.id!] = GlobalKey();
            }
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

  // الحصول على موضع فوق صورة الـ Actor بالضبط (منتصف الحافة العلوية)
  Offset? _getActorTopPosition(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    // منتصف الحافة العلوية للصورة
    return Offset(position.dx + size.width / 2, position.dy);
  }

  // الحصول على موضع فوق صورة الـ Anchor بالضبط (منتصف الحافة العلوية)
  Offset? _getAnchorTopPosition(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    // منتصف الحافة العلوية للصورة
    return Offset(position.dx + size.width / 2, position.dy);
  }

  // التحقق مما إذا كان الـ Actor قد وصل إلى Anchor
  String? _getAnchorAtPosition(Offset position) {
    for (var entry in _anchorKeys.entries) {
      final anchorId = entry.key;
      if (_connectedAnchors[anchorId] == true) continue;

      final renderBox = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final anchorPosition = renderBox.localToGlobal(Offset.zero);
      final anchorSize = renderBox.size;
      final anchorRect = Rect.fromLTWH(
        anchorPosition.dx,
        anchorPosition.dy,
        anchorSize.width,
        anchorSize.height,
      );

      if (anchorRect.contains(position)) {
        return anchorId;
      }
    }
    return null;
  }

  // بدء السحب
  void _onDragStart(String actorId, Offset position) {
    if (_connections.containsKey(actorId)) return;

    // الحصول على موضع فوق الـ Actor بالضبط
    final startPos = _getActorTopPosition(_actorKeys[actorId]!);
    if (startPos == null) return;

    setState(() {
      _draggingActorId = actorId;
      _dragStartPosition = startPos;
      _dragCurrentPosition = startPos;
      _isDragging = true;
    });
  }

  // أثناء السحب
  void _onDragUpdate(Offset position) {
    if (_isDragging) {
      setState(() {
        _dragCurrentPosition = position;
      });
    }
  }

  // إنهاء السحب
  Future<void> _onDragEnd(Offset position) async {
    if (!_isDragging || _draggingActorId == null) {
      _resetDrag();
      return;
    }

    // الحصول على الـ Anchor الذي انتهى عنده السحب
    final targetAnchorId = _getAnchorAtPosition(position);
    final expectedAnchorId = _actorTargetAnchor[_draggingActorId];

    if (targetAnchorId != null && targetAnchorId == expectedAnchorId && !_connectedAnchors[targetAnchorId]!) {
      // إجابة صحيحة
      final startPos = _getActorTopPosition(_actorKeys[_draggingActorId!]!);
      final endPos = _getAnchorTopPosition(_anchorKeys[targetAnchorId]!);

      setState(() {
        _connections[_draggingActorId!] = targetAnchorId;
        _connectedAnchors[targetAnchorId] = true;
        if (startPos != null) _connectionStartPositions[_draggingActorId!] = startPos;
        if (endPos != null) _connectionEndPositions[targetAnchorId] = endPos;
      });

      // تشغيل صوت الإجابة الصحيحة إذا لم يتم تشغيله من قبل لهذا الـ Anchor
      if (!_soundPlayed[targetAnchorId]!) {
        _soundPlayed[targetAnchorId] = true;
        TrueAnswerSound.play();
      }

      // التحقق من اكتمال جميع التوصيلات
      bool allConnected =
      _connectedAnchors.values.every((connected) => connected == true);

      if (allConnected) {
        await _logProgress();

        WellDoneOverlay.show(context);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
      }
    } else if (targetAnchorId != null) {
      setState(() {
        _usedHint = true;
      });

      TryAgainSound.play();
    }

    _resetDrag();
  }

  void _resetDrag() {
    setState(() {
      _draggingActorId = null;
      _dragStartPosition = null;
      _dragCurrentPosition = null;
      _isDragging = false;
    });
  }
  Future<void> _logProgress() async {
    try {
      final result = await ApiManager.logAttemptStatus(
        phaseId: _activity!.phaseId!,
        userHint: _usedHint,
      );

      print("PhaseId = ${_activity!.phaseId}");
      print("RESULT = ${result?.isPassed}");

      if (result?.isPassed == true) {
        await ApiManager.getProgressSummary();
      }
    } catch (e) {
      print("Progress error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
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

    // الحصول على Anchors و Actors
    final anchors = elements.where((e) => e.role == 'Anchor').toList();
    final actors = elements.where((e) => e.role == 'Actor').toList();

    // عكس ترتيب الـ Anchors (اللي تحت يصبح فوق واللي فوق يصبح تحت)
    final reversedAnchors = List.from(anchors.reversed);

    final double itemSize = screenWidth * 0.25;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // رسم خطوط التوصيل الثابتة والخط أثناء السحب
            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: ConnectionPainter(
                connections: _connections,
                connectionStartPositions: _connectionStartPositions,
                connectionEndPositions: _connectionEndPositions,
                draggingLine: _isDragging && _dragStartPosition != null && _dragCurrentPosition != null
                    ? DraggingLine(
                  start: _dragStartPosition!,
                  end: _dragCurrentPosition!,
                )
                    : null,
                actorKeys: _actorKeys,
                anchorKeys: _anchorKeys,
              ),
            ),

            // المحتوى الرئيسي
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الـ Actors على اليسار (فوق بعض)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: actors.map((actor) {
                        final isConnected = _connections.containsKey(actor.id);

                        return Listener(
                          onPointerDown: (event) {
                            if (!isConnected) {
                              final renderBox = _actorKeys[actor.id]?.currentContext?.findRenderObject() as RenderBox?;
                              if (renderBox != null) {
                                final position = renderBox.localToGlobal(Offset.zero);
                                final size = renderBox.size;
                                // نقطة البداية فوق الصورة بالضبط
                                final startPoint = Offset(position.dx + size.width / 2, position.dy);
                                _onDragStart(actor.id!, startPoint);
                              }
                            }
                          },
                          onPointerMove: (event) {
                            if (_isDragging) {
                              _onDragUpdate(event.position);
                            }
                          },
                          onPointerUp: (event) {
                            if (_isDragging) {
                              _onDragEnd(event.position);
                            }
                          },
                          child: Container(
                            key: _actorKeys[actor.id!],
                            margin: const EdgeInsets.symmetric(vertical: 40),
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Opacity(
                              opacity: isConnected ? 0.5 : 1.0,
                              child: Image.network(
                                actor.imageUrl ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // الـ Anchors على اليمين (فوق بعض) - بترتيب معكوس
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: reversedAnchors.map((anchor) {
                        final isConnected = _connectedAnchors[anchor.id!] == true;

                        return Container(
                          key: _anchorKeys[anchor.id!],
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          width: itemSize,
                          height: itemSize,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              anchor.imageUrl ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// كلاس لبيانات الخط أثناء السحب
class DraggingLine {
  final Offset start;
  final Offset end;

  DraggingLine({required this.start, required this.end});
}

// كلاس لرسم خطوط التوصيل
class ConnectionPainter extends CustomPainter {
  final Map<String, String> connections;
  final Map<String, Offset> connectionStartPositions;
  final Map<String, Offset> connectionEndPositions;
  final DraggingLine? draggingLine;
  final Map<String, GlobalKey> actorKeys;
  final Map<String, GlobalKey> anchorKeys;

  ConnectionPainter({
    required this.connections,
    required this.connectionStartPositions,
    required this.connectionEndPositions,
    this.draggingLine,
    required this.actorKeys,
    required this.anchorKeys,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // رسم الخطوط للتوصيلات الثابتة
    for (var entry in connections.entries) {
      final actorId = entry.key;
      final anchorId = entry.value;

      // محاولة الحصول على الموضع المخزن أولاً
      Offset? actorPos = connectionStartPositions[actorId];
      Offset? anchorPos = connectionEndPositions[anchorId];

      // إذا لم يكن هناك موضع مخزن، نحسبه من الـ GlobalKey
      if (actorPos == null) {
        final actorRenderBox = actorKeys[actorId]?.currentContext?.findRenderObject() as RenderBox?;
        if (actorRenderBox != null) {
          final position = actorRenderBox.localToGlobal(Offset.zero);
          final size = actorRenderBox.size;
          // منتصف الحافة العلوية للصورة
          actorPos = Offset(position.dx + size.width / 2, position.dy);
        }
      }

      if (anchorPos == null) {
        final anchorRenderBox = anchorKeys[anchorId]?.currentContext?.findRenderObject() as RenderBox?;
        if (anchorRenderBox != null) {
          final position = anchorRenderBox.localToGlobal(Offset.zero);
          final size = anchorRenderBox.size;
          // منتصف الحافة العلوية للصورة
          anchorPos = Offset(position.dx + size.width / 2, position.dy);
        }
      }

      if (actorPos != null && anchorPos != null) {
        // رسم الخط
        canvas.drawLine(actorPos, anchorPos, paint);

        // رسم دائرة في بداية الخط ونهايته
        final circlePaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill;
        canvas.drawCircle(actorPos, 6, circlePaint);
        canvas.drawCircle(anchorPos, 6, circlePaint);
      }
    }

    // رسم الخط أثناء السحب
    if (draggingLine != null) {
      final draggingPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      canvas.drawLine(draggingLine!.start, draggingLine!.end, draggingPaint);

      // رسم دائرة في بداية الخط
      final circlePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      canvas.drawCircle(draggingLine!.start, 6, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}