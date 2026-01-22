import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class TimeWidget extends StatelessWidget{
  bool isSelected ;
  String image;
  String text;
  final VoidCallback? onPressed;
  TimeWidget({
    required this.isSelected,
    required this.image,
    required this.text,
    required this.onPressed
});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onPressed,
      child: Container(
          padding: EdgeInsets.symmetric(
              vertical: height * .01,
              horizontal: width * .02
          ),

        decoration: BoxDecoration(
          color: isSelected ? AppColors.softBlue : AppColors.trasparentColor,
          borderRadius: BorderRadius.circular(isSelected ? 8 : 0)
        ),
        child: Column(
          children: [
            Image(image: AssetImage(image),color: isSelected ? AppColors.whiteColor : AppColors.greyColor,),
            Text(text,style: isSelected ? AppStyles.regular14White : AppStyles.regular14BlackWithOpacity60,)
          ],
        ),
      ),
    );
  }
}