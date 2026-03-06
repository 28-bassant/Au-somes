import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level1/front_back_level1_stage1_activity.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level1/front_back_level1_stage2_activity.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level2/front_back_level2_stage1_activity.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level2/front_back_level2_stage3_activity.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_colors.dart';
import 'level1/outside_level1_stage1_activity.dart';
import 'level1/outside_level1_stage2_activity.dart';
import 'level1/outside_level1_stage3_activity.dart';
import 'level1/outside_level1_stage4_activity.dart';
import 'level2/outside_level2_stage1_activity.dart';
import 'level2/outside_level2_stage2_activity.dart';
import 'level2/outside_level2_stage3_activity.dart';
import 'level2/outside_level2_stage4_activity.dart';

class OutsideBaseActivityScreen extends StatefulWidget {
  @override
  _OutsideBaseActivityScreenState createState() =>
      _OutsideBaseActivityScreenState();
}

class _OutsideBaseActivityScreenState extends State<OutsideBaseActivityScreen> {
  final stage11Key = GlobalKey<OutsideLevel1Stage1ActivityState>();
  final stage12Key = GlobalKey<OutsideLevel1Stage2ActivityState>();
  final stage13Key = GlobalKey<OutsideLevel1Stage3ActivityState>();
  final stage14Key = GlobalKey<OutsideLevel1Stage4ActivityState>();
  final stage21Key = GlobalKey<OutsideLevel2Stage1ActivityState>();
  final stage22Key = GlobalKey<OutsideLevel2Stage2ActivityState>();
  final stage23Key = GlobalKey<OutsideLevel2Stage3ActivityState>();
  final stage24Key = GlobalKey<OutsideLevel2Stage4ActivityState>();

  late final List<Widget> activities;
  int currentActivityIndex = 0;

  @override
  void initState() {
    super.initState();
    activities = [
      OutsideLevel1Stage1Activity(
        key: stage11Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel1Stage2Activity(
        key: stage12Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel1Stage3Activity(
        key: stage13Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel1Stage4Activity(
        key: stage14Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel2Stage1Activity(
        key: stage21Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel2Stage2Activity(
        key: stage22Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel2Stage3Activity(
        key: stage23Key,
        onNextStage: goToNextActivity,
      ),
      OutsideLevel2Stage4Activity(
        key: stage24Key,
        onNextStage: goToNextActivity,
      ),

    ];
  }

  void repeatCurrentSound() {
    if (currentActivityIndex == 0) {
      stage11Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 1) {
      stage12Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 2) {
      stage13Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 3) {
      stage14Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 4) {
      stage21Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 5) {
      stage22Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 6) {
      stage23Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 7) {
      stage24Key.currentState?.repeatSound();
    }

  }

  void goToNextActivity() {
    setState(() {
      if (currentActivityIndex < activities.length - 1) {
        currentActivityIndex++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("خلصت كل الأنشطة!")),
        );
      }
    });
  }

  void goToPreviousActivity() {
    setState(() {
      if (currentActivityIndex > 0) {
        currentActivityIndex--;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
            actionsPadding: EdgeInsets.symmetric(horizontal: width * .02),
            centerTitle: true,
            actions: [
            GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(
        context, AppRoutes.spatialConceptsScreenRouteName),
    child: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
    color: AppColors.whiteColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: AppColors.blackColorWithOpacity60, width: 1),
    ),
    child: Icon(
    Icons.home_outlined,
      color: AppColors.blackColorWithOpacity60,
      size: 25,
    ),
    ),
            ),
            ],
          leading: GestureDetector(
            onTap: goToPreviousActivity,
            child: Row(
              children: [
                SizedBox(width: width * .02),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.blackColorWithOpacity60, width: 1),
                  ),
                  child: Icon(
                    languageProvider.isArabic()
                        ? Icons.arrow_forward
                        : Icons.arrow_back,
                    color: AppColors.blackColorWithOpacity60,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      body: Column(
        children: [
          Expanded(child: activities[currentActivityIndex]),
          GestureDetector(
            onTap: repeatCurrentSound,
            child: Center(
              child: Image(image: AssetImage(AppAssets.soundIcon)),
            ),
          ),
          SizedBox(height: height * .04),

          // InkWell(
          //   onTap: goToNextActivity,
          //   child: const Center(
          //     child: Icon(Icons.add),
          //   ),
          // ),
        ],
      ),
    );
  }
}