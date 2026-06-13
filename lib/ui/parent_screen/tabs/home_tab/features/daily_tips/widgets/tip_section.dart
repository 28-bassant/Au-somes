import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TipSection extends StatelessWidget {
  final String? iconPath;
  final String title;
  final String? description;

  // structured content
  final List<dynamic> content;

  final Color backgroundColor;

  const TipSection({
    super.key,
    this.iconPath,
    required this.title,
    this.description,
    required this.content,
    required this.backgroundColor,
  });

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var languageProvider = Provider.of<AppLanguageProvider>(context);

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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (iconPath != null) ...[
                    Image.asset(iconPath!),
                    SizedBox(width: width * .02),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: AppStyles.bold14Black,
                    ),
                  ),
                ],
              ),

              if (description != null && description!.isNotEmpty) ...[
                SizedBox(height: height * .004),
                Text(
                  description!,
                  style: AppStyles.regular12Black,
                ),
              ],

              SizedBox(height: height * .01),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item["text"],
                            style: AppStyles.regular12Black,
                          ),
                        ),

                        if (item["hasLink"] == true) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              _openUrl(item["url"]);
                            },
                            child: const Icon(
                              Icons.link,
                              size: 16,
                              color: AppColors.softBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        Positioned(
          left: languageProvider.isArabic() ? null : 0,
          right: languageProvider.isArabic() ? 0 : null,
          top: 5,
          bottom: 5,
          child: Container(
            width: width * .02,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(languageProvider.isArabic() ? 0 : 24),
                bottomLeft: Radius.circular(languageProvider.isArabic() ? 0 : 24),
                topRight: Radius.circular(languageProvider.isArabic() ? 24 : 0),
                bottomRight: Radius.circular(languageProvider.isArabic() ? 24 : 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}