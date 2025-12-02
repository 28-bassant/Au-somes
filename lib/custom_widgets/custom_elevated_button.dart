
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
    this.borderReadius
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
      ? Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            iconWidget!,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Text(
                text,
                style: textStyle ?? AppStyles.bold24SoftBlue,
              ),
            ),
          ],
        )
          : Text(text, style: textStyle ?? AppStyles.bold22White),
    );
  }
}
