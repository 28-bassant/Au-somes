import 'package:au_somes/custom_widgets/custom_text_form_field.dart';
import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: width * .04,
          vertical: height * .02
        ),
        child: Column(
          children: [
            CustomTextFormField(
              prefixIcon: Icon(Icons.search,color: AppColors.softBlue,),
              hintText: AppLocalizations.of(context)!.search,
              hintStyle: AppStyles.bold20SoftBlue,
              borderRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
}