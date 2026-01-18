import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PercentCircularIndicator extends StatelessWidget {
  final double percent;

  const PercentCircularIndicator({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      height: height*.35,
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(.3),
        borderRadius: BorderRadius.circular(16)
      ),
      child: CircularPercentIndicator(
         radius: 120.0,
         lineWidth: 20.0,
         animation: true,
         percent: percent,
         animationDuration: 2500,
         center:  Text(
             '${(percent * 100).toInt()} %',
             style: AppStyles.bold32MintGreen
         ),
         footer:  Text(
           AppLocalizations.of(context)!.today_progress,
           style:AppStyles.medium16BlackWithOpacity60,
         ),
         circularStrokeCap: CircularStrokeCap.round,
         progressColor: AppColors.mintGreen,
       ),
    );
  }
}
