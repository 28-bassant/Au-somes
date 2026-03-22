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
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity6/level1/activity6_level1_stag4.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity6/level1/activity6_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity6/level1/activity6_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity6/level1/activity6_level1_stage3.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity6/level1/activity6_level1_stage5.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/Activity6/level1/activity6_level1_stage6.dart';
import 'package:au_somes/ui/child_screen/spatial_relations/spatial_relations_activities/activity7/level1/activity7_level1_stag1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/room_arrangement_activities/Level1/room_arrangement_level1_stage1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_assets.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_routes.dart';
import '../reinforcement_widgets/confetti_overlay.dart';


class VisualSpatialPerceptionBaseScreen extends StatefulWidget {
  @override
  _VisualSpatialPerceptionBaseScreenState createState() =>
      _VisualSpatialPerceptionBaseScreenState();
}

class _VisualSpatialPerceptionBaseScreenState extends State<VisualSpatialPerceptionBaseScreen> {
  final room_arrangement11Key = GlobalKey<RoomArrangementLevel1Stage1State>();




  late final List<Widget> activities;
  int currentActivityIndex = 0;

  @override
  void initState() {
    super.initState();
    activities = [
      RoomArrangementLevel1Stage1(
        key: room_arrangement11Key,
        onNextStage: goToNextActivity,
      ),

    ];
  }

  void repeatCurrentSound() {
    if (currentActivityIndex == 0) {
      room_arrangement11Key.currentState?.repeatSound();
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
              AppRoutes.childScreenRouteName,
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
