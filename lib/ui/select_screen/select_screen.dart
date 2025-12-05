
import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/select_screen/selecting_box_widget.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class SelectScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body : Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * .2,),
              SelectingBoxWidget(
                  image: AppAssets.parentImage,
                  text: AppLocalizations.of(context)!.parent,
                  textStyle: AppStyles.extraBold24PastelPink,
                  onTapFunction: () {
                    //todo : Navigate to Parent Screen
                    Navigator.pushNamed(context, AppRoutes.parentScreenRouteName);
                  },
              ),
              SizedBox(height: height * .04,),
              SelectingBoxWidget(
                  image: AppAssets.childImage,
                  text: AppLocalizations.of(context)!.child,
                  textStyle: AppStyles.extraBold24MintGreen,
                  onTapFunction: () {
                    //todo : Navigate to Child Screen
                    Navigator.pushNamed(context, AppRoutes.childScreenRouteName);
                  },
              ),
          
            ],
          ),
        ),
      )
    );
  }
}