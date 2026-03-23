import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/l10n/app_localizations_ar.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget{
  Color containerColor;
  String icon;
  String text1;
  String text2;
  String text3;
  TextStyle? text1Style;
  TextStyle? text2Style;
  TextStyle? text3Style;
  Color smallContainerColor;
  ProgressWidget({
    required this.containerColor,
    required this.icon,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.smallContainerColor,
    this.text1Style,
    this.text2Style,
    this.text3Style,
});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width * .45,
      padding: EdgeInsets.symmetric(
        horizontal: width * .04,
        vertical: height*.02
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16)
      ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Image(image: AssetImage(icon)),
             Container(
               padding: EdgeInsets.symmetric(
                 horizontal: width * .02
               ),
               decoration: BoxDecoration(
                 color: smallContainerColor,
                 borderRadius: BorderRadius.circular(16)
               ),
               child: Text(text1,style:text1Style?? AppStyles.regular14White,),
             )
           ],
    ),
         SizedBox(
           height: height * .01,
         ),
         Text(text2,style:text2Style?? AppStyles.regular16White,),
         SizedBox(
           height: height * .01,
         ),
         Text(text3,style:text3Style?? AppStyles.bold24White,)
       ],
     ),
    );
  }
}