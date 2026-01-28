import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppAssets.childPhoto,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
           SizedBox(height: 12),
          Text(
            'Establishing Morning Routines',
            style: AppStyles.bold18Black
          ),
         SizedBox(height: height*.01),
          Text(
            'Learn how visual schedules can significantly reduce transition anxiety for your child during the busy morning rush',
            style: AppStyles.medium16BlackWithOpacity60
          ),SizedBox(height: height*.01,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Container(
              padding:EdgeInsets.symmetric(vertical:height*.01,horizontal: width*.02 ) ,
              decoration: BoxDecoration(
                color: AppColors.lightPastelBlue,
                borderRadius: BorderRadius.circular(18)
              ),child: Text("Expert advice",style: AppStyles.medium16SoftBlue,),
            ),
            Container(
             padding:EdgeInsets.symmetric(vertical:height*.01,horizontal: width*.02 ) ,
              decoration: BoxDecoration(
                color: AppColors.lightPastelBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 25,
                color: AppColors.softBlue,
              ),
            ),
          ],)
        ],
      ),
    );
  }
}