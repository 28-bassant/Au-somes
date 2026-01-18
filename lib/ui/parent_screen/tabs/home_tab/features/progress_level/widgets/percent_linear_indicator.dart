import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class PercentLinearIndicator extends StatelessWidget{
  String activityName;
  String activityPercent;
  TextStyle activityPercentStyle;
  Color indicatorColor;
  double percent;
  PercentLinearIndicator({
    required this.activityName,
    required this.activityPercent,
    required this.activityPercentStyle,
    required this.indicatorColor,
    required this.percent
});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    return   Container(
      padding: EdgeInsets.symmetric(
        vertical: height * .008,
        horizontal: width * .02
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(activityName,style: AppStyles.medium16BlackWithOpacity60,),
              Text(activityPercent,style: activityPercentStyle,)
            ],
          ),
          Padding(
            padding: EdgeInsets.all(width * .02),
            child:  LinearPercentIndicator(
              width: width * .8,
              animation: true,
              isRTL: languageProvider.isArabic()?true : false,
              lineHeight: height * .02,
              barRadius: Radius.circular(16),
              animationDuration: 2500,
              percent: percent,
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: indicatorColor,
            ),
          )
        ],
      ),
    );
  }
}



