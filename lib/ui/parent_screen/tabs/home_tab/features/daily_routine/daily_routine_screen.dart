import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/routines/afternoon_routine.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/routines/evening_routine.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/routines/morning_routine.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/widgets/time_widget.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/widgets/percent_linear_indicator.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_styles.dart';

class DailyRoutineScreen extends StatefulWidget {
  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  int selectedIndex = 0;

  int morningDone = 0;
  int afternoonDone = 0;
  int eveningDone = 0;

  final int morningTotal = 7;
  final int afternoonTotal = 3;
  final int eveningTotal = 4;

  Key routineKey = UniqueKey();

  double get morningPercent => morningDone / morningTotal;
  double get afternoonPercent => afternoonDone / afternoonTotal;
  double get eveningPercent => eveningDone / eveningTotal;

  @override
  void initState() {
    super.initState();
    _checkNewDay();
  }

  Future<void> _checkNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString('last_routine_date');

    if (lastDate != today) {
      _resetAllRoutines();
      await prefs.setString('last_routine_date', today);
    }
  }

  void _resetAllRoutines() {
    setState(() {
      morningDone = 0;
      afternoonDone = 0;
      eveningDone = 0;
      routineKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    int currentDone = 0;
    int currentTotal = 0;
    double currentPercent = 0;
    switch (selectedIndex) {
      case 0:
        currentDone = morningDone;
        currentTotal = morningTotal;
        currentPercent = morningPercent;
        break;
      case 1:
        currentDone = afternoonDone;
        currentTotal = afternoonTotal;
        currentPercent = afternoonPercent;
        break;
      case 2:
        currentDone = eveningDone;
        currentTotal = eveningTotal;
        currentPercent = eveningPercent;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPastelBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.blackColor),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.daily_routine,
          style: AppStyles.bold22Black,
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: height * .02),
            decoration: BoxDecoration(
              color: AppColors.lightPastelBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(54),
                bottomRight: Radius.circular(54),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PercentLinearIndicator(
                  activityName: AppLocalizations.of(context)!.current_progress,
                  activityPercent:
                  '$currentDone ${AppLocalizations.of(context)!.of_word} $currentTotal ${AppLocalizations.of(context)!.done}',
                  activityPercentStyle: AppStyles.medium16SoftBlue,
                  indicatorColor: AppColors.softBlue,
                  percent: currentPercent,
                  givenWidth: width * .5,
                  containerWidth: width * .6,
                ),
              ],
            ),
          ),

          SizedBox(height: height * .02),

          Container(
            padding: EdgeInsets.symmetric(
              vertical: height * .02,
              horizontal: width * .02,
            ),
            width: width * .7,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TimeWidget(
                  isSelected: selectedIndex == 0,
                  image: AppAssets.morning_icon,
                  text: AppLocalizations.of(context)!.morning,
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),
                TimeWidget(
                  isSelected: selectedIndex == 1,
                  image: AppAssets.afternoon_icon,
                  text: AppLocalizations.of(context)!.afternoon,
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
                TimeWidget(
                  isSelected: selectedIndex == 2,
                  image: AppAssets.evening_icon,
                  text: AppLocalizations.of(context)!.evening,
                  onPressed: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: height * .04),

          // Routine List
          Expanded(
            child: SingleChildScrollView(
              key: routineKey,
              padding: EdgeInsets.symmetric(horizontal: width * .04),
              child: selectedIndex == 0
                  ? MorningRoutine(
                onProgressChanged: (doneCount) {
                  setState(() {
                    morningDone = doneCount;
                  });
                },
              )
                  : selectedIndex == 1
                  ? AfternoonRoutine(
                onProgressChanged: (doneCount) {
                  setState(() {
                    afternoonDone = doneCount;
                  });
                },
              )
                  : EveningRoutine(
                onProgressChanged: (doneCount) {
                  setState(() {
                    eveningDone = doneCount;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: height * .02,)
        ],
      ),
    );
  }
}
