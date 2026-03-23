import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class WellDoneCard extends StatelessWidget {
  const WellDoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * .2,
              vertical: height * .02,
            ),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.starImage),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.well_done,
                  style: AppStyles.bold20BlackWithOpacity60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
