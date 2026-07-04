import 'package:au_somes/custom_widgets/custom_elevated_button.dart';
import 'package:au_somes/custom_widgets/custom_language_widget.dart';
import 'package:au_somes/custom_widgets/custom_text_form_field.dart';
import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:au_somes/utils/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/api_manager.dart';
import '../../../core/cache/shared_prefs_utils.dart';
import '../../../core/cache/token_utils.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var formKey = GlobalKey<FormState>();
  TextEditingController childNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController parentEmailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  bool obscure = true;

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
                      Text(AppLocalizations.of(context)!.join_us,
                          style: AppStyles.bold24BlackWithOpacity60),
                    ],
                  ),

                  Positioned(top: 0,
                      right: languageProvider.appLanguage == 'en' ? 0 : null,
                      left: languageProvider.appLanguage == 'ar' ? 0 : null,
                      child: CustomLanguageWidget()),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.register_qoute,
                style: AppStyles.medium16BlackWithOpacity60,
              ),
              SizedBox(height: height * 0.04),
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
                      hintText: AppLocalizations.of(context)!.child_name,
                    ),
                    SizedBox(height: height * .01),
                    Text(AppLocalizations.of(context)!.age,
                        style: AppStyles.medium20BlackWithOpacity60),
                    CustomTextFormField(
                      controller: ageController,
                      prefixIcon: Icon(Icons.person,color: AppColors.greyColor,),
                      hintText: AppLocalizations.of(context)!.age,
                      validator: (value) =>
                          AppValidators.validateAge(ageController.text),

                    ),
                    SizedBox(height: height * .01),
                    Text(AppLocalizations.of(context)!.parent_email,
                        style: AppStyles.medium20BlackWithOpacity60),
                    CustomTextFormField(
                        controller: parentEmailController,
                        prefixIcon: Icon(Icons.email_outlined,color: AppColors.greyColor,),
                        hintText: AppLocalizations.of(context)!.email,
                        validator: AppValidators.validateEmail
                    ),
                    SizedBox(height: height * .01),
                    Text(AppLocalizations.of(context)!.password,
                        style: AppStyles.medium20BlackWithOpacity60),
                    CustomTextFormField(
                        controller: passwordController,
                        validator: AppValidators.validatePassword,
                        keyboardType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(onPressed: () {
                          obscure = !obscure;
                          setState(() {});
                        }
                            ,
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.greyColor,)),
                        obscureText: obscure
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      AppLocalizations.of(context)!.confirm_password,
                      style: AppStyles.medium20BlackWithOpacity60,
                    ),
                    CustomTextFormField(
                        controller: confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) =>
                            AppValidators.validateConfirmPassword(
                                value, passwordController.text),
                        suffixIcon: IconButton(onPressed: () {
                          obscure = !obscure;
                          setState(() {});
                        }
                            ,
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.greyColor,)),
                        obscureText: obscure
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
                        Text(
                          AppLocalizations.of(context)!.already_have_an_account,
                          style: AppStyles.regular16BlackWithOpacity60,),
                        InkWell(
                            onTap: () {
                              //todo: Navigate to login screen
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.loginScreenRouteName);
                            },
                            child: Text(AppLocalizations.of(context)!.login,
                              style: AppStyles.bold16BlackWithOpacity60,)),
                      ],
                    ),
                    SizedBox(height: height * .04)


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void Register() async {
    if (formKey.currentState?.validate() == true) {
      DialogUtils.showLoading(textLoading: 'Loading', context: context);

      try {
        final response = await ApiManager.register(
          childName: childNameController.text.trim(),
          email: parentEmailController.text.trim(),
          password: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
          age: int.tryParse(ageController.text.trim()) ?? 0,
        );

        DialogUtils.hideLoading(context: context);
        if (response != null && response.token != null) {
          await TokenUtils.saveTokens(response);

          final expiryTimestamp = DateTime.now()
              .add(Duration(seconds: response.expiresIn ?? 1800))
              .millisecondsSinceEpoch;
          await SharedPrefsUtils.saveData(
            key: "tokenExpiry",
            value: expiryTimestamp,
          );

          DialogUtils.showMsg(
            context: context,
            title: "Success",
            msg: "register Successful",
            posActionName: "OK",
            posAction: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.selectScreenRouteName,
              );
            },
          );
        }

      } catch (e) {
        DialogUtils.hideLoading(context: context);

        DialogUtils.showMsg(
          context: context,
          msg: e.toString().replaceFirst("Exception: ", ""),
        );
      }
    }
  }





}
