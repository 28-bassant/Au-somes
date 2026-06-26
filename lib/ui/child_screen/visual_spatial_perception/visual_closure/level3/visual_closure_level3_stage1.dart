import 'package:au_somes/l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../api/api_constants.dart';
import '../../../../../api/api_manager.dart';
import '../../../../../models/activities/activity_element.dart';
import '../../../../../models/activities/activity_response.dart';
import '../../../reinforcement_widgets/try_again_sound.dart';
import '../../../reinforcement_widgets/well_done_overlay.dart';
import '../../../reinforcement_widgets/true_answer_sound.dart';

import '../../visual_spatial_perception_base_screen.dart';
import '../../widgets/asperger_widget.dart';

class VisualClosureLevel3Stage1 extends StatefulWidget {
  final VoidCallback? onNextStage;

  const VisualClosureLevel3Stage1({Key? key, this.onNextStage})
      : super(key: key);

  @override
  State createState() => VisualClosureLevel3Stage1State();
}

class VisualClosureLevel3Stage1State extends State<VisualClosureLevel3Stage1> {
  late AudioPlayer _player;

  ActivityElement? anchor;
  List<ActivityElement> shadows = [];
  List<ActivityElement> actors = [];

  Map<String, String> placed = {};
  Map<String, bool> actorCanTry = {};

  bool _canPlayAfterOk = false;
  String? _audioUrl;

  int currentStep = 0;

  late List<Map<String, ActivityElement>> stepCorrect;
  List<String> stepInstructions = [];
  List<String> stepSuccess = [];

  // لحفظ آخر صوت اتشغل
  String? _currentPlayingInstruction;

  // ✅ متغيرات تتبع تحميل الصور
  bool _allImagesLoaded = false;
  int _totalImages = 0;
  int _loadedImagesCount = 0;

  // ✅ متغير لمنع تشغيل الصوت الأولي أكثر من مرة
  bool _initialSoundPlayed = false;
  bool _usedHint = false;
  ActivityResponse? _activity;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenContext = context;

      AspergerWidget().aspergerFun(
        screenContext,
        msg: AppLocalizations.of(context)!.asperger2,
        onSkip: () {
          final parent = screenContext
              .findAncestorStateOfType<VisualSpatialPerceptionBaseScreenState>();
          parent?.goToActivity(9);
        },
        onOk: () {
          _canPlayAfterOk = true;
          _playAfterDialog(); // ✅ تشغيل الصوت بعد الضغط على OK
        },
      );
    });

    _loadActivity();
  }

  void _playAfterDialog() async {
    if (!_canPlayAfterOk) return;
    if (_audioUrl == null || _audioUrl!.isEmpty) return;

    // ✅ فقط تشغل الصوت بعد تحميل الصور والضغط على OK
    if (_allImagesLoaded && !_initialSoundPlayed) {
      _initialSoundPlayed = true;
      try {
        await _player.stop();
        await _player.play(UrlSource(_audioUrl!));
        _currentPlayingInstruction = _audioUrl;
      } catch (e) {
        debugPrint("Error playing audio after dialog: $e");
      }
    }
  }

  void _resetActorTry() {
    actorCanTry.clear();
    for (var actor in actors) {
      actorCanTry[actor.id ?? ''] = true;
    }
  }

  void _checkAllImagesLoaded() {
    _loadedImagesCount++;
    if (_loadedImagesCount >= _totalImages && !_allImagesLoaded) {
      _allImagesLoaded = true;
      // ✅ مش هنشغل الصوت هنا تلقائياً، هنستنى الضغط على OK
      // _playInitialSoundIfReady(); // ❌ تم إلغاء التشغيل التلقائي
    }
  }

  // ❌ تم إلغاء هذه الدالة لأننا مش عايزين الصوت يشتغل تلقائياً
  // Future<void> _playInitialSoundIfReady() async { ... }

  Future<void> _playSound(String url) async {
    if (url.isEmpty) return;

    // ✅ فقط تشغل الصوت بعد تحميل الصور
    if (!_allImagesLoaded) return;

    _currentPlayingInstruction = url;

    await _player.stop();
    await _player.play(UrlSource(url));
  }

  void repeatSound() {
    if (_currentPlayingInstruction != null && _allImagesLoaded) {
      _playSound(_currentPlayingInstruction!);
    }
  }

  Future<void> _loadActivity() async {
    final response = await ApiManager.getActivity(
      ApiConstants.visual_closure_activityId,
      3,
      1,
    );

    _audioUrl = response.audioUrl;
    _activity = response;
    anchor = response.elements!.firstWhere((e) => e.role == 'Anchor');
    shadows = response.elements!.where((e) => e.role == 'Shadow').toList();
    actors = response.elements!.where((e) => e.role == 'Actor').toList();

    _resetActorTry();

    stepCorrect = [
      {'actor': actors[1], 'shadow': shadows[0]},
      {'actor': actors[2], 'shadow': shadows[2]},
      {'actor': actors[0], 'shadow': shadows[3]},
      {'actor': actors[3], 'shadow': shadows[1]},
    ];

    stepInstructions = response.deceptionInstructions ?? [];
    stepSuccess = response.deceptionInstructions ?? [];

    // ✅ حساب العدد الإجمالي للصور
    _totalImages = 1 + shadows.length + actors.length; // Anchor + Shadows + Actors

    // ✅ تحميل كل الصور مسبقاً
    _preloadAllImages();

    setState(() {});
  }

  void _preloadAllImages() {
    // تحميل صورة Anchor
    if (anchor?.imageUrl != null && anchor!.imageUrl!.isNotEmpty) {
      _preloadImage(anchor!.imageUrl!, 'anchor');
    }

    // تحميل صور Shadows
    for (var shadow in shadows) {
      if (shadow.imageUrl != null && shadow.imageUrl!.isNotEmpty) {
        _preloadImage(shadow.imageUrl!, 'shadow_${shadow.id}');
      }
    }

    // تحميل صور Actors
    for (var actor in actors) {
      if (actor.imageUrl != null && actor.imageUrl!.isNotEmpty) {
        _preloadImage(actor.imageUrl!, 'actor_${actor.id}');
      }
    }
  }

  void _preloadImage(String url, String key) {
    Image.network(
      url,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _checkAllImagesLoaded();
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        _checkAllImagesLoaded(); // Count as loaded even if error
        return const SizedBox.shrink();
      },
    );
  }

  void onActorDragEnd(ActivityElement actor, ActivityElement shadow) async {
    if (!_allImagesLoaded) return;

    var correctActor = stepCorrect[currentStep]['actor'];
    var correctShadow = stepCorrect[currentStep]['shadow'];

    if (actor == correctActor && shadow == correctShadow) {
      setState(() {
        placed[shadow.id!] = actor.imageUrl!;
        currentStep++;
        _resetActorTry();
      });

      if (currentStep < stepCorrect.length) {
        TrueAnswerSound.play();

        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (stepSuccess.length >= currentStep) {
          await _playSound(stepSuccess[currentStep - 1]);
        }
      } else {
        // ✅ سجل الـ Progress قبل Well Done
        await _logProgress();

        WellDoneOverlay.show(context);
      }

      if (currentStep == stepCorrect.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
      }
    } else {
      if (actorCanTry[actor.id ?? ''] == true) {
        if (_allImagesLoaded) {
          TryAgainSound.play();
        }

        actorCanTry[actor.id ?? ''] = false;

        // ✅ المستخدم أخطأ
        _usedHint = true;
      }
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

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        /// ⭐ Anchor
        if (anchor != null)
          Positioned(
            top: h * 0.1,
            left: w * 0.07,
            child: Image.network(
              anchor!.imageUrl ?? '',
              width: w * 0.9,
              height: h * 0.39,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  _checkAllImagesLoaded();
                }
                return child;
              },
            ),
          ),

        /// ⭐ Shadows
        if (shadows.length >= 4) ...[
          Positioned(
            top: h * 0.15,
            left: w * 0.21,
            width: w * 0.134,
            height: h * 0.15,
            child: _buildShadow(shadows[1]),
          ),
          Positioned(
            top: h * 0.1399,
            left: w * 0.58,
            width: w * 0.12,
            height: h * 0.15,
            child: _buildShadow(shadows[3]),
          ),
          Positioned(
            top: h * 0.355,
            left: w * 0.51,
            width: w * 0.14,
            height: h * 0.15,
            child: _buildShadow(shadows[0]),
          ),
          Positioned(
            top: h * 0.25,
            left: w * 0.76,
            width: w * 0.09,
            height: h * 0.15,
            child: _buildShadow(shadows[2]),
          ),
        ],

        /// ⭐ Actors
        for (int i = 0; i < actors.length; i++)
          if (!placed.values.contains(actors[i].imageUrl))
            Positioned(
              bottom: h * 0.1,
              left: w * (0.1 + i * 0.2),
              child: Draggable<ActivityElement>(
                data: actors[i],
                feedback: Image.network(
                  actors[i].imageUrl ?? '',
                  width: w * 0.14,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      _checkAllImagesLoaded();
                    }
                    return child;
                  },
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  actors[i].imageUrl ?? '',
                  width: w * 0.14,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      _checkAllImagesLoaded();
                    }
                    return child;
                  },
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildShadow(ActivityElement shadow) {
    bool isPlaced = placed.containsKey(shadow.id);

    return DragTarget<ActivityElement>(
      onWillAccept: (_) => _allImagesLoaded, // ✅ فقط لما الصور تتحمل
      onAccept: (actor) => onActorDragEnd(actor, shadow),
      builder: (context, _, __) {
        return isPlaced
            ? Image.network(placed[shadow.id]!)
            : Image.network(
          shadow.imageUrl ?? '',
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              _checkAllImagesLoaded();
            }
            return child;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}