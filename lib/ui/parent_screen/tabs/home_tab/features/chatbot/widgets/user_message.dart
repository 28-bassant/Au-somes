import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../../../utils/app_colors.dart';

class UserMessage extends StatelessWidget{
  String text;
  UserMessage({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding:  EdgeInsets.all(width*.03),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(topLeft:Radius.circular(16),bottomLeft:Radius.circular(16),
              topRight: Radius.circular(16),bottomRight: Radius.circular(1) ),
          border: Border.all(width: 2,color: AppColors.softBlue),
        ),
        child: Text(
          text,
          style:AppStyles.bold16SoftBlue
        ),
      ),
    );

  }

}