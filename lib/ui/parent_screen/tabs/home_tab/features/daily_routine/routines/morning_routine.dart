import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/widgets/routine_item.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../utils/app_styles.dart';

class MorningRoutine extends StatefulWidget {
  final ValueChanged<int> onProgressChanged;

  const MorningRoutine({super.key, required this.onProgressChanged});

  @override
  State<MorningRoutine> createState() => _MorningRoutineState();
}

class _MorningRoutineState extends State<MorningRoutine> {
  bool isWakeUpDone = false;
  bool isMorningHygiene = false;
  bool isBreakfastTime = false;
  bool isQuietTime = false;
  bool isSchoolWork = false;
  bool isSnackTime = false;
  bool isPhysicalActivity = false;

  void _updateProgress() {
    final doneCount = [
      isWakeUpDone,
      isMorningHygiene,
      isBreakfastTime,
      isQuietTime,
      isSchoolWork,
      isSnackTime,
      isPhysicalActivity,
    ].where((e) => e).length;

    widget.onProgressChanged(doneCount);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image(image: AssetImage(AppAssets.morning_icon), color: AppColors.softBlue),
            SizedBox(width: width * .02),
            Text(AppLocalizations.of(context)!.morning_routine, style: AppStyles.medium20Black),
          ],
        ),
        SizedBox(height: height * .02),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7,
          separatorBuilder: (_, __) => SizedBox(height: height * .02),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return RoutineItem(
                  isDone: isWakeUpDone,
                  title:AppLocalizations.of(context)!.wake_up,
                  time: '7:00 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.mintGreen,
                  image:languageProvider.isArabic()?AppAssets.wake_up_arabic: AppAssets.wake_up,
                  onTap: () => setState(() {
                    isWakeUpDone = !isWakeUpDone;
                    _updateProgress();
                  }),
                );
              case 1:
                return RoutineItem(
                  isDone: isMorningHygiene,
                  title: AppLocalizations.of(context)!.morning_hygiene,
                  time: '7:15 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.lightPastelBlue,
                  image:languageProvider.isArabic()?AppAssets.morning_hygiene_arabic: AppAssets.morning_hygiene,
                  onTap: () => setState(() {
                    isMorningHygiene = !isMorningHygiene;
                    _updateProgress();
                  }),
                );
              case 2:
                return RoutineItem(
                  isDone: isBreakfastTime,
                  title: AppLocalizations.of(context)!.breakfast_time,
                  time: '7:30 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.pastelPink,
                  image:languageProvider.isArabic()?AppAssets.breakfast_arabic: AppAssets.breakfast_time,
                  onTap: () => setState(() {
                    isBreakfastTime = !isBreakfastTime;
                    _updateProgress();
                  }),
                );
              case 3:
                return RoutineItem(
                  isDone: isQuietTime,
                  title: AppLocalizations.of(context)!.quiet_time,
                  time: '8:00 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.mintGreen,
                  image:languageProvider.isArabic()?AppAssets.quiet_time_arabic: AppAssets.quiet_time,
                  onTap: () => setState(() {
                    isQuietTime = !isQuietTime;
                    _updateProgress();
                  }),
                );
              case 4:
                return RoutineItem(
                  isDone: isSchoolWork,
                  title: AppLocalizations.of(context)!.school_work,
                  time: '9:00 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.softBlue,
                  image:languageProvider.isArabic()?AppAssets.school_work_arabic: AppAssets.school_work,
                  onTap: () => setState(() {
                    isSchoolWork = !isSchoolWork;
                    _updateProgress();
                  }),
                );
              case 5:
                return RoutineItem(
                  isDone: isSnackTime,
                  title: AppLocalizations.of(context)!.snack_time,
                  time: '10:00 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.pastelPink,
                  image:languageProvider.isArabic()?AppAssets.snack_arabic: AppAssets.snack_time,
                  onTap: () => setState(() {
                    isSnackTime = !isSnackTime;
                    _updateProgress();
                  }),
                );
              case 6:
                return RoutineItem(
                  isDone: isPhysicalActivity,
                  title: AppLocalizations.of(context)!.physical_activity,
                  time: '10:30 ${AppLocalizations.of(context)!.am}',
                  color: AppColors.softBlue,
                  image:languageProvider.isArabic()?AppAssets.physical_activity_arabic: AppAssets.physical_activity,
                  onTap: () => setState(() {
                    isPhysicalActivity = !isPhysicalActivity;
                    _updateProgress();
                  }),
                );
              default:
                return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}
