import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';
import '../../../../../../../utils/app_colors.dart';
import 'package:flutter/material.dart';
class BotMessage extends StatelessWidget {
   String text;
   BotMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
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
          child: Container(
            padding: EdgeInsets.all(width*.03),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.only(topLeft:Radius.circular(16),bottomLeft:Radius.circular(1),
                  topRight: Radius.circular(16),bottomRight: Radius.circular(16) ),
            ),
            child: Text(
              text,
              style:AppStyles.bold16White
            ),
          ),
        ),
      ],
    );
  }
}