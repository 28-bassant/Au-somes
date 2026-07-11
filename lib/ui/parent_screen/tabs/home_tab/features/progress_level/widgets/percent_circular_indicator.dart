import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
class PercentCircularIndicator extends StatelessWidget {
  final double percent;
  final String progressText;

  const PercentCircularIndicator({
    super.key,
    required this.percent,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: height * .46,
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 20.0,
        animation: true,
        percent: percent,
        animationDuration: 2500,
        center: Text(
          progressText,
          style: AppStyles.bold32MintGreen,
        ),
        footer: Text(
          AppLocalizations.of(context)!.overall_progress,
          style: AppStyles.medium16BlackWithOpacity60,
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: AppColors.mintGreen,
      ),
    );
  }
}
