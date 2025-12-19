import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../../../../utils/app_colors.dart';

class QuickQuestionCard extends StatelessWidget{
   String text;
   QuickQuestionCard({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin:  EdgeInsets.symmetric(vertical: height*.007),
      padding: EdgeInsets.all(width*.026),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        border: Border.all(width: 2,color: AppColors.whiteColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppStyles.bold16White
            ),
          ),
        ],
      ),
    );
  }

}