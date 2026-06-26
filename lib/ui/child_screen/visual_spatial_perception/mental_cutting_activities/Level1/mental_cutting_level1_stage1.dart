import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';

class MentalCuttingLevel1Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const MentalCuttingLevel1Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  MentalCuttingLevel1Stage1State createState() => MentalCuttingLevel1Stage1State();
}

class MentalCuttingLevel1Stage1State extends State<MentalCuttingLevel1Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  // متغيرات للتحكم في Shadow
  bool _shadowReplaced = false; // هل تم استبدال Shadow أم لا
  String? _shadowImageUrl; // صورة Shadow الأصلية
  String? _correctActorImageUrl; // صورة الـ Actor الصحيح

  // متغيرات للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;
  bool _usedHint = false;

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
        1,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;

          // تعيين صور Shadow و Actor الصحيح
          final shadowElement = activity.elements!
              .firstWhere((e) => e.role == 'Shadow');
          final correctActor = activity.elements!
              .firstWhere((e) => e.targetedZoneId == shadowElement.id);

          _shadowImageUrl = shadowElement.imageUrl;
          _correctActorImageUrl = correctActor.imageUrl;
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

  // دالة للتعامل مع الإجابة الخاطئة
  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
      _usedHint = true;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts >= 2) {
      _startAnswerAnimation();
    }
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

  // دالة للتعامل مع الإجابة الصحيحة (الضغط على Actor الصحيح)
  Future<void> _handleCorrectActor() async {
    if (_shadowReplaced) return; // إذا تم استبدال Shadow بالفعل

    setState(() {
      _shadowReplaced = true;
      _wrongAttempts = 0;
      _isAnimatingAnswer = false;
    });

    _animationController?.stop();
    _animationController?.value = 0;

    // إظهار WellDoneOverlay بعد استبدال Shadow
    await _logProgress();

    WellDoneOverlay.show(context);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onNextStage?.call();
      }
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

    // الحصول على العناصر
    final anchorElement = elements.firstWhere((e) => e.role == 'Anchor');
    final shadowElement = elements.firstWhere((e) => e.role == 'Shadow');
    final correctActor = elements.firstWhere((e) => e.targetedZoneId == shadowElement.id);
    final otherActors = elements.where((e) =>
    e.role == 'Actor' && e.id != correctActor.id).toList();

    final double actorSize = MediaQuery.of(context).size.width * 0.3;
    final double anchorSize = MediaQuery.of(context).size.width * 0.3;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container العلوي: Anchor و Shadow
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 8
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.black,
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(16)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: anchorSize * 0.5,
                      height: anchorSize,
                      child: Image.network(
                        anchorElement.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      width: anchorSize * 0.5,
                      height: anchorSize,
                      child: _shadowReplaced
                          ? Image.network(
                        _correctActorImageUrl ?? '',
                        fit: BoxFit.contain,
                      )
                          : Image.network(
                        _shadowImageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

               SizedBox(height: height *.04),

              // جميع الـ Actors تحت بعض (تظل ظاهرة حتى بعد الإجابة الصحيحة)
              // Actor الصحيح (الإجابة الصحيحة)
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  double shakeValue = 0;
                  if (_isAnimatingAnswer && !_shadowReplaced) {
                    shakeValue = 20 * sin(_animationController!.value * 3.14159);
                  }
                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _handleCorrectActor,
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
                ),
              ),

              // باقي الـ Actors (الإجابات الخاطئة) - تظل ظاهرة حتى بعد الإجابة الصحيحة
              ...otherActors.map((actor) => GestureDetector(
                onTap: _handleWrongAnswer,
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
              )),
            ],
          ),
        ),
      ),
    );
  }
}
