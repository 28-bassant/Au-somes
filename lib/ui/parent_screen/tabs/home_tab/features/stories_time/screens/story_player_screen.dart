import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../child_screen/reinforcement_widgets/sound_helper.dart';
import '../widgets/encourangement_popup.dart';
import '../widgets/story_header.dart';
import '../widgets/answer_option_button.dart';
import 'story_complete_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../../../../models/story/story_response.dart';
class StoryPlayerScreen extends StatefulWidget {
  final StoryResponse story;

  const StoryPlayerScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}
class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  int _currentPage = 0;
  int? _selectedAnswer;
  int _wrongAttempts = 0;
  bool _answered = false;
  bool _showPopup = false;
  bool _showHint = false;
  int _score = 0;
  final FlutterTts _tts = FlutterTts();
  List<StoryPage> get _pages => widget.story.pages;

  StoryPage get _page => _pages[_currentPage];
  bool get _isLastPage => _currentPage == _pages.length - 1;
  bool get _isCorrect =>
      _answered &&
          _selectedAnswer != null &&
          _page.options[_selectedAnswer!] == _page.answer;
  bool get _showRetryBanner => _wrongAttempts >= 1 && !_isCorrect;

  bool get isArabic => Provider.of<AppLanguageProvider>(context).isArabic();



  void _selectAnswer(int index) {
    if (_answered) return;

    final correct = _page.options[index] == _page.answer;

    setState(() {
      _selectedAnswer = index;

      if (correct) {
        _answered = true;
        _score++;

        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;

          setState(() {
            _showPopup = true;
          });
        });
      }
      else {
        _wrongAttempts++;

        _speakWrongFeedback();

        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() => _selectedAnswer = null);
          }
        });
      }
    });
  }

  void _dismissPopup() {
    if (!mounted) return;

    setState(() {
      _showPopup = false;
    });

    if (_isLastPage) {
      _goNext();
    }
  }
  Future<void> _speak() async {
    await _tts.setLanguage("en-US"); // أو "ar"
    await _tts.setSpeechRate(0.5);

    await _tts.speak(_page.narration);
  }
  Future<void> _speakWrongFeedback() async {
    final isArabic =
    RegExp(r'[\u0600-\u06FF]').hasMatch(_page.feedback.wrongFeedback);

    await _tts.stop();

    await _tts.setLanguage(isArabic ? "ar-EG" : "en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    await _tts.speak(_page.feedback.wrongFeedback);
  }
  void _goNext() {
    if (_isLastPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StoryCompleteScreen(
            storyId: widget.story.storyId,
            score: _score,
            total: _pages.length,
          )
        ),
      );
    } else {
      setState(() {
        _currentPage++;
        _selectedAnswer = null;
        _wrongAttempts = 0;
        _answered = false;
        _showPopup = false;
        _showHint = false;
      });
    }
  }

  OptionState _optionState(int index) {
    if (_selectedAnswer == null) return OptionState.idle;

    if (_answered &&
        _page.options[index] == _page.answer) {
      return OptionState.correct;
    }

    if (_selectedAnswer == index &&
        _page.options[index] != _page.answer) {
      return OptionState.wrong;
    }

    return OptionState.idle;
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Provider.of<AppLanguageProvider>(context).isArabic();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(children: [
        Column(children: [
          StoryHeader(
            title: widget.story.theme,
            subtitle: widget.story.mission,
            currentPage: _currentPage + 1,
            totalPages: _pages.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImage(),
                  const SizedBox(height: 14),
                  _buildStoryText(),
                  const SizedBox(height: 6),
                  Align(
                    alignment: isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _speak,
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.softBlue,
                        ),
                      )
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                      _page.question,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: AppStyles.bold14Black
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    _page.options.length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AnswerOptionButton(
                        text: _page.options[i],
                        state: _optionState(i),
                        onTap: _answered ? null : () => _selectAnswer(i),
                      ),
                    ),
                  ),
                  if (_showRetryBanner) ...[
                    const SizedBox(height: 8),
                    _buildRetryBanner(),
                  ],
                  const SizedBox(height: 6),
                  if (_showHint)
                    _buildHintCard()
                  else
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _showHint = true),
                        icon: const Text('💡',
                            style: TextStyle(fontSize: 15)),
                        label: Text(
                          l10n.hint,
                          style: AppStyles.medium16SoftBlue
                        ),
                      ),
                    ),
                  if (!_showPopup) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _answered ? _goNext : null,                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softBlue,
                          padding:
                          const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isLastPage ? l10n.new_story : l10n.next,
                          style: AppStyles.bold16White
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ]),
        if (_showPopup)
          Positioned.fill(
            child: EncouragementPopup(
              message: _page.feedback.encouragementMessage,
              onDismiss: _dismissPopup,
            ),
          ),
      ]),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        _page.imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print(error);
          return const Center(
            child: Icon(Icons.broken_image, size: 60),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
  Widget _buildStoryText() {
    final isArabic = Provider.of<AppLanguageProvider>(context).isArabic();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyColor),
      ),
      child: Text(
          _page.narration,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style:AppStyles.medium10Black
      ),
    );
  }

  Widget _buildRetryBanner() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.redColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
              _page.feedback.wrongFeedback,
            style: AppStyles.bold14Black
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    final isArabic = Provider.of<AppLanguageProvider>(context).isArabic();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.mintGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greenColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                _page.feedback.retryHint,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style:AppStyles.bold14BlackWithOpacity60
            ),
          ),
        ],
      ),
    );
  }
}
