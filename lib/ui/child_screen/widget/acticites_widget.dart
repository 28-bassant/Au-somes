import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class ActivitiesWidget extends StatelessWidget{
  String image;
  String text;
  final VoidCallback? onPressed;
  ActivitiesWidget({
    required this.image,
    required this.text,
    required this.onPressed
});
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Image(image: AssetImage(image)),
          SizedBox(height: height * .02,),
          Text(text, style: AppStyles.medium20Black,)
        ],
      ),
    );
  }
}