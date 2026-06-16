import 'package:flutter/material.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import '../../../../../models/Centers/center_model.dart';
import '../../../../../utils/app_assets.dart';
import 'actions.dart';

class CenterWidget extends StatelessWidget {
  final CenterModel model;

  const CenterWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * .02,
        vertical: height * .01,
      ),
      padding:  EdgeInsets.all(height * .01),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(.6),
        border: Border.all(color: AppColors.softBlue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: AppStyles.bold14Black,
                  softWrap: true,
                ),

                 SizedBox(height: height * .01),

                InkWell(
                  onTap: () => openPhone(model.phone),
                  child: _row(
                    Icons.phone,
                    model.phone,
                  ),
                ),

                 SizedBox(height: height * .009),

                InkWell(
                  onTap: () =>
                      openMap(model.latitude, model.longitude),
                  child: _row(
                    Icons.location_on_outlined,
                    model.address,
                  ),
                ),

                 SizedBox(height: height * .009),

                InkWell(
                  onTap: () => openLink(model.facebookLink),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        AppAssets.facebook_icon,
                        width: 16,
                        height: 16,
                      ),
                       SizedBox(width: height * .006),

                      Expanded(
                        child: Text(
                          model.facebookName,
                          style: AppStyles.medium10Black,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),

                 SizedBox(height: height * .009),

                InkWell(
                  onTap: () => openLink(model.websiteLink),
                  child: _row(
                    Icons.link,
                    model.websiteName,
                  ),
                ),
              ],
            ),
          ),

           SizedBox(width: width * .02),

          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              model.image,
              width: width * 0.25,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
        ),
        const SizedBox(width: 6),

        Expanded(
          child: Text(
            text,
            style: AppStyles.medium10Black,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

