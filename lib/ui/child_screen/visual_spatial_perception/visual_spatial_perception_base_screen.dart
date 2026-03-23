
import 'package:au_somes/ui/child_screen/visual_spatial_perception/room_arrangement_activities/Level1/room_arrangement_level1_stage1.dart';
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


class VisualSpatialPerceptionBaseScreen extends StatefulWidget {
  @override
  _VisualSpatialPerceptionBaseScreenState createState() =>
      _VisualSpatialPerceptionBaseScreenState();
}

class _VisualSpatialPerceptionBaseScreenState extends State<VisualSpatialPerceptionBaseScreen> {
  final room_arrangement11Key = GlobalKey<RoomArrangementLevel1Stage1State>();
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

  @override
  void initState() {
    super.initState();
    activities = [
      RoomArrangementLevel1Stage1(
        key: room_arrangement11Key,
        onNextStage: goToNextActivity,
      ),ShapeAndShadowLevel1Stage1(
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
      ),VisualClosureLevel1Stage1(
        key: visual_closure_18Key,
        onNextStage: goToNextActivity,
      ),VisualClosureLevel2Stage1(
        key: visual_closure_19Key,
        onNextStage: goToNextActivity,
      ),VisualClosureLevel3Stage1(
        key: visual_closure_20Key,
        onNextStage: goToNextActivity,
      )




    ];
  }

  void repeatCurrentSound() {
    if (currentActivityIndex == 0) {
      room_arrangement11Key.currentState?.repeatSound();
    } if (currentActivityIndex == 1) {
      shape_and_shadow_12Key.currentState?.repeatSound();
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
