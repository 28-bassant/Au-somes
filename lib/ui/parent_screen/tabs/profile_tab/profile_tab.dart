import 'package:au_somes/ui/parent_screen/tabs/profile_tab/widget/profile_item.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../core/cache/token_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';

class ProfileTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.all(width*.05),
          child: Column(
            children: [
              Image(image: AssetImage(AppAssets.childAvatar,)),
              SizedBox(height: height*.01),
              Text("sila Mohammed",style: AppStyles.bold20SoftBlue,),
              Text("8 years",style: AppStyles.bold20SoftBlue,),
              SizedBox(height: height*.05,),
              Container(
                margin:  EdgeInsets.symmetric(vertical: height*.007),
                padding: EdgeInsets.symmetric(horizontal:  width*.05,vertical: height*.03),
                decoration: BoxDecoration(
                  border: Border.all(width: 2,color: AppColors.softBlue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ProfileItem(text: AppLocalizations.of(context)!.edit_profile, image:AppAssets.editIcon),
                    SizedBox(height: height*.03,),
                    ProfileItem(text: AppLocalizations.of(context)!.reset_password, image:AppAssets.resetIcon),
                    SizedBox(height: height*.03),
                    ProfileItem(text: AppLocalizations.of(context)!.frequently_asked_questions, image:AppAssets.frequentlyQuestionIcon)
                    ,SizedBox(height: height*.03,),
                    ProfileItem(text: AppLocalizations.of(context)!.about_us, image:AppAssets.aboutIcon),
                    SizedBox(height: height*.03),
                    ProfileItem(text: AppLocalizations.of(context)!.review_au_somes, image:AppAssets.reviewIcon),
                    SizedBox(height: height*.03),
                    ProfileItem(text: AppLocalizations.of(context)!.logout, image:AppAssets.logoutIcon,
                      onPressed:() async {
                        await TokenUtils.clearTokens();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.loginScreenRouteName,
                              (route) => false,
                        );
                      }, ),
                  ],
                ),
              ),

            ],
          ),
        )
    );
  }
}