
import 'package:au_somes/ui/child_screen/visual_spatial_perception/geoboard_activities/Level1/geoboard_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/mental_cutting_activities/Level1/mental_cutting_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/room_arrangement_activities/Level1/room_arrangement_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/room_arrangement_activities/Level1/room_arrangement_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/room_arrangement_activities/Level2/room_arrangement_level2_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/tower_building_activities/Level1/tower_building_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/tower_building_activities/Level1/tower_building_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/tower_building_activities/Level2/tower_building_level2_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/tower_building_activities/Level2/tower_building_level2_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/tower_building_activities/Level3/tower_building_level3_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/tower_building_activities/Level3/tower_building_level3_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/shape_and_shapow_avtivites/level1/shape_and_shadow_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/shape_and_shapow_avtivites/level1/shape_and_shadow_level1_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/shape_and_shapow_avtivites/level2/shape_and_shadow_level2_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/shape_and_shapow_avtivites/level2/shape_and_shadow_level2_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/shape_and_shapow_avtivites/level3/shape_and_shadow_level3_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/shape_and_shapow_avtivites/level3/shape_and_shadow_level3_stage2.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/visual_closure/level1/visual_closure_level1_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/visual_closure/level2/visual_closure_level2_stage1.dart';
import 'package:au_somes/ui/child_screen/visual_spatial_perception/visual_closure/level3/visual_closure_level3_stage1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_assets.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_routes.dart';
import '../reinforcement_widgets/confetti_overlay.dart';
import 'geoboard_activities/Level1/geoboard_level1_stage2.dart';
import 'geoboard_activities/Level2/geoboard_level2_stage1.dart';
import 'geoboard_activities/level3/geoboard_level3_stage1.dart';
import 'mental_cutting_activities/Level2/mental_cutting_level2_stage1.dart';
import 'mental_cutting_activities/Level3/mental_cutting_level3_stage1.dart';
import 'mental_cutting_activities/Level3/mental_cutting_level3_stage2.dart';
import 'mental_cutting_activities/Level3/mental_cutting_level3_stage3.dart';


class VisualSpatialPerceptionBaseScreen extends StatefulWidget {
  @override
  VisualSpatialPerceptionBaseScreenState createState() =>
      VisualSpatialPerceptionBaseScreenState();
}

class VisualSpatialPerceptionBaseScreenState extends State<VisualSpatialPerceptionBaseScreen> {
  final room_arrangement11Key = GlobalKey<RoomArrangementLevel1Stage1State>();
  final room_arrangement12Key = GlobalKey<RoomArrangementLevel1Stage2State>();
  final room_arrangement21Key = GlobalKey<RoomArrangementLevel2Stage1State>();
  final tower_building11Key = GlobalKey<TowerBuildingLevel1Stage1State>();
  final tower_building12Key = GlobalKey<TowerBuildingLevel1Stage2State>();
  final tower_building21Key = GlobalKey<TowerBuildingLevel2Stage1State>();
  final tower_building22Key = GlobalKey<TowerBuildingLevel2Stage2State>();
  final tower_building31Key = GlobalKey<TowerBuildingLevel3Stage1State>();
  final tower_building32Key = GlobalKey<TowerBuildingLevel3Stage2State>();
  final mental_cutting11Key = GlobalKey<MentalCuttingLevel1Stage1State>();
  final mental_cutting21Key = GlobalKey<MentalCuttingLevel2Stage1State>();
  final mental_cutting31Key = GlobalKey<MentalCuttingLevel3Stage1State>();
  final mental_cutting32Key = GlobalKey<MentalCuttingLevel3Stage2State>();
  final mental_cutting33Key = GlobalKey<MentalCuttingLevel3Stage3State>();
  final geoboard11Key = GlobalKey<GeoboardLevel1Stage1State>();
  final geoboard12Key = GlobalKey<GeoboardLevel1Stage2State>();
  final geoboard21Key = GlobalKey<GeoboardLevel2Stage1State>();
  final geoboard22Key = GlobalKey<GeoboardLevel3Stage1State>();
  final shape_and_shadow_12Key = GlobalKey<ShapeAndShadowLevel1Stage1State>();
  final shape_and_shadow_13Key = GlobalKey<ShapeAndShadowLevel1Stage2State>();
  final shape_and_shadow_14Key = GlobalKey<ShapeAndShadowLevel2Stage1State>();
  final shape_and_shadow_15Key = GlobalKey<ShapeAndShadowLevel2Stage2State>();
  final shape_and_shadow_16Key = GlobalKey<ShapeAndShadowLevel3Stage1State>();
  final shape_and_shadow_17Key = GlobalKey<ShapeAndShadowLevel3Stage2State>();
  final visual_closure_18Key = GlobalKey<VisualClosureLevel1Stage1State>();
  final visual_closure_19Key = GlobalKey<VisualClosureLevel2Stage1State>();
  final visual_closure_20Key = GlobalKey<VisualClosureLevel3Stage1State>();
  late final List<Widget> activities;
  int currentActivityIndex = 0;

  void goToActivity(int index) {
    setState(() {
      currentActivityIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    activities = [
      ShapeAndShadowLevel1Stage1(
        key: shape_and_shadow_12Key,
        onNextStage: goToNextActivity,
      ),ShapeAndShadowLevel1Stage2(
        key: shape_and_shadow_13Key,
        onNextStage: goToNextActivity,
      ),ShapeAndShadowLevel2Stage1(
        key: shape_and_shadow_14Key,
        onNextStage: goToNextActivity,
      ),ShapeAndShadowLevel2Stage2(
        key: shape_and_shadow_15Key,
        onNextStage: goToNextActivity,
      ),ShapeAndShadowLevel3Stage1(
        key: shape_and_shadow_16Key,
        onNextStage: goToNextActivity,
      ),ShapeAndShadowLevel3Stage2(
        key: shape_and_shadow_17Key,
        onNextStage: goToNextActivity,
      ),
      VisualClosureLevel1Stage1(
        key: visual_closure_18Key,
        onNextStage: goToNextActivity,
      ),VisualClosureLevel2Stage1(
        key: visual_closure_19Key,
        onNextStage: goToNextActivity,
      ),VisualClosureLevel3Stage1(
        key: visual_closure_20Key,
        onNextStage: goToNextActivity,
      ),
      TowerBuildingLevel1Stage1(
        key: tower_building11Key,
        onNextStage: goToNextActivity,
      ),
      TowerBuildingLevel1Stage2(
        key: tower_building12Key,
        onNextStage: goToNextActivity,
      ),
      TowerBuildingLevel2Stage1(
        key: tower_building21Key,
        onNextStage: goToNextActivity,
      ),
      TowerBuildingLevel2Stage2(
        key: tower_building22Key,
        onNextStage: goToNextActivity,
      ),
      TowerBuildingLevel3Stage1(
        key: tower_building31Key,
        onNextStage: goToNextActivity,
      ),
      TowerBuildingLevel3Stage2(
        key: tower_building32Key,
        onNextStage: goToNextActivity,
      ),
      RoomArrangementLevel1Stage1(
        key: room_arrangement11Key,
        onNextStage: goToNextActivity,
      ),
      RoomArrangementLevel1Stage2(
        key: room_arrangement12Key,
        onNextStage: goToNextActivity,
      ),
      RoomArrangementLevel2Stage1(
        key: room_arrangement21Key,
        onNextStage: goToNextActivity,
      ),

      MentalCuttingLevel1Stage1(
        key: mental_cutting11Key,
        onNextStage: goToNextActivity,
      ),
      MentalCuttingLevel2Stage1(
        key: mental_cutting21Key,
        onNextStage: goToNextActivity,
      ),
      MentalCuttingLevel3Stage1(
        key: mental_cutting31Key,
        onNextStage: goToNextActivity,
      ),
      MentalCuttingLevel3Stage2(
        key: mental_cutting32Key,
        onNextStage: goToNextActivity,
      ),
      MentalCuttingLevel3Stage3(
        key: mental_cutting33Key,
        onNextStage: goToNextActivity,
      ),
      GeoboardLevel1Stage1(
        key: geoboard11Key,
        onNextStage: goToNextActivity,
      ),
      GeoboardLevel1Stage2(
        key: geoboard12Key,
        onNextStage: goToNextActivity,
      ),
      GeoboardLevel2Stage1(
        key: geoboard21Key,
        onNextStage: goToNextActivity,
      ),GeoboardLevel3Stage1(
        key: geoboard22Key,
        onNextStage: goToNextActivity,
      ),


    ];
  }

  void repeatCurrentSound() {
    if (currentActivityIndex == 0) {
       shape_and_shadow_12Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 1) {
       shape_and_shadow_13Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 2) {
       shape_and_shadow_14Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 3) {
       shape_and_shadow_15Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 4) {
      shape_and_shadow_16Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 5) {
       shape_and_shadow_17Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 6) {
       visual_closure_18Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 7) {
       visual_closure_19Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 8) {
       visual_closure_20Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 9) {
      tower_building11Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 10) {
      tower_building12Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 11) {
      tower_building21Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 12) {
      tower_building22Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 13) {
      tower_building31Key.currentState?.repeatSound();
    }else if (currentActivityIndex == 14) {
      tower_building32Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 15) {
      room_arrangement11Key.currentState?.repeatSound();
    } else if (currentActivityIndex == 16) {
      room_arrangement12Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 17) {
      room_arrangement21Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 18) {
      mental_cutting11Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 19) {
      mental_cutting21Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 20) {
      mental_cutting31Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 21) {
      mental_cutting32Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 22) {
      mental_cutting33Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 23) {
      geoboard11Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 24) {
      geoboard12Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 25) {
      geoboard21Key.currentState?.repeatSound();
    }  else if (currentActivityIndex == 26) {
      // geoboard22Key.currentState?.repeatSound();
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
                       Icons.arrow_back
                      ,
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
