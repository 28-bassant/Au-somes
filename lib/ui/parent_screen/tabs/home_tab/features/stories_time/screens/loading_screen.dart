import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../providers/app_language_provider.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/app_routes.dart';
import 'story_player_screen.dart';
import '../../../../../../../api/api_manager.dart';
import '../../../../../../../models/story/story_response.dart';

class LoadingScreen extends StatefulWidget {
  final String childName;
  final String theme;
  final List<String> concepts;

  const LoadingScreen({
    super.key,
    required this.childName,
    required this.theme,
    required this.concepts,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {


  @override
  void initState() {
    super.initState();
    _generateStory();
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _generateStory() async {
    try {
      final StoryResponse story =
      await ApiManager.generateStories(
        childName: widget.childName,
        theme: widget.theme,
        concepts: widget.concepts,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StoryPlayerScreen(
            story: story,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    final isArabic = languageProvider.isArabic();
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: [
        Container(
          height: height * .13,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 42, 18, 22),
          decoration: const BoxDecoration(
            color: AppColors.lightPastelBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  l10n.generating_interactive_story,
                  style: AppStyles.bold20Black,
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                right: isArabic ? 0 : null,
                left: isArabic ? null : 0,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.storiesTimeScreenRouteName,
                          (route) => true,
                    );
                  },
                  child: Icon(
                    // السهم للخلف حسب الاتجاه
                    isArabic ? Icons.arrow_back : Icons.arrow_back,
                    size: 24,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SizedBox(
                width: double.infinity,
                child: LinearProgressIndicator(
                  color: AppColors.softBlue,
                  backgroundColor: AppColors.greyColor.withOpacity(0.3),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
                  const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⏳', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                        l10n.generating_interactive_story,
                        style: AppStyles.bold16SoftBlue
                    ),
                    ]),
                ],
              )
            ),
          ),
        ),
      ]),
    );
  }
}
