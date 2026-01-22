import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/widgets/routine_item.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../utils/app_styles.dart';
import '../../../../../../../providers/app_language_provider.dart';

class EveningRoutine extends StatefulWidget {
  final ValueChanged<int> onProgressChanged;

  const EveningRoutine({super.key, required this.onProgressChanged});

  @override
  State<EveningRoutine> createState() => _EveningRoutineState();
}

class _EveningRoutineState extends State<EveningRoutine> {
  bool isDinner = false;
  bool isStoriesTime = false;
  bool isBedTimeRoutine = false;
  bool isBedTime = false;

  void _updateProgress() {
    final doneCount = [
      isDinner,
      isStoriesTime,
      isBedTimeRoutine,
      isBedTime,
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
            Image(image: AssetImage(AppAssets.evening_icon), color: AppColors.softBlue),
            SizedBox(width: width * .02),
            Text(AppLocalizations.of(context)!.evening_routine, style: AppStyles.medium20Black),
          ],
        ),
        SizedBox(height: height * .02),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(height: height * .02),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return RoutineItem(
                  isDone: isDinner,
                  title: AppLocalizations.of(context)!.dinner_time,
                  time: '6:00 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.lightPastelBlue,
                  image:languageProvider.isArabic()?AppAssets.dinner_time_arabic: AppAssets.dinner_time,
                  onTap: () => setState(() {
                    isDinner = !isDinner;
                    _updateProgress();
                  }),
                );
              case 1:
                return RoutineItem(
                  isDone: isStoriesTime,
                  title: AppLocalizations.of(context)!.stories_time,
                  time: '7:00 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.pastelPink,
                  image:languageProvider.isArabic()?AppAssets.stories_time_arabic: AppAssets.stories_time,
                  onTap: () => setState(() {
                    isStoriesTime = !isStoriesTime;
                    _updateProgress();
                  }),
                );
              case 2:
                return RoutineItem(
                  isDone: isBedTimeRoutine,
                  title: AppLocalizations.of(context)!.bed_time_routine,
                  time: '8:30 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.softBlue,
                  image:languageProvider.isArabic()?AppAssets.bed_time_routine_arabic: AppAssets.bed_time_routine,
                  onTap: () => setState(() {
                    isBedTimeRoutine = !isBedTimeRoutine;
                    _updateProgress();
                  }),
                );
              case 3:
                return RoutineItem(
                  isDone: isBedTime,
                  title: AppLocalizations.of(context)!.bed_time,
                  time: '10:00 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.mintGreen,
                  image:languageProvider.isArabic()?AppAssets.bed_time_arabic: AppAssets.bed_time,
                  onTap: () => setState(() {
                    isBedTime = !isBedTime;
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
