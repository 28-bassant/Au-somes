import 'package:flutter/material.dart';

import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../custom_widgets/custom_text_form_field.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_styles.dart';
import '../../../../../../utils/validators.dart';

class EditProfileScreen extends StatelessWidget{
  TextEditingController childNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController parentEmailController = TextEditingController();
  var formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.lightPastelBlue,
          elevation: 0,
          iconTheme: IconThemeData(
              color: AppColors.blackColor
          ),
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.edit_profile,style: AppStyles.bold22Black,)
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(
          vertical: height * .02,
          horizontal: width * .04
        ),
        child: Column(
          children: [
             Text(AppLocalizations.of(context)!.edit_profile_text,style: AppStyles.bold24BlackWithOpacity60,
             textAlign: TextAlign.center,),
            SizedBox(height: height * .04,),
            Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.child_name,
                    style: AppStyles.medium20BlackWithOpacity60),
                CustomTextFormField(
                  controller: childNameController,
                  validator: AppValidators.validateFullName,
                  prefixIcon: Icon(Icons.person,color: AppColors.greyColor,),
                  hintText: 'Ali Mohamed',
                ),
                SizedBox(height: height * .01),
                Text(AppLocalizations.of(context)!.age,
                    style: AppStyles.medium20BlackWithOpacity60),
                CustomTextFormField(
                  controller: ageController,
                  prefixIcon: Icon(Icons.person,color: AppColors.greyColor,),
                  hintText: '8 ${AppLocalizations.of(context)!.years}',
                  validator: (value) =>
                      AppValidators.validateAge(ageController.text),

                ),
                SizedBox(height: height * .01),
                Text(AppLocalizations.of(context)!.parent_email,
                    style: AppStyles.medium20BlackWithOpacity60),
                CustomTextFormField(
                    controller: parentEmailController,
                    prefixIcon: Icon(Icons.email_outlined,color: AppColors.greyColor,),
                    hintText: 'mohamed@gmail.com',
                    validator: AppValidators.validateEmail
                ),
                SizedBox(height: height * .04),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    backgroundColor: AppColors.mintGreen,
                    borderColor: AppColors.mintGreen,
                    text: AppLocalizations.of(context)!.update_profile,
                    textStyle: AppStyles.bold22White,
                    onPressed: () {
                      //todo: Update Profile
                      UpdateProfile();
                    },
                  ),
                ),              ],
            ))
          ],
        ),
      ),
    );
  }

  void UpdateProfile(){

  }
}