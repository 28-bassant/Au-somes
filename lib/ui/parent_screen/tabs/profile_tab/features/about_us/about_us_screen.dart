import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
       appBar: AppBar(
         iconTheme: IconThemeData(
           color: AppColors.blackColor
         ),
       ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.symmetric(horizontal : height * .04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(image: AssetImage(AppAssets.logoImage),
               height: height * .2,
            ),
            // Tagline
             Text(
              AppLocalizations.of(context)!.about_us_title,
              textAlign: TextAlign.center,
              style: AppStyles.bold20SoftBlue
            ),

             SizedBox(height: height * .04),





            // About Text
             Text(
              AppLocalizations.of(context)!.about_us_content,
              textAlign: TextAlign.justify,
              style: AppStyles.medium16BlackWithOpacity60
            ),
          ],
        ),
      ),
    );
  }
}
