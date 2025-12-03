
import 'dart:ui';

import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

typedef OnValidator = String? Function(String?)?;

class CustomTextFormField extends StatefulWidget {
  Color? filledColor;
  Color? borderColor;
  String? labelText;
  TextStyle? labelStyle;
  Widget? prefixIcon;
  Widget? suffixIcon;
  String? Function(String?)? validator;
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

    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.textStyle,
    this.borderRadius

  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
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
            widget.borderColor ?? AppColors.softBlue,
        ),
        focusedBorder: builtTextFieldBorder(borderColor: AppColors.softBlue),
        errorBorder: builtTextFieldBorder(borderColor: AppColors.redColor),
        errorStyle: AppStyles.medium16Red.copyWith(color: AppColors.redColor),
        fillColor: widget.filledColor ?? AppColors.trasparentColor,
        filled: true,
        labelText: widget.labelText,

        labelStyle:
        widget.labelStyle ?? AppStyles.semiBold20SoftBlue,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,

      ),
      controller: widget.controller,
      maxLines: widget.maxLines ?? 1,
      style:widget.textStyle ?? AppStyles.semiBold20SoftBlue,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
    );
  }

  OutlineInputBorder builtTextFieldBorder({required Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
      borderSide: BorderSide(
        color: borderColor ?? AppColors.softBlue,
        width: 2,
      ),
    );
  }
}
