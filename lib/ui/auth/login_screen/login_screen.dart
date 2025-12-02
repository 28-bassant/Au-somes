import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../custom_widgets/custom_language_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_language_provider.dart';
import '../../../utils/app_assets.dart';
import '../../../utils/app_styles.dart';

class LoginScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 8,
      ),
      body:Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .06),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Image(image: AssetImage(AppAssets.logoImage), width: 140),
                      SizedBox(width: width * .04),
                      Text(AppLocalizations.of(context)!.welcome_back, style: AppStyles.bold24SoftBlue),
                    ],
                  ),

                  Positioned(top: 0, right:languageProvider.appLanguage == 'en'? 0 : null,left:languageProvider.appLanguage == 'ar'? 0 : null, child: CustomLanguageWidget()),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}