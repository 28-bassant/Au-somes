import 'package:au_somes/ui/child_screen/spatial_concepts/widgets/activity_name.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';

class SpatialConceptsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPastelBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.blackColor),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.spatial_concepts,
          style: AppStyles.bold22Black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * .06,
          vertical: height * .02,
        ),
        child: Column(
          children: [
            ActivityName(
              image: AppAssets.above_and_under,
              text: AppLocalizations.of(context)!.above_under,
              icon: Icons.lock_outline,
              onPressed: () {
                //todo: Navigate to Above & Under Activities
              },
            ),
            SizedBox(height: height * .02),
            ActivityName(
              image: AppAssets.right_and_left,
              text: AppLocalizations.of(context)!.right_left,
              icon: Icons.lock_outline,
              onPressed: () {
                //todo: Navigate to Right & Left Activities
              },
            ),
            SizedBox(height: height * .02),
            ActivityName(
              image: AppAssets.inside_and_outside,
              text: AppLocalizations.of(context)!.inside_outside,
              icon: Icons.lock_open,
              onPressed: () {
                //todo: Navigate to Inside & Outside Activities
              },
            ),
            SizedBox(height: height * .02),
            ActivityName(
              image: AppAssets.near_and_far,
              text: AppLocalizations.of(context)!.near_far,
              icon: Icons.lock_outline,
              onPressed: () {
                //todo: Navigate to Near & Far Activities
              },
            ),
            SizedBox(height: height * .02),
            ActivityName(
              image: AppAssets.between,
              text: AppLocalizations.of(context)!.between,
              icon: Icons.lock_outline,
              onPressed: () {
                //todo: Navigate to Between Activities
              },
            ),
            SizedBox(height: height * .02),
          ],
        ),
      ),
    );
  }
}
