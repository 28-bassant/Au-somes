import 'package:flutter/material.dart';

import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/app_styles.dart';

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.lightPastelBlue,
          width: width * 0.004,
        ),
        borderRadius: BorderRadius.circular(width * 0.06),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: width * 0.045,
            vertical: height * 0.005,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            width * 0.045,
            0,
            width * 0.045,
            height * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.06),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.06),
          ),
          onExpansionChanged: (value) {
            setState(() {
              expanded = value;
            });
          },
          trailing: Icon(
            expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: AppColors.lightPastelBlue,
            size: width * 0.07,
          ),
          title: Text(
            widget.question,
            style: AppStyles.bold14Black,
          ),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: AppColors.lightPastelBlue,
                borderRadius:
                BorderRadius.circular(width * 0.05),
              ),
              child: Text(
                widget.answer,
                style: AppStyles.medium16Black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}