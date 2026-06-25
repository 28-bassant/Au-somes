import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../utils/app_colors.dart';

class StoryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onBack;

  const StoryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentPage,
    required this.totalPages,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<AppLanguageProvider>(context).isArabic();

    // حساب قيمة التقدم (تبدأ من 0)
    // currentPage يبدأ من 1،所以要 طرح 1
    final progressValue = (currentPage - 1) / totalPages;
    // عرض الصفحة الحالية (0-based) ولكن نعرضها كـ 1-based للمستخدم
    final displayPage = currentPage;
    var height = MediaQuery.of(context).size.height;


    return Container(
      height: height * .2,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.lightPastelBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  title,
                  style: AppStyles.bold14Black,
                  textAlign: TextAlign.center,
                ),
              ),
              // السهم - يتغير موقعه حسب اللغة
              Positioned(
                right: isArabic ? 0 : null,
                left: isArabic ? null : 0,
                child: GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppStyles.medium14BlackWithOpacity60,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      '${displayPage-1}/$totalPages',
                      style: AppStyles.bold16SoftBlue,
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.star,
                      size: 14,
                      color: currentPage > 0
                          ? AppColors.starGold
                          : AppColors.starEmpty,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0), // للتأكد من أن القيمة بين 0 و 1
              backgroundColor: AppColors.progressBg,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.softBlue,
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}