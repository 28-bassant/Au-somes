import 'package:au_somes/custom_widgets/custom_elevated_button.dart';
import 'package:au_somes/custom_widgets/custom_language_widget.dart';
import 'package:au_somes/custom_widgets/custom_text_form_field.dart';
import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:au_somes/utils/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  TextEditingController childNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController parentEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 8,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .06),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Image(image: AssetImage(AppAssets.logoImage), width: 108),
                      SizedBox(width: width * .04),
                      Text(AppLocalizations.of(context)!.join_us, style: AppStyles.bold24SoftBlue),
                    ],
                  ),

                  Positioned(top: 0, right:languageProvider.appLanguage == 'en'? 0 : null,left:languageProvider.appLanguage == 'ar'? 0 : null, child: CustomLanguageWidget()),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.register_qoute,
                style: AppStyles.medium16SoftBlue,
              ),
              SizedBox(height: height * 0.04),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.child_name, style: AppStyles.semiBold20SoftBlue),
                    CustomTextFormField(
                      controller: childNameController,
                    ),
                    SizedBox(height: height * .01),
                    Text(AppLocalizations.of(context)!.age, style: AppStyles.semiBold20SoftBlue),
                    CustomTextFormField(
                      controller: ageController,
                    ),
                    SizedBox(height: height * .01),
                    Text(AppLocalizations.of(context)!.parent_email, style: AppStyles.semiBold20SoftBlue),
                    CustomTextFormField(
                      controller: parentEmailController,
                    ),
                    SizedBox(height: height * .01),
                    Text(AppLocalizations.of(context)!.password, style: AppStyles.semiBold20SoftBlue),
                    CustomTextFormField(
                      controller: passwordController,
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      AppLocalizations.of(context)!.confirm_password,
                      style: AppStyles.semiBold20SoftBlue,
                    ),
                    CustomTextFormField(
                      controller: confirmPasswordController,
                    ),
                    SizedBox(height: height * .02),
                    SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        text: AppLocalizations.of(context)!.register,
                        textStyle: AppStyles.bold22White,
                        onPressed: () {
                          //todo: Register
                          Register();
                        },
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.already_have_an_account,style: AppStyles.bold16SoftBlue,),
                        InkWell(
                            onTap: () {
                              //todo: Navigate to login screen
                              Navigator.pushReplacementNamed(context, AppRoutes.loginScreenRouteName);
                            },
                            child: Text(AppLocalizations.of(context)!.login,style: AppStyles.extraBold16SoftBlue,)),
                      ],
                    )
                    

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void Register(){

  }
}
