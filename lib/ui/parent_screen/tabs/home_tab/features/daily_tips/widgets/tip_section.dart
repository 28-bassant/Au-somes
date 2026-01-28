import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class TipSection extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final String content;
  final Color backgroundColor;

  const TipSection({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.content,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * .04),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 8,
                offset:  Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(iconPath),
                  SizedBox(width: width * .02),
                  Expanded(
                    child: Text(
                      title,
                      style: AppStyles.bold14Black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .004),
              Text(
                description,
                style: AppStyles.regular12Black,
              ),
              SizedBox(height: height * .01),
              Text(
                content,
                style: AppStyles.regular12Black,
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 5,
          bottom: 5,
          child: Container(
            width: width*.02,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}