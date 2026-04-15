import 'dart:math';

import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/try_again_sound.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/true_answer_sound.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
import '../../visual_spatial_perception_base_screen.dart';
import '../../widgets/asperger_widget.dart';

class MentalCuttingLevel3Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const MentalCuttingLevel3Stage1({Key? key, this.onNextStage}) : super(key: key);

  @override
  MentalCuttingLevel3Stage1State createState() => MentalCuttingLevel3Stage1State();
}

class MentalCuttingLevel3Stage1State extends State<MentalCuttingLevel3Stage1>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  // قائمة لتتبع أي Anchors تم ملؤها
  Map<String, bool> _filledAnchors = {};
  Map<String, String?> _anchorImages = {};
  Map<String, String?> _actorImages = {};
  Map<String, String?> _shadowImages = {};
  Map<String, String?> _actorTargetAnchor = {}; // لتخزين الـ Anchor المستهدف لكل Actor

  // لتتبع الأصوات التي تم تشغيلها لكل Anchor
  Map<String, bool> _soundPlayed = {};

  // متغيرات للإدارة
  int _wrongAttempts = 0;
  bool _isAnimatingAnswer = false;
  AnimationController? _animationController;
  String? _animatingAnchorId; // Anchor الذي يهتز وليس Actor

  // GlobalKeys لكل Anchor
  final Map<String, GlobalKey> _anchorKeys = {};


  void _playAfterDialog() async {
    _canPlaySound = true;
    // تأخير بسيط للتأكد من أن كل شيء جاهز
    await Future.delayed(const Duration(milliseconds: 100));
    await playSound();
    _hasPlayedSound = true;
  }
  @override
  void initState() {
    super.initState();

    // تهيئة AudioPlayer أولاً
    _player = AudioPlayer();

    // استخدام Future.delayed للتأكد من اكتمال التهيئة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AspergerWidget().aspergerFun(
        context,
        onSkip: () {
          final parent = context.findAncestorStateOfType<VisualSpatialPerceptionBaseScreenState>();
          parent?.goToActivity(23);
        },
        onOk: () {
          _playAfterDialog();
        },
      );
    });

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
        3,
        1,
      );

      if (mounted) {
        setState(() {
          _activity = activity;
          _dataLoaded = true;

          // تجهيز البيانات
          final elements = activity.elements!;

          // الحصول على Shadow
          final shadowElement = elements.firstWhere((e) => e.role == 'Shadow');
          final shadowImageUrl = shadowElement.imageUrl;

          // تجهيز Anchors و Actors
          for (var element in elements) {
            if (element.role == 'Anchor') {
              _filledAnchors[element.id!] = false;
              _anchorImages[element.id!] = element.imageUrl;
              _shadowImages[element.id!] = shadowImageUrl;
              _anchorKeys[element.id!] = GlobalKey();
              _soundPlayed[element.id!] = false;
            } else if (element.role == 'Actor') {
              _actorImages[element.id!] = element.imageUrl;
              _actorTargetAnchor[element.id!] = element.targetedZoneId;
            }
          }
        });

        await _preloadImages(activity);

        setState(() {
          _imagesLoaded = true;
        });



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
  bool _canPlaySound = false;

  Future<void> playSound() async {
    if (!_canPlaySound) return;

    // التأكد من أن player تم تهيئته
    if (_player == null) {
      print('AudioPlayer not initialized');
      return;
    }

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
  void _handleWrongAnswer(String actorId) {
    setState(() {
      _wrongAttempts++;
    });

    // تشغيل صوت Try Again فقط في المرة الأولى
    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    }

    // عند المحاولة الخاطئة الثانية، نهتز الـ Anchor الصحيح (بدون صوت)
    if (_wrongAttempts >= 2) {
      // الحصول على الـ Anchor المستهدف لهذا الـ Actor
      final targetAnchorId = _actorTargetAnchor[actorId];
      if (targetAnchorId != null && !_filledAnchors[targetAnchorId]!) {
        _startAnchorAnimation(targetAnchorId);
      }
    }
  }

  // دالة لبدء حركة الـ Anchor
  void _startAnchorAnimation(String anchorId) {
    if (!_isAnimatingAnswer && _animationController != null) {
      setState(() {
        _isAnimatingAnswer = true;
        _animatingAnchorId = anchorId;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isAnimatingAnswer) {
          setState(() {
            _isAnimatingAnswer = false;
            _animatingAnchorId = null;
          });
          _animationController!.stop();
          _animationController!.value = 0;
        }
      });
    }
  }

  // دالة للتحقق من أن الـ Actor قد وقع داخل Anchor
  String? _getAnchorUnderActor(DraggableDetails details, double actorSize) {
    // نتحقق على جميع الـ Anchors
    for (var entry in _anchorKeys.entries) {
      final renderBox = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final anchorPosition = renderBox.localToGlobal(Offset.zero);
      final anchorSize = renderBox.size;

      final actorCenter = Offset(
        details.offset.dx + actorSize / 2,
        details.offset.dy + actorSize / 2,
      );

      final anchorRect = Rect.fromLTWH(
        anchorPosition.dx,
        anchorPosition.dy,
        anchorSize.width,
        anchorSize.height,
      );

      if (anchorRect.contains(actorCenter)) {
        return entry.key;
      }
    }
    return null;
  }

  // دالة للتعامل مع سحب Actor
  void _handleActorDragEnd(DraggableDetails details, double actorSize, String actorId) {
    // الحصول على الـ Anchor الذي تم السحب فوقه
    final targetAnchorId = _getAnchorUnderActor(details, actorSize);

    if (targetAnchorId == null) {
      // إذا لم يتم السحب فوق أي Anchor، لا نفعل شيء
      return;
    }

    // التحقق مما إذا كان هذا الـ Anchor هو الهدف الصحيح لهذا الـ Actor
    final expectedAnchorId = _actorTargetAnchor[actorId];

    if (expectedAnchorId == targetAnchorId && !_filledAnchors[targetAnchorId]!) {
      // إجابة صحيحة
      setState(() {
        _filledAnchors[targetAnchorId] = true;
        _wrongAttempts = 0;
        _isAnimatingAnswer = false;
        _animatingAnchorId = null;
      });

      _animationController?.stop();
      _animationController?.value = 0;

      // تشغيل صوت الإجابة الصحيحة إذا لم يتم تشغيله من قبل لهذا الـ Anchor
      if (!_soundPlayed[targetAnchorId]!) {
        _soundPlayed[targetAnchorId] = true;
        TrueAnswerSound.play();
      }

      // التحقق من اكتمال جميع Anchors
      bool allFilled = _filledAnchors.values.every((filled) => filled == true);
      if (allFilled) {
        WellDoneOverlay.show(context);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
      }
    } else {
      // إجابة خاطئة
      _handleWrongAnswer(actorId);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // الحصول على Anchors و Actors
    final anchors = elements.where((e) => e.role == 'Anchor').toList();
    final actors = elements.where((e) => e.role == 'Actor').toList();

    final double anchorSize = screenWidth * 0.2;
    final double actorSize = screenWidth * 0.2;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // عرض Anchors في شبكة 2x2 مع Shadow بجانب كل Anchor
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.5,
                children: anchors.map((anchor) {
                  final actor = actors.firstWhere(
                        (a) => a.targetedZoneId == anchor.id,
                    orElse: () => actors.first,
                  );

                  return AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      double shakeValue = 0;
                      if (_isAnimatingAnswer && _animatingAnchorId == anchor.id) {
                        shakeValue = 20 * sin(_animationController!.value * 3.14159);
                      }
                      return Transform.translate(
                        offset: Offset(shakeValue, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      key: _anchorKeys[anchor.id!],
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Anchor image
                          Container(
                            width: anchorSize * 0.5,
                            height: anchorSize,
                            child: Image.network(
                              anchor.imageUrl ?? '',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Shadow or Actor after being filled (جنب Anchor)
                          Container(
                            width: anchorSize * 0.5,
                            height: anchorSize * 0.8,
                            child: _filledAnchors[anchor.id!] == true
                                ? Image.network(
                              actor.imageUrl ?? '',
                              fit: BoxFit.contain,
                            )
                                : Image.network(
                              elements.firstWhere((e) => e.role == 'Shadow').imageUrl ?? '',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 50),

              // عرض الـ Actors في صف أفقي
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: actors.map((actor) {
                  final targetAnchor = anchors.firstWhere(
                        (a) => a.id == actor.targetedZoneId,
                    orElse: () => anchors.first,
                  );
                  final isFilled = _filledAnchors[targetAnchor.id!] == true;

                  if (isFilled) return const SizedBox.shrink();

                  return Draggable<String>(
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
                    childWhenDragging: const SizedBox.shrink(),
                    child: Container(
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
                      _handleActorDragEnd(details, actorSize, actor.id!);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
