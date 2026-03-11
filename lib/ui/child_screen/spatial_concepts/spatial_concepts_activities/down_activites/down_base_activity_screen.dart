import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/up_activites/level1/up_level1_stage1_activity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_assets.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_routes.dart';
import '../../../reinforcement_widgets/confetti_overlay.dart';
import 'level1/down_level1_stage1_activity.dart';
import 'level1/down_level1_stage2_activity.dart';
import 'level1/down_level1_stage3_activity.dart';
import 'level1/down_level1_stage4_activity.dart';
import 'level2/down_level2_stage1_activity.dart';
import 'level2/down_level2_stage2_activity.dart';
import 'level2/down_level2_stage3_activity.dart';
import 'level2/down_level2_stage4_activity.dart';

class DownBaseActivityScreen extends StatefulWidget {
  @override
  _DownBaseActivityScreenState createState() =>
      _DownBaseActivityScreenState();
}

class _DownBaseActivityScreenState extends State<DownBaseActivityScreen> {
  final stage11Key = GlobalKey<DownLevel1Stage1ActivityState>();
  final stage12Key = GlobalKey<DownLevel1Stage2ActivityState>();
  final stage13Key = GlobalKey<DownLevel1Stage3ActivityState>();
  final stage14Key = GlobalKey<DownLevel1Stage4ActivityState>();

  final stage21Key = GlobalKey<DownLevel2Stage1ActivityState>();
  final stage22Key = GlobalKey<DownLevel2Stage2ActivityState>();
  final stage23Key = GlobalKey<DownLevel2Stage3ActivityState>();
  final stage24Key = GlobalKey<DownLevel2Stage4ActivityState>();


  late final List<Widget> activities;
  int currentActivityIndex = 0;

  @override
  void initState() {
    super.initState();
    activities = [
      DownLevel1Stage1Activity(
        key: stage11Key,
        onNextStage: goToNextActivity,
      ),
      DownLevel1Stage2Activity(
        key: stage12Key,
        onNextStage: goToNextActivity,
      ),

      DownLevel1Stage3Activity(
        key: stage13Key,
        onNextStage: goToNextActivity,
      ),

      DownLevel1Stage4Activity(
        key: stage14Key,
        onNextStage: goToNextActivity,
      ),

      DownLevel2Stage1Activity(
        key: stage21Key,
        onNextStage: goToNextActivity,
      ),

      DownLevel2Stage2Activity(
        key: stage22Key,
        onNextStage: goToNextActivity,
      ),
      DownLevel2Stage3Activity(
        key: stage23Key,
        onNextStage: goToNextActivity,
      ),
      DownLevel2Stage4Activity(
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
    }
    else if (currentActivityIndex == 2) {
      stage13Key.currentState?.repeatSound();
    }

    else if (currentActivityIndex == 3) {
      stage14Key.currentState?.repeatSound();
    }
    else if (currentActivityIndex == 4) {
      stage21Key.currentState?.repeatSound();
    }

    else if (currentActivityIndex == 5) {
      stage22Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 6) {
      stage23Key.currentState?.repeatSound();
    }
    else if (currentActivityIndex == 7) {
      stage24Key.currentState?.repeatSound();
    }

  }

  void goToNextActivity() {
    setState(() {
      if (currentActivityIndex < activities.length - 1) {
        currentActivityIndex++;
      } else {
        ConfettiOverlay.show(context);

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.spatialConceptsScreenRouteName,
            );
          }
        });
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
          //   child: Center(
          //     child: Icon(Icons.add),
          //   ),
          // ),
        ],
      ),
    );
  }
}