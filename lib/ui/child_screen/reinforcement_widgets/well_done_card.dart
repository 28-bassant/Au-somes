import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/sound_helper.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class WellDoneCard extends StatefulWidget {
  final bool visible;

  const WellDoneCard({super.key, required this.visible});

  @override
  State<WellDoneCard> createState() => _WellDoneCardState();
}

class _WellDoneCardState extends State<WellDoneCard> {
  bool _played = false;

  @override
  void didUpdateWidget(covariant WellDoneCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible && !_played) {
      SoundHelper.playSuccess();
      _played = true;
    }

    if (!widget.visible) {
      _played = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (!widget.visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Material(
        color: AppColors.blackColor.withOpacity(0.3),
        child: Container(
          color: AppColors.blackColor.withOpacity(0.3),
          child: Center(
            child: AnimatedScale(
              scale: widget.visible ? 1 : 0.8,
              duration:  Duration(milliseconds: 400),
              child: Container(
                padding:  EdgeInsets.symmetric(
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
                     SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.well_done,
                      style: AppStyles.bold20BlackWithOpacity60
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
