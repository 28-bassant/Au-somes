import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/app_colors.dart';
import '../models/story_model.dart';
import '../widgets/encourangement_popup.dart';
import '../widgets/story_header.dart';
import '../widgets/answer_option_button.dart';
import 'story_complete_screen.dart';

class StoryPlayerScreen extends StatefulWidget {
  const StoryPlayerScreen({super.key});

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

  final List<StoryPage> _pages = const [
    StoryPage(
      imagePath: 'assets/images/pizza_kitchen.png',
      storyTextKey: 'story_text_pizza',
      question: StoryQuestion(
        questionKey: 'where_is_pizza',
        optionKeys: ['inside_box', 'outside_box'],
        correctIndex: 0,
        hintKey: 'pizza_hint',
      ),
    ),
    StoryPage(
      imagePath: 'assets/images/delivery_bike.png',
      storyTextKey: 'story_text_bike',
      question: StoryQuestion(
        questionKey: 'where_is_bag',
        optionKeys: ['at_back', 'at_front'],
        correctIndex: 0,
        hintKey: 'bag_hint',
      ),
    ),
    StoryPage(
      imagePath: 'assets/images/delivery_arrive.png',
      storyTextKey: 'story_text_arrive',
      question: StoryQuestion(
        questionKey: 'where_is_grandma',
        optionKeys: ['in_front_of_door', 'behind_door'],
        correctIndex: 0,
        hintKey: 'grandma_hint',
      ),
    ),
  ];

  StoryPage get _page => _pages[_currentPage];
  bool get _isLastPage => _currentPage == _pages.length - 1;
  bool get _isCorrect =>
      _answered && _selectedAnswer == _page.question.correctIndex;
  bool get _showRetryBanner => _wrongAttempts >= 1 && !_isCorrect;

  bool get isArabic => Provider.of<AppLanguageProvider>(context).isArabic();

  String _getLocalizedText(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'title':
        return l10n.title;
      case 'subtitle':
        return l10n.subtitle;
      case 'where_is_pizza':
        return l10n.where_is_pizza;
      case 'inside_box':
        return l10n.inside_box;
      case 'outside_box':
        return l10n.outside_box;
      case 'where_is_bag':
        return l10n.where_is_bag;
      case 'at_back':
        return l10n.at_back;
      case 'at_front':
        return l10n.at_front;
      case 'where_is_grandma':
        return l10n.where_is_grandma;
      case 'in_front_of_door':
        return l10n.in_front_of_door;
      case 'behind_door':
        return l10n.behind_door;
      case 'pizza_hint':
        return l10n.pizza_hint;
      case 'bag_hint':
        return l10n.bag_hint;
      case 'grandma_hint':
        return l10n.grandma_hint;
      // case 'story_text_pizza':
      //   return l10n.story_text_pizza;
      // case 'story_text_bike':
      //   return l10n.story_text_bike;
      // case 'story_text_arrive':
      //   return l10n.story_text_arrive;
      default:
        return key;
    }
  }

  String _getPopupMessage() {
    final l10n = AppLocalizations.of(context)!;
    final messages = [l10n.keep_going, l10n.wonderful, l10n.well_done];
    return messages[_currentPage % messages.length];
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    final correct = index == _page.question.correctIndex;
    setState(() {
      _selectedAnswer = index;
      if (correct) {
        _answered = true;
        _score++;
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) setState(() => _showPopup = true);
        });
      } else {
        _wrongAttempts++;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _selectedAnswer = null);
        });
      }
    });
  }

  void _dismissPopup() {
    setState(() => _showPopup = false);
    Future.delayed(const Duration(milliseconds: 150), _goNext);
  }

  void _goNext() {
    if (_isLastPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StoryCompleteScreen(
            score: _score,
            total: _pages.length,
          ),
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
    if (index == _page.question.correctIndex && _answered) {
      return OptionState.correct;
    }
    if (index == _selectedAnswer && index != _page.question.correctIndex) {
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
            title: l10n.title,
            subtitle: l10n.subtitle,
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
                        onPressed: () {},
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.softBlue,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _getLocalizedText(_page.question.questionKey),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: AppStyles.bold14Black
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    _page.question.optionKeys.length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AnswerOptionButton(
                        text: _getLocalizedText(
                            _page.question.optionKeys[i]),
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
                        onPressed: _goNext,
                        style: ElevatedButton.styleFrom(
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
              message: _getPopupMessage(),
              onDismiss: _dismissPopup,
            ),
          ),
      ]),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        _page.imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 200,
          color: const Color(0xFFFFE0B2),
          child: const Center(
            child: Text('🍕', style: TextStyle(fontSize: 60)),
          ),
        ),
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
        _getLocalizedText(_page.storyTextKey),
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
        color: AppColors.redColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            l10n.lets_try_again,
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
              _getLocalizedText(_page.question.hintKey),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style:AppStyles.bold14BlackWithOpacity60
            ),
          ),
        ],
      ),
    );
  }
}