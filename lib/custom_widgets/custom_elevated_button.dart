
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_styles.dart';


class CustomElevatedButton extends StatelessWidget {
  VoidCallback? onPressed;
  String text;
  TextStyle? textStyle;
  Color backgroundColor;
  Color borderColor;
  bool isIcon;
  Widget? iconWidget;
  MainAxisAlignment mainAxisAlignment;
  double? borderReadius;
  IconData? suffixIconName;
  double space ;
  String? text2;
  bool istext2;
  Color? suffixIconColor;
  String? iconName;
  num iconPadding;



  CustomElevatedButton({
    super.key,
    this.onPressed,
    required this.text,
    this.textStyle,
    this.backgroundColor = AppColors.softBlue,
    this.borderColor = AppColors.softBlue,
    this.isIcon = false,
    this.iconWidget,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.borderReadius,
    this.suffixIconColor=AppColors.greyColor,
    this.space =.01,
    this.suffixIconName,
    this.text2,
    this.istext2=false,
    this.iconPadding=0,
    this.iconName


  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: height * .02),
        ),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        side: MaterialStateProperty.all(
          BorderSide(color: borderColor, width: 1),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderReadius ?? 16)),
        ),
      ),
      child: isIcon
      ? Row(mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: width*iconPadding),
            child: Image(image: AssetImage(iconName!)),
          ),
          SizedBox(width: width*.04,),
          istext2?
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text!,style:textStyle ?? AppStyles.semiBold20White,),
              Text(text2??'',style: AppStyles.medium20Black,),
            ],
          ):Text(text!,style:textStyle ?? AppStyles.medium20Black ,),
          SizedBox(width: width* space )
          ,Icon(suffixIconName,color: suffixIconColor)
        ],):
           Text(text, style: textStyle ?? AppStyles.bold22White),
    );
  }
}

