import 'dart:async';
import 'dart:math';
import 'package:au_somes/api/api_constants.dart';
import 'package:au_somes/api/api_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../../../models/activities/activity_response.dart';
import '../../../../reinforcement_widgets/try_again_sound.dart';
import '../../../../reinforcement_widgets/well_done_overlay.dart';

class FrontBackLevel4Stage1Activity extends StatefulWidget {
  final VoidCallback? onNextStage;

  const FrontBackLevel4Stage1Activity({Key? key, this.onNextStage}) : super(key: key);

  @override
  State<FrontBackLevel4Stage1Activity> createState() =>
      FrontBackLevel4Stage1ActivityState();
}

class FrontBackLevel4Stage1ActivityState extends State<FrontBackLevel4Stage1Activity>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  ActivityResponse? _activity;
  bool _isLoading = true;
  bool _hasPlayedSound = false;
  bool _isPlacedCorrectly = false;
  bool _imagesLoaded = false;
  bool _dataLoaded = false;

  final GlobalKey _shadowLeftKey = GlobalKey();
  final GlobalKey _shadowRightKey = GlobalKey();

  int _wrongAttempts = 0;
  bool _isAnimatingShadow = false;
  AnimationController? _animationController;

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
        ApiConstants.front_back_activityId,
        2,
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

    if (_activity?.deceptionInstructions == null ||
        _activity!.deceptionInstructions!.isEmpty) return;

    try {
      await _player.stop();
      await _player.play(
        UrlSource(_activity!.deceptionInstructions![0]!),
      );
      print('Sound played successfully after data and images loaded');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void repeatSound() {
    if (_dataLoaded && _imagesLoaded) {
      playSound();
    }
  }

  void _handleWrongAnswer() {
    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts == 1) {
      TryAgainSound.play();
    } else if (_wrongAttempts == 2) {
      _startShadowAnimation();
    }
  }

  void _startShadowAnimation() {
    if (!_isAnimatingShadow && _animationController != null) {
      setState(() {
        _isAnimatingShadow = true;
      });

      _animationController!.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isAnimatingShadow = false;
          });

          _animationController!.stop();
          _animationController!.value = 0;
        }
      });
    }
  }

  void _handleDragEnd(DraggableDetails details, double actorSize) {
    if (_isPlacedCorrectly) return;

    final actorCenter = Offset(
      details.offset.dx + actorSize / 2,
      details.offset.dy + actorSize / 2,
    );


    final shadowLeftBox =
    _shadowLeftKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowLeftBox != null) {
      final pos = shadowLeftBox.localToGlobal(Offset.zero);

      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        shadowLeftBox.size.width,
        shadowLeftBox.size.height,
      );

      if (rect.contains(actorCenter)) {
        _handleWrongAnswer();
        return;
      }
    }


    final shadowRightBox =
    _shadowRightKey.currentContext?.findRenderObject() as RenderBox?;

    if (shadowRightBox != null) {
      final pos = shadowRightBox.localToGlobal(Offset.zero);

      final rect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        shadowRightBox.size.width,
        shadowRightBox.size.height,
      );

      if (rect.contains(actorCenter)) {
        setState(() {
          _isPlacedCorrectly = true;
          _wrongAttempts = 0;
          _isAnimatingShadow = false;
        });

        _animationController?.stop();
        _animationController?.value = 0;

        WellDoneOverlay.show(context);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNextStage?.call();
          }
        });
      }
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

    final actor = _activity!.elements!.firstWhere((e) => e.role == 'Actor');
    final actor2 = _activity!.elements!.lastWhere((e) => e.role == 'Actor');

    final shadowLeft = _activity!.elements!.firstWhere((e) => e.role == 'Shadow');
    final shadowRight = _activity!.elements!.lastWhere((e) => e.role == 'Shadow');

    final anchor = _activity!.elements!.firstWhere((e) => e.role == 'Anchor');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final anchorWidth = screenWidth * 1.5;
    final actorSize = screenWidth * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: screenWidth * 0.22,
            top: screenHeight * 0.42,
            child: AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                double shake = 0;

                if (_isAnimatingShadow) {
                  shake = screenWidth * 0.04 *
                      sin(_animationController!.value * pi);
                }

                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: Container(
                key: _shadowRightKey,
                width: 120,
                height: 120,
                child: _isPlacedCorrectly
                    ? Image.network(actor2.imageUrl ?? '', fit: BoxFit.fill)
                    : Image.network(shadowLeft.imageUrl ?? '',
                    fit: BoxFit.fill),
              ),
            ),
          ),

          Positioned.fill(
            child: Center(
              child: Image.network(
                anchor.imageUrl ?? '',
                width: anchorWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            left: screenWidth * 0.5,
            top: screenHeight * 0.45,
            child: Container(
              key: _shadowLeftKey,
              width: 120,
              height: 120,
              child: Image.network(
                shadowRight.imageUrl ?? '',
                fit: BoxFit.fill,
              ),
            ),
          ),

          if (!_isPlacedCorrectly)
            Positioned(
              right: 150,
              bottom: 20,
              child: Draggable<String>(
                data: actor2.id,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    actor2.imageUrl ?? '',
                    width: actorSize * 0.8,
                    height: actorSize * 0.5,
                  ),
                ),
                childWhenDragging: const SizedBox(),
                child: Image.network(
                  actor2.imageUrl ?? '',
                  width: actorSize * 0.5,
                  height: actorSize * 0.5,
                ),
                onDragEnd: (details) {
                  _handleDragEnd(details, actorSize);
                },
              ),
            ),
        ],
      ),
    );
  }
}