
import 'dart:ui';

import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

typedef OnValidator = String? Function(String?)?;

class CustomTextFormField extends StatelessWidget {
  Color? filledColor;
  Color? borderColor;
  String? labelText;
  TextStyle? labelStyle;
  Widget? prefixIcon;
  Widget? suffixIcon;
  OnValidator onValidator;
  TextInputType? keyboardType;
  TextEditingController? controller;
  bool obscureText;
  int? maxLines;
  TextStyle? textStyle;
  double? borderRadius;

  CustomTextFormField({
    this.filledColor,
    super.key,
    this.maxLines,
    this.borderColor,
    this.labelText,
    this.labelStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.onValidator,
    this.keyboardType,
    this.obscureText = false,
    this.textStyle,
    this.borderRadius

  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            width: 2,
            strokeAlign: 2
          )
        ),
        enabledBorder: builtTextFieldBorder(
            borderColor:
            borderColor ?? AppColors.softBlue,
        ),
        focusedBorder: builtTextFieldBorder(borderColor: AppColors.softBlue),
        errorBorder: builtTextFieldBorder(borderColor: AppColors.redColor),
        errorStyle: AppStyles.medium16Red.copyWith(color: AppColors.redColor),
        fillColor: filledColor ?? AppColors.trasparentColor,
        filled: true,
        labelText: labelText,

        labelStyle:
        labelStyle ?? AppStyles.semiBold20SoftBlue,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

      ),
      controller: controller,
      maxLines: maxLines ?? 1,
      style:textStyle ?? AppStyles.semiBold20SoftBlue,
      validator: onValidator,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  OutlineInputBorder builtTextFieldBorder({required Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      borderSide: BorderSide(
        color: borderColor ?? AppColors.softBlue,
        width: 2,
      ),
    );
  }
}
