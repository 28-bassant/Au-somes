import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../providers/app_language_provider.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/app_routes.dart';
import 'story_player_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progress = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.forward().then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>  StoryPlayerScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
                  style: AppStyles.bold14Black,
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
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, __) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        backgroundColor: AppColors.lightPastelBlue,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.softBlue,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          l10n.generating_interactive_story,
                          style: AppStyles.bold16SoftBlue
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}