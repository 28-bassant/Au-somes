import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/app_routes.dart';
import '../stories_time_screen.dart';

class StoryCompleteScreen extends StatelessWidget {
  final int score;
  final int total;

  const StoryCompleteScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pct = score / total;

    String emoji;
    String msg;
    if (pct == 1.0) {
      emoji = '🏆';
      msg = l10n.excellent_you_answered;
    } else if (pct >= 0.5) {
      emoji = '⭐';
      msg = l10n.well_done_keep_practicing;
    } else {
      emoji = '💪';
      msg = l10n.keep_trying_you_will_improve;
    }
    var height = MediaQuery.of(context).size.height;


    return Scaffold(
     backgroundColor: AppColors.backgroundColor,
      body: Column(children: [
        Container(
          height: height * .13,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 42, 18, 24),
          decoration: const BoxDecoration(
            color: AppColors.lightPastelBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Center(
            child: Text(
              l10n.story_complete,
              style: AppStyles.bold22Black,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: AppStyles.bold18Black
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.greyColor),
                    ),
                    child: Column(children: [
                      Text(
                        l10n.your_score,
                        style: AppStyles.medium16BlackWithOpacity60
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$score / $total',
                        style: AppStyles.bold32SoftBlue
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          total,
                              (i) => Icon(
                            Icons.star,
                            size: 26,
                            color: i < score
                                ? AppColors.starGold
                                : AppColors.starEmpty,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.storiesTimeScreenRouteName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softBlue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: Text(l10n.new_story, style: AppStyles.bold22White),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}