import 'package:flutter/material.dart';

import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/app_styles.dart';

class RoutineItem extends StatelessWidget {
  final bool isDone;
  final String title;
  final String time;
  final VoidCallback onTap;
  final String image;
  final Color color;

  const RoutineItem({
    super.key,
    required this.isDone,
    required this.title,
    required this.time,
    required this.onTap,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * .02,
          vertical: height * .01,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: width * .02,
        ),
        decoration: BoxDecoration(
          color: !isDone
              ? AppColors.whiteColor
              : AppColors.whiteColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // icon image
            Image.asset(
              image,

            ),

            SizedBox(width: width * .03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: !isDone
                        ?AppStyles.medium16Black :
                    AppStyles.medium16grey.copyWith(
                      decoration: TextDecoration.lineThrough ,
                    ),
                  ),
                  SizedBox(height: height *.01),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.greyColor,
                      ),
                       SizedBox(width: width * .02),
                      Text(
                        time,
                        style: AppStyles.regular14Grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              isDone ? Icons.check_circle : Icons.circle,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
