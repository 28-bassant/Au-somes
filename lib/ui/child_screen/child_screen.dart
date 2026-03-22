import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/child_screen/widget/acticites_widget.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../core/cache/token_utils.dart';

class ChildScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final name = TokenUtils.getChildName();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.selectScreenRouteName);
          },
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: width * .04),
        child: Column(
          children: [
            Row(
              children: [
                Text('${AppLocalizations.of(context)!.hi} $name !',style: AppStyles.bold24BlackWithOpacity60,),
                SizedBox(width: width * .02,),
                Image(image: AssetImage(AppAssets.hi_icon))
              ],
            ),
            SizedBox(height: height * .04,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActivitiesWidget(
                    image: AppAssets.spatial_relations,
                    text: AppLocalizations.of(context)!.spatial_relations,
                    onPressed: () {
                      //todo : Navigate to Spatial Relations
                      Navigator.pushNamed(context, AppRoutes.spatialRelationsActivitiesBaseScreenRouteName);

                    },),
                SizedBox(width: width * .02,),
                ActivitiesWidget(
                    image: AppAssets.spatial_concepts,
                    text: AppLocalizations.of(context)!.spatial_concepts,
                    onPressed: () {
                      //todo : Navigate to Spatial Concepts
                      Navigator.pushNamed(context, AppRoutes.spatialConceptsScreenRouteName);
                    },),
              ],
            ),
            SizedBox(height: height * .02,),
            ActivitiesWidget(
              image: AppAssets.visual_spatial_perception,
              text: AppLocalizations.of(context)!.visual_spatial_perception,
              onPressed: () {
                //todo : Navigate to Visual Spatial Perception
                Navigator.pushNamed(context, AppRoutes.visualSpatialPerceptionScreenRouteName);
              },),

          ],
        ),
      ),
    );
  }
}