import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomLanguageWidget extends StatefulWidget{
  @override
  State<CustomLanguageWidget> createState() => _CustomLanguageWidgetState();
}

class _CustomLanguageWidgetState extends State<CustomLanguageWidget> {
  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    return InkWell(
      onTap: () {
        //todo : Change Language
        languageProvider.appLanguage == 'en' ? languageProvider.changeLanguage('ar'):languageProvider.changeLanguage('en');
        setState(() {

        });

      },
      child: Container(

        child: Text(
          languageProvider.appLanguage == 'en'?'AR' : 'En'
          ,style: AppStyles.medium16BlackWithOpacity60,),
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8),
          border:Border.all(
            color: AppColors.softBlue,
            width: 1
          )

        ),
      ),
    );
  }
}