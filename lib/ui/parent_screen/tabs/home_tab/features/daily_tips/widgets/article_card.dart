import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key});

  Future<void> _openArticle() async {
    final Uri url = Uri.parse(
      'https://autismlearningpartners.com/stress-free-morning-routine/',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppAssets.childPhoto,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.article_title,
            style: AppStyles.bold18Black,
          ),
          SizedBox(height: height * .01),
          Text(
            AppLocalizations.of(context)!.article_content,
            style: AppStyles.medium16BlackWithOpacity60,
          ),
          SizedBox(height: height * .01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * .01,
                  horizontal: width * .02,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPastelBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  AppLocalizations.of(context)!.expert_advice,
                  style: AppStyles.medium16SoftBlue,
                ),
              ),
              InkWell(

                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://autismlearningpartners.com/stress-free-morning-routine/',
                    );

                    final result = await launchUrl(url);

                    print('Result = $result');

                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: height * .01,
                    horizontal: width * .02,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.lightPastelBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 25,
                    color: AppColors.softBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}