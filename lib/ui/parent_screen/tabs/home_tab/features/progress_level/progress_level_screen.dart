import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/percent_circular_indicator.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/percent_linear_indicator.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/progress_widget.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_styles.dart';

class ProgressLevelScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.lightPastelBlue,
          elevation: 0,
          iconTheme: IconThemeData(
              color: AppColors.blackColor
          ),
          centerTitle: true,
          title: Column(
            children: [
              Text(AppLocalizations.of(context)!.progress_level,style: AppStyles.bold22Black,),
              Text(AppLocalizations.of(context)!.your_child_progress,style: AppStyles.regular14BlackWithOpacity60,),
            ],
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(
            vertical: height * .02,
            horizontal: width*.04
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProgressWidget(
                      containerColor: AppColors.mintGreen,
                      icon: AppAssets.overallProgressIcon,
                      text1: '12%',
                      text2: AppLocalizations.of(context)!.overall_progress,
                      text3: '78%',
                      smallContainerColor: AppColors.whiteColor.withOpacity(0.3)),
                  ProgressWidget(
                    text1Style: AppStyles.regular14BlackWithOpacity60,
                      text2Style: AppStyles.regular16BlackWithOpacity60,
                      text3Style: AppStyles.bold24BlackWithOpacity60,
                      containerColor: AppColors.pastelPink,
                      icon: AppAssets.activitesDoneIcon,
                      text1: AppLocalizations.of(context)!.today,
                      text2: AppLocalizations.of(context)!.activities_done,
                      text3: '5/8',
                      smallContainerColor: AppColors.whiteColor.withOpacity(0.3),
        
        
                  ),
        
                ],
              ),
              SizedBox(height: height*.02,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProgressWidget(
                      text1Style: AppStyles.regular14White,
                      text2Style: AppStyles.regular16BlackWithOpacity60,
                      text3Style: AppStyles.bold24BlackWithOpacity60,
                      containerColor: AppColors.whiteColor,
                      icon: AppAssets.storiesTimeIcon,
                      text1: AppLocalizations.of(context)!.done,
                      text2: AppLocalizations.of(context)!.stories_done,
                      text3: '6/20',
                      smallContainerColor: AppColors.mintGreen),
                  ProgressWidget(
                    text1Style: AppStyles.regular14BlackWithOpacity60,
                    text2Style: AppStyles.regular16BlackWithOpacity60,
                    text3Style: AppStyles.bold24BlackWithOpacity60,
                    containerColor: AppColors.whiteColor,
                    icon: AppAssets.achivementsIcon,
                    text1: AppLocalizations.of(context)!.new_word,
                    text2: AppLocalizations.of(context)!.achievements,
                    text3: '23',
                    smallContainerColor: AppColors.lightPastelBlue,
        
        
                  ),
        
                ],
              ),
              SizedBox(height: height*.02,),
              PercentCircularIndicator(percent: 0.56),
              SizedBox(height: height*.02,),
              PercentLinearIndicator(
                  activityName: AppLocalizations.of(context)!.spatial_concepts_activities,
                  activityPercent: '68%',
                  activityPercentStyle: AppStyles.bold16PastelPink,
                  indicatorColor: AppColors.pastelPink,
                  percent: 0.68),
              SizedBox(height: height*.01,),
              PercentLinearIndicator(
                  activityName: AppLocalizations.of(context)!.spatial_relations_activities,
                  activityPercent: '55%',
                  activityPercentStyle: AppStyles.bold16MintGreen,
                  indicatorColor: AppColors.mintGreen,
                  percent: 0.55),
              SizedBox(height: height*.01,),
              PercentLinearIndicator(
                  activityName: AppLocalizations.of(context)!.visual_spatial_visualization_activities,
                  activityPercent: '77%',
                  activityPercentStyle: AppStyles.bold16SoftBlue,
                  indicatorColor: AppColors.softBlue,
                  percent: 0.77),



            ],
          ),
        ),
      ),
    );
  }
}