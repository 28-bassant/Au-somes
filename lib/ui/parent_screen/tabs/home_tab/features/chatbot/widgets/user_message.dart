import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../../../providers/app_language_provider.dart';
import '../../../../../../../utils/app_colors.dart';

class UserMessage extends StatelessWidget{
  String text;
  UserMessage({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    return Align(
      alignment:languageProvider.isArabic()?Alignment.centerLeft: Alignment.centerRight,
      child: Container(
        padding:  EdgeInsets.all(width*.03),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(topLeft:Radius.circular(16),bottomLeft:languageProvider.isArabic()?Radius.circular(0):Radius.circular(16),
              topRight: Radius.circular(16),bottomRight:languageProvider.isArabic()?Radius.circular(16): Radius.circular(0) ),
          border: Border.all(width: 1,color: AppColors.blackColorWithOpacity60),
        ),
        child: Text(
          text,
          style:AppStyles.medium14BlackWithOpacity60
        ),
      ),
    );

  }

}