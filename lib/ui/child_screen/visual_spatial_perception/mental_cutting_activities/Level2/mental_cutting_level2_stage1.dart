import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class MentalCuttingLevel2Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const MentalCuttingLevel2Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  MentalCuttingLevel2Stage1State createState() => MentalCuttingLevel2Stage1State();
}

class MentalCuttingLevel2Stage1State extends State<MentalCuttingLevel2Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  // متغيرات للتحكم في الـ Container الفارغ
  bool _containerFilled = false; // هل تم ملء الـ Container أم لا
  String? _correctActorImageUrl; // صورة الـ Actor الصحيح
  String? _correctActorId; // ID الـ Actor الصحيح

  // متغيرات للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;

  // GlobalKey للـ Container
  final GlobalKey _containerKey = GlobalKey();

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
        ApiConstants.mental_cutting_activityId,
        2,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;

          // تعيين صورة Actor الصحيح
          final correctActor = activity.elements!
              .firstWhere((e) => e.isCorrect == true);
          _correctActorImageUrl = correctActor.imageUrl;
          _correctActorId = correctActor.id;
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
    print('All images preloaded successfully');
  }

  Future<void> playSound() async {
    if (!_dataLoaded || !_imagesLoaded) {
      print('Waiting for data and images to load before playing sound');
      return;
    }

    if (_activity?.audioUrl == null || _activity!.audioUrl!.isEmpty) return;

    try {
      await _player.stop();
      await _player.play(UrlSource(_activity!.audioUrl!));
      print('Sound played successfully');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void repeatSound() {
    if (_dataLoaded && _imagesLoaded) {
      playSound();
    }
  }

  // دالة للتعامل مع الإجابة الخاطئة (سحب Actor خاطئ)
  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    // تشغيل صوت Try Again
    TryAgainSound.play();

    if (_wrongAttempts >= 2) {
      // تحريك الإجابة الصحيحة بعد المحاولات الخاطئة
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

  // دالة للتحقق من أن الـ Actor قد وقع داخل الـ Container
  bool _isOverContainer(DraggableDetails details, double actorSize) {
    final renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    final containerPosition = renderBox.localToGlobal(Offset.zero);
    final containerSize = renderBox.size;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );

    final containerRect = Rect.fromLTWH(
      containerPosition.dx,
      containerPosition.dy,
      containerSize.width,
      containerSize.height,
    );

    return containerRect.contains(actorCenter);
  }

  // دالة للتعامل مع الإجابة الصحيحة (سحب Actor الصحيح إلى الـ Container)
  void _handleCorrectActor(DraggableDetails details, double actorSize) {
    if (_containerFilled) return;

    // نتحقق إذا كان الـ Actor قد وقع داخل الـ Container
    if (_isOverContainer(details, actorSize)) {
      setState(() {
        _containerFilled = true;
        _wrongAttempts = 0;
        _isAnimatingAnswer = false;
      });

      _animationController?.stop();
      _animationController?.value = 0;

      // إظهار WellDoneOverlay بعد ملء الـ Container
      WellDoneOverlay.show(context);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onNextStage?.call();
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

    final elements = _activity!.elements!;

    // الحصول على العناصر
    final anchorElement = elements.firstWhere((e) => e.role == 'Anchor');
    final correctActor = elements.firstWhere((e) => e.isCorrect == true);
    final wrongActors = elements.where((e) =>
    e.role == 'Actor' && e.isCorrect == false).toList();

    final double actorSize = MediaQuery.of(context).size.width * 0.3;
    final double anchorSize = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container العلوي: Anchor و Container فارغ
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Anchor
                    Container(
                      width: anchorSize * 0.5,
                      height: anchorSize,
                      child: Image.network(
                        anchorElement.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Container فارغ أو Actor الصحيح بعد السحب
                    Container(
                      key: _containerKey,
                      width: anchorSize * 0.5,
                      height: anchorSize,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.black, width: 2),
                      //   borderRadius: BorderRadius.circular(8),
                      //   color: _containerFilled ? Colors.transparent : Colors.grey[200],
                      // ),
                      child: _containerFilled
                          ? Image.network(
                        _correctActorImageUrl ?? '',
                        fit: BoxFit.contain,
                      )
                          : Container()
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // جميع الـ Actors تحت بعض (كلهم Draggable)
              // Actor الصحيح (Draggable) - يختفي بعد السحب
              if (!_containerFilled)
                AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    double shakeValue = 0;
                    if (_isAnimatingAnswer && !_containerFilled) {
                      shakeValue = 20 * sin(_animationController!.value * 3.14159);
                    }
                    return Transform.translate(
                      offset: Offset(shakeValue, 0),
                      child: child,
                    );
                  },
                  child: Draggable<String>(
                    data: correctActor.id!,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: actorSize,
                        height: actorSize,
                        child: Image.network(
                          correctActor.imageUrl ?? '',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    childWhenDragging: const SizedBox.shrink(), // إزالة المربع الرمادي
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: actorSize,
                      height: actorSize,
                      child: Image.network(
                        correctActor.imageUrl ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    onDragEnd: (details) {
                      _handleCorrectActor(details, actorSize);
                    },
                  ),
                ),

              // باقي الـ Actors (الإجابات الخاطئة) - Draggable
              ...wrongActors.map((actor) => Draggable<String>(
                data: actor.id!,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: actorSize,
                    height: actorSize,
                    child: Image.network(
                      actor.imageUrl ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                childWhenDragging: const SizedBox.shrink(), // إزالة المربع الرمادي
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: actorSize,
                  height: actorSize,
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
                onDragEnd: (details) {
                  // عند سحب Actor خاطئ، نعتبره إجابة خاطئة
                  _handleWrongAnswer();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
