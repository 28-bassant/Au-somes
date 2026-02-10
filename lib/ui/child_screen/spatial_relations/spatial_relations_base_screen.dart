import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level1(Right&Left)/activity1_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level1(Right&Left)/activity1_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level2(Inside&Outside)/activity1_level2_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level2(Inside&Outside)/activity1_level2_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level3(Near&Far)/activity1_level3_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level3(Near&Far)/activity1_level3_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level4(Front&Back)/activity1_level4_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level4(Front&Back)/activity1_level4_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity1/Level5(Between)/activity1_level5_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity2/Level1/activity2_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity2/Level1/activity2_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity3/Level1/activity3_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity4/Level1/activity4_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity4/Level1/activity4_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity4/Level1/activity4_level1_stage3.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity5/Level1/activity5_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity5/Level1/activity5_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity5/Level1/activity5_level1_stage3.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity5/Level1/activity5_level1_stage4.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity5/Level1/activity5_level1_stage5.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_assets.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_routes.dart';


class SpatialRelationsBaseScreen extends StatefulWidget {
  @override
  _SpatialRelationsBaseScreenState createState() =>
      _SpatialRelationsBaseScreenState();
}

class _SpatialRelationsBaseScreenState extends State<SpatialRelationsBaseScreen> {
  final stage111Key = GlobalKey<Activity1Level1Stage1State>();
  final stage112Key = GlobalKey<Activity1Level1Stage2State>();
  final stage121Key = GlobalKey<Activity1Level2Stage1State>();
  final stage122Key = GlobalKey<Activity1Level2Stage2State>();
  final stage131Key = GlobalKey<Activity1Level3Stage1State>();
  final stage132Key = GlobalKey<Activity1Level3Stage2State>();
  final stage141Key = GlobalKey<Activity1Level4Stage1State>();
  final stage142Key = GlobalKey<Activity1Level4Stage2State>();
  final stage151Key = GlobalKey<Activity1Level5Stage1State>();
  final stage211Key = GlobalKey<Activity2Level1Stage1State>();
  final stage212Key = GlobalKey<Activity2Level1Stage2State>();
  final stage311Key = GlobalKey<Activity3Level1Stage1State>();
  final stage411Key = GlobalKey<Activity4Level1Stage1State>();
  final stage412Key = GlobalKey<Activity4Level1Stage2State>();
  final stage413Key = GlobalKey<Activity4Level1Stage3State>();
  final stage511Key = GlobalKey<Activity5Level1Stage1State>();
  final stage512Key = GlobalKey<Activity5Level1Stage2State>();
  final stage513Key = GlobalKey<Activity5Level1Stage3State>();
  final stage514Key = GlobalKey<Activity5Level1Stage4State>();
  final stage515Key = GlobalKey<Activity5Level1Stage5State>();



  late final List<Widget> activities;
  int currentActivityIndex = 0;

  @override
  void initState() {
    super.initState();
    activities = [
      Activity1Level1Stage1(
        key: stage111Key,
        onNextStage: goToNextActivity,
      ),
      Activity1Level1Stage2(
        key: stage112Key,
        onNextStage: goToNextActivity,
      ),
     Activity1Level2Stage1(
        key: stage121Key,
        onNextStage: goToNextActivity,
      ),
     Activity1Level2Stage2(
        key: stage122Key,
        onNextStage: goToNextActivity,
      ),
      Activity1Level3Stage1(
        key: stage131Key,
        onNextStage: goToNextActivity,
      ),
     Activity1Level3Stage2(
        key: stage132Key,
        onNextStage: goToNextActivity,
      ),
 Activity1Level4Stage1(
        key: stage141Key,
        onNextStage: goToNextActivity,
      ),
Activity1Level4Stage2(
        key: stage142Key,
        onNextStage: goToNextActivity,
      ),
Activity1Level5Stage1(
        key: stage151Key,
        onNextStage: goToNextActivity,
      ),
Activity2Level1Stage1(
        key: stage211Key,
        onNextStage: goToNextActivity,
      ),
Activity2Level1Stage2(
        key: stage212Key,
        onNextStage: goToNextActivity,
      ),
Activity3Level1Stage1(
        key: stage311Key,
        onNextStage: goToNextActivity,
      ),
Activity4Level1Stage1(
        key: stage411Key,
        onNextStage: goToNextActivity,
      ),
Activity4Level1Stage2(
        key: stage412Key,
        onNextStage: goToNextActivity,
      ),
Activity4Level1Stage3(
        key: stage413Key,
        onNextStage: goToNextActivity,
      ),
Activity5Level1Stage1(
        key: stage511Key,
        onNextStage: goToNextActivity,
      ),
Activity5Level1Stage2(
        key: stage512Key,
        onNextStage: goToNextActivity,
      ),
Activity5Level1Stage3(
        key: stage513Key,
        onNextStage: goToNextActivity,
      ),
Activity5Level1Stage4(
        key: stage514Key,
        onNextStage: goToNextActivity,
      ),
Activity5Level1Stage5(
        key: stage515Key,
        onNextStage: goToNextActivity,
      ),

    ];
  }

  void repeatCurrentSound() {
    if (currentActivityIndex == 0) {
     stage111Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 1) {
     stage112Key.currentState?.repeatSound();
    }
     else if (currentActivityIndex == 2) {
     stage121Key.currentState?.repeatSound();
    }
    else if (currentActivityIndex == 3) {
     stage122Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 4) {
     stage131Key.currentState?.repeatSound();
    }
   else if (currentActivityIndex == 5) {
     stage132Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 6) {
     stage141Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 7) {
     stage142Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 8) {
     stage151Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 9) {
     stage211Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 10) {
     stage212Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 11) {
     stage311Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 12) {
     stage411Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 13) {
     stage412Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 14) {
     stage413Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 15) {
     stage511Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 16) {
     stage512Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 17) {
     stage513Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 18) {
     stage514Key.currentState?.repeatSound();
    }
else if (currentActivityIndex == 19) {
     stage515Key.currentState?.repeatSound();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ده أول نشاط بالفعل!")),
        );
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
                context, AppRoutes.childScreenRouteName),
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
          InkWell(
            onTap: goToNextActivity,
            child: Center(
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
