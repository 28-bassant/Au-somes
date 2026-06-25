import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../../../../utils/app_colors.dart';

enum OptionState { idle, correct, wrong }

class AnswerOptionButton extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const AnswerOptionButton({
    super.key, required this.text,
    required this.state, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, border, textColor;
    switch (state) {
      case OptionState.correct:
        bg = AppColors.greenColor; border = AppColors.greenColor;
        textColor = AppColors.whiteColor; break;
      case OptionState.wrong:
        bg = AppColors.redColor; border = AppColors.redColor;
        textColor = AppColors.redColor; break;
      default:
        bg = AppColors.whiteColor; border = AppColors.greyColor;
        textColor = AppColors.blackColor;
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(text, textAlign: TextAlign.center,
            style: AppStyles.bold14Black),
      ),
    );
  }
}
