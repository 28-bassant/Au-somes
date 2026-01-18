import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../../../../utils/app_colors.dart';
import 'package:flutter/material.dart';
class BotMessage extends StatelessWidget {
   String text;
   BotMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius:18,
          backgroundColor: AppColors.softBlue,
          child: Image.asset(AppAssets.chatbotImage,
            width: 40,
          ),
        ),
        SizedBox(width:width* .02),
        Flexible(
          child: Align(
            alignment:languageProvider.isArabic()?Alignment.centerRight: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(width * .03),
              margin: EdgeInsets.only(
                right:languageProvider.isArabic()? 0: width * .08,
                left:languageProvider.isArabic()? width * .08 :0  ,
              ),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(topLeft:Radius.circular(16),bottomLeft:languageProvider.isArabic()?Radius.circular(16):Radius.circular(0),
                    topRight: Radius.circular(16),bottomRight:languageProvider.isArabic()? Radius.circular(0):Radius.circular(16) ),
              ),
              child:ExpandableText(
                text,
                expandText: AppLocalizations.of(context)!.show_more,
                collapseText:AppLocalizations.of(context)!.show_less,
                maxLines: 7,
                linkColor: AppColors.blackColor,
                linkStyle: AppStyles.bold14Black,
                style: AppStyles.medium16Black
              ),
            ),
          ),
        ),
      ],
    );
  }
}