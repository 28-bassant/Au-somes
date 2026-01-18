import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileItem extends StatelessWidget{
  String image;
  String text;
  final VoidCallback? onPressed;
  ProfileItem({super.key, required this.text ,this.onPressed,required this.image});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var languageProvider = Provider.of<AppLanguageProvider>(context);
   return InkWell(
     onTap: onPressed,
     child: Row(
       children: [
         Image(image: AssetImage(image)),
         SizedBox(width: width*.06),
         Text(text,style: AppStyles.bold16BlackWithOpacity60,),
         Spacer(),
         Image(image: AssetImage(languageProvider.isArabic()?AppAssets.arrowArabicIcon:AppAssets.arrowEnglishIcon,)),
       ],
     ),
   );
  }

}