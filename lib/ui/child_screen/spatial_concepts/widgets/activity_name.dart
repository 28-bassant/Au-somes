import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class ActivityName extends StatelessWidget{
  String image;
  String text;
  IconData icon;
  final VoidCallback? onPressed;
  ActivityName({
    required this.image,
    required this.text,
    required this.icon,
    required this.onPressed
  });
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double . infinity,
        padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .02
        ),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular( 16)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image(image: AssetImage(image)),
            Text(text,style: AppStyles.regular18Black,),
            Icon(icon,color: AppColors.blackColorWithOpacity60,)

          ],
        ),
      ),
    );
  }
}