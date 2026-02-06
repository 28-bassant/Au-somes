import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/near_and_far_activities/level1/near_far_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/near_and_far_activities/level2/near_far_level2_stage2.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_colors.dart';
import 'level1/near_far_level1_stage2.dart';
import 'level1/near_far_level1_stage3.dart';
import 'level1/near_far_level1_stage4.dart';
import 'level2/near_far_level2_stage1.dart';
import 'level2/near_far_level2_stage3.dart';
import 'level2/near_far_level2_stage4.dart';


class NearFarBaseActivityScreen extends StatefulWidget {
  @override
  _NearFarBaseActivityScreenState createState() =>
      _NearFarBaseActivityScreenState();
}

class _NearFarBaseActivityScreenState extends State<NearFarBaseActivityScreen> {
  final stage11Key = GlobalKey<NearFarLevel1Stage1State>();
  final stage12Key = GlobalKey<NearFarLevel1Stage2State>();
  final stage13Key = GlobalKey<NearFarLevel1Stage3State>();
  final stage14Key = GlobalKey<NearFarLevel1Stage4State>();
  final stage21Key = GlobalKey<NearFarLevel2Stage1State>();
  final stage22Key = GlobalKey<NearFarLevel2Stage2State>();
  final stage23Key = GlobalKey<NearFarLevel2Stage3State>();
  final stage24Key = GlobalKey<NearFarLevel2Stage4State>();



  late final List<Widget> activities;
  int currentActivityIndex = 0;

  @override
  void initState() {
    super.initState();
    activities = [
      NearFarLevel1Stage1(
        key: stage11Key,
        onNextStage: goToNextActivity,
      ),
       NearFarLevel1Stage2(
        key: stage12Key,
        onNextStage: goToNextActivity,
      ),
      NearFarLevel1Stage3(
        key: stage13Key,
        onNextStage: goToNextActivity,
      ),

      NearFarLevel1Stage4(
        key: stage14Key,
        onNextStage: goToNextActivity,
      ),
      NearFarLevel2Stage1(
        key: stage21Key,
        onNextStage: goToNextActivity,
      ),
      NearFarLevel2Stage2(
        key: stage22Key,
        onNextStage: goToNextActivity,
      ),
      NearFarLevel2Stage3(
        key: stage23Key,
        onNextStage: goToNextActivity,
      ),
     NearFarLevel2Stage4(
        key: stage24Key,
        onNextStage: goToNextActivity,
      ),


    ];
  }


  void repeatCurrentSound() {
    if (currentActivityIndex == 0) {
      stage11Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 1) {
      stage12Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 2) {
      stage13Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 3) {
      stage14Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 4) {
      stage21Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 5) {
      stage22Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 5) {
      stage23Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 6) {
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
          InkWell(
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.spatialConceptsScreenRouteName),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.blackColorWithOpacity60, width: 1),
              ),
              child: Icon(
                Icons.home_outlined,
                color: AppColors.blackColorWithOpacity60,
                size: 25,
              ),
            ),
          ),
        ],
        leading: InkWell(
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
                  border: Border.all(color: AppColors.blackColorWithOpacity60, width: 1),
                ),
                child: Icon(
                  languageProvider.isArabic() ? Icons.arrow_forward : Icons.arrow_back,
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
