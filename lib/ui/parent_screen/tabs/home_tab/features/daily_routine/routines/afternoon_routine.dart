import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_routine/widgets/routine_item.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../utils/app_styles.dart';
import '../../../../../../../providers/app_language_provider.dart';

class AfternoonRoutine extends StatefulWidget {
  final ValueChanged<int> onProgressChanged;

  const AfternoonRoutine({super.key, required this.onProgressChanged});

  @override
  State<AfternoonRoutine> createState() => _AfternoonRoutineState();
}

class _AfternoonRoutineState extends State<AfternoonRoutine> {
  bool isLunch = false;
  bool isNap = false;
  bool isInteractiveActivities = false;

  void _updateProgress() {
    final doneCount = [
      isLunch,
      isNap,
      isInteractiveActivities,
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
            Image(image: AssetImage(AppAssets.afternoon_icon), color: AppColors.softBlue),
            SizedBox(width: width * .02),
            Text(AppLocalizations.of(context)!.afternoon_routine, style: AppStyles.medium20Black),
          ],
        ),
        SizedBox(height: height * .02),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => SizedBox(height: height * .02),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return RoutineItem(
                  isDone: isLunch,
                  title: AppLocalizations.of(context)!.lunch_time,
                  time: '1:00 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.mintGreen,
                  image:languageProvider.isArabic()?AppAssets.lunch_time_arabic: AppAssets.lunch_time,
                  onTap: () => setState(() {
                    isLunch = !isLunch;
                    _updateProgress();
                  }),
                );
              case 1:
                return RoutineItem(
                  isDone: isNap,
                  title: AppLocalizations.of(context)!.nap,
                  time: '2:00 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.softBlue,
                  image:languageProvider.isArabic()?AppAssets.nap_arabic: AppAssets.nap,
                  onTap: () => setState(() {
                    isNap = !isNap;
                    _updateProgress();
                  }),
                );
              case 2:
                return RoutineItem(
                  isDone: isInteractiveActivities,
                  title: AppLocalizations.of(context)!.interactive_activity,
                  time: '3:00 ${AppLocalizations.of(context)!.pm}',
                  color: AppColors.pastelPink,
                  image:languageProvider.isArabic()?AppAssets.interactive_activities_arabic: AppAssets.interactive_activities,
                  onTap: () => setState(() {
                    isInteractiveActivities = !isInteractiveActivities;
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
