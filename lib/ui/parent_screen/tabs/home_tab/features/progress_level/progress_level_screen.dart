import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/percent_circular_indicator.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/percent_linear_indicator.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/progress_widget.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

import '../../../../../../api/api_manager.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../models/progress/progress_summary_response.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_styles.dart';
class ProgressLevelScreen extends StatefulWidget {
  const ProgressLevelScreen({Key? key}) : super(key: key);

  @override
  State<ProgressLevelScreen> createState() =>
      _ProgressLevelScreenState();
}

class _ProgressLevelScreenState
    extends State<ProgressLevelScreen> {

  ProgressSummaryResponse? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {
      summary = await ApiManager.getProgressSummary();
      print(" SUMMARY: ${summary?.totalPercentage}");
    } catch (e) {
      print("Progress Error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPastelBlue,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.blackColor,
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.progress_level,
              style: AppStyles.bold22Black,
            ),
            Text(
              AppLocalizations.of(context)!.your_child_progress,
              style: AppStyles.regular14BlackWithOpacity60,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadProgress,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: height * .02,
              horizontal: width * .04,
            ),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    ProgressWidget(
                      containerColor: AppColors.mintGreen,
                      icon: AppAssets.overallProgressIcon,
                      text1: '${summary?.passedPhaseCount ?? 0}',
                      text2:
                      AppLocalizations.of(context)!
                          .overall_progress,
                      text3:
                      '${summary?.totalPercentage.toStringAsFixed(0) ?? 0}%',
                      smallContainerColor:
                      AppColors.whiteColor.withOpacity(
                        0.3,
                      ),
                    ),

                    ProgressWidget(
                      text1Style:
                      AppStyles.regular14BlackWithOpacity60,
                      text2Style:
                      AppStyles.regular16BlackWithOpacity60,
                      text3Style:
                      AppStyles.bold24BlackWithOpacity60,
                      containerColor: AppColors.pastelPink,
                      icon: AppAssets.activitesDoneIcon,
                      text1:
                      AppLocalizations.of(context)!.today,
                      text2:
                      AppLocalizations.of(context)!
                          .activities_done,
                      text3: '5/8',
                      smallContainerColor:
                      AppColors.whiteColor.withOpacity(
                        0.3,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * .02),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    ProgressWidget(
                      text1Style:
                      AppStyles.regular14White,
                      text2Style:
                      AppStyles.regular16BlackWithOpacity60,
                      text3Style:
                      AppStyles.bold24BlackWithOpacity60,
                      containerColor:
                      AppColors.whiteColor,
                      icon: AppAssets.storiesTimeIcon,
                      text1:
                      AppLocalizations.of(context)!.done,
                      text2:
                      AppLocalizations.of(context)!
                          .stories_done,
                      text3: '6/20',
                      smallContainerColor:
                      AppColors.mintGreen,
                    ),

                    ProgressWidget(
                      text1Style:
                      AppStyles.regular14BlackWithOpacity60,
                      text2Style:
                      AppStyles.regular16BlackWithOpacity60,
                      text3Style:
                      AppStyles.bold24BlackWithOpacity60,
                      containerColor:
                      AppColors.whiteColor,
                      icon: AppAssets.achivementsIcon,
                      text1:
                      AppLocalizations.of(context)!
                          .new_word,
                      text2:
                      AppLocalizations.of(context)!
                          .achievements,
                      text3:
                      '${summary?.achievementPoints ?? 0}',
                      smallContainerColor:
                      AppColors.lightPastelBlue,
                    ),
                  ],
                ),

                SizedBox(height: height * .02),
                PercentCircularIndicator(
                  percent: (summary?.totalPercentage ?? 0) / 100,
                  progressText:
                  '${summary?.totalPercentage.toStringAsFixed(0) ?? 0}%',
                ),
                /// Spatial Concepts
                PercentLinearIndicator(
                  activityName:
                  AppLocalizations.of(context)!
                      .spatial_concepts_activities,
                  activityPercent:
                  '${summary?.spatialActivities.toStringAsFixed(0) ?? 0}%',
                  activityPercentStyle:
                  AppStyles.bold16PastelPink,
                  indicatorColor:
                  AppColors.pastelPink,
                  percent:
                  (summary?.spatialActivities ?? 0) /
                      100,
                ),

                SizedBox(height: height * .01),

                /// Spatial Relation
                PercentLinearIndicator(
                  activityName:
                  AppLocalizations.of(context)!
                      .spatial_relations_activities,
                  activityPercent:
                  '${summary?.spatialRelation.toStringAsFixed(0) ?? 0}%',
                  activityPercentStyle:
                  AppStyles.bold16MintGreen,
                  indicatorColor:
                  AppColors.mintGreen,
                  percent:
                  (summary?.spatialRelation ?? 0) /
                      100,
                ),

                SizedBox(height: height * .01),

                /// Visual Spatial Perception
                PercentLinearIndicator(
                  activityName:
                  AppLocalizations.of(context)!
                      .visual_spatial_visualization_activities,
                  activityPercent:
                  '${summary?.visualRelation.toStringAsFixed(0) ?? 0}%',
                  activityPercentStyle:
                  AppStyles.bold16SoftBlue,
                  indicatorColor:
                  AppColors.softBlue,
                  percent:
                  (summary?.visualRelation ?? 0) /
                      100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//PercentCircularIndicator(percent: 0.56),