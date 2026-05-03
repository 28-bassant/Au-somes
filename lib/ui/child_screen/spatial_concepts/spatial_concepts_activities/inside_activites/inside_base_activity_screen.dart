import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level1/front_back_level1_stage1_activity.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level1/front_back_level1_stage2_activity.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level2/front_back_level2_stage1_activity.dart';
import 'package:au_somes/ui/child_screen/spatial_concepts/spatial_concepts_activities/front_and_back_activities/level2/front_back_level2_stage3_activity.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../main.dart';
import '../../../../../providers/app_language_provider.dart';
import '../../../../../utils/app_colors.dart';
import '../../../reinforcement_widgets/confetti_overlay.dart';
import 'level1/inside_level1_stage1_activity.dart';
import 'level1/inside_level1_stage2_activity.dart';
import 'level1/inside_level1_stage3_activity.dart';
import 'level1/inside_level1_stage4_activity.dart';
import 'level2/inside_level2_stage1_activity.dart';
import 'level2/inside_level2_stage2_activity.dart';
import 'level2/inside_level2_stage3_activity.dart';
import 'level2/inside_level2_stage4_activity.dart';

class InsideBaseActivityScreen extends StatefulWidget {
  @override
  _InsideBaseActivityScreenState createState() =>
      _InsideBaseActivityScreenState();
}

class _InsideBaseActivityScreenState extends State<InsideBaseActivityScreen> with RouteAware {
  final stage11Key = GlobalKey<InsideLevel1Stage1ActivityState>();
  final stage12Key = GlobalKey<InsideLevel1Stage2ActivityState>();
  final stage13Key = GlobalKey<InsideLevel1Stage3ActivityState>();
  final stage14Key = GlobalKey<InsideLevel1Stage4ActivityState>();
  final stage21Key = GlobalKey<InsideLevel2Stage1ActivityState>();
  final stage22Key = GlobalKey<InsideLevel2Stage2ActivityState>();
  final stage23Key = GlobalKey<InsideLevel2Stage3ActivityState>();
  final stage24Key = GlobalKey<InsideLevel2Stage4ActivityState>();

  late final List<Widget> activities;
  int currentActivityIndex = 0;

  @override
  void initState() {
    super.initState();
    activities = [
      InsideLevel1Stage1Activity(
        key: stage11Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel1Stage2Activity(
        key: stage12Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel1Stage3Activity(
        key: stage13Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel1Stage4Activity(
        key: stage14Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel2Stage1Activity(
        key: stage21Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel2Stage2Activity(
        key: stage22Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel2Stage3Activity(
        key: stage23Key,
        onNextStage: goToNextActivity,
      ),
      InsideLevel2Stage4Activity(
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

        Navigator.pushNamed(context, AppRoutes.outsideBaseActivityScreenRouteName);


      }
    });
  }

  void goToPreviousActivity() {
    setState(() {
      if (currentActivityIndex > 0) {
        currentActivityIndex--;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context)!.first_activity,
              style: AppStyles.regular16White,
            ),
            backgroundColor: AppColors.redColor,

            behavior: SnackBarBehavior.floating, // يخليه مش لازق في الشاشة

            margin: EdgeInsets.symmetric(
                horizontal: 34,
                vertical: 16
            ), // مسافة من كل الجهات

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // البوردر ريديوس
            ),
          ),

        );
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  void didPopNext() {
    final currentKey = activities[currentActivityIndex].key;

    // dynamic cast لكل State عنده resetActivity
    if (currentKey is GlobalKey) {
      final state = currentKey.currentState;
      if (state != null) {
        try {
          (state as dynamic).resetActivity(); // ✨ cast dynamic عشان Dart يسمح بالنداء
        } catch (e) {
          // لو State مش عنده resetActivity، نتجاهل
        }
      }
    }
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
            onTap: () => Navigator.pop(context),
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
                 Icons.arrow_back,
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
