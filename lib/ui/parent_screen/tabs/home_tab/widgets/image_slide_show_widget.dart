import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/app_colors.dart';

class ImageSlideShowWidget extends StatelessWidget{
  late List<String> adsImagesList;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    adsImagesList = [
      languageProvider.isArabic() ? AppAssets.ad1_arabic : AppAssets.ad1_english,
      languageProvider.isArabic() ? AppAssets.ad2_arabic : AppAssets.ad2_english,
      languageProvider.isArabic() ? AppAssets.ad3_arabic : AppAssets.ad3_english,
    ];
    return Column(
      children: [
        ImageSlideshow(
          height: height * 0.2,
          indicatorColor: Colors.transparent,
          indicatorBackgroundColor: Colors.transparent,
          initialPage: 0,
          isLoop: true,
          autoPlayInterval: 3000,
          children: adsImagesList.map((e) {
            return Image.asset(
              e,);
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(adsImagesList.length, (index) {
            Color dotColor;
            if (index == 0) dotColor = AppColors.mintGreen;
            else if (index == 1) dotColor = AppColors.pastelPink;
            else dotColor = AppColors.lightPastelBlue;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );



  }
}