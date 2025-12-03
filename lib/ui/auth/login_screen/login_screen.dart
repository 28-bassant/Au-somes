import 'package:au_somes/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../custom_widgets/custom_language_widget.dart';
import '../../../custom_widgets/custom_text_form_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_language_provider.dart';
import '../../../utils/app_assets.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/app_styles.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscure = true;


  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
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
                              Image(image: AssetImage(AppAssets.logoImage),
                                  width: 140),
                              SizedBox(width: width * .04),
                              Text(AppLocalizations.of(context)!.welcome_back,
                                  style: AppStyles.bold24SoftBlue),
                            ],
                          ),

                          Positioned(top: 0,
                              right: languageProvider.appLanguage == 'en'
                                  ? 0
                                  : null,
                              left: languageProvider.appLanguage == 'ar'
                                  ? 0
                                  : null,
                              child: CustomLanguageWidget()),
                        ],
                      ),
                      SizedBox(height: height * 0.02),
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(AppLocalizations.of(context)!.email,
                                style: AppStyles.semiBold20SoftBlue),

                            CustomTextFormField(
                              controller: emailController,
                              keyboardType:  TextInputType.emailAddress,
                              validator: AppValidators.validateEmail,
                            ),
                            SizedBox(height: height * .02),
                            Text(AppLocalizations.of(context)!.password,
                                style: AppStyles.semiBold20SoftBlue),

                            CustomTextFormField(
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                validator: AppValidators.validatePassword,
                                suffixIcon: IconButton(onPressed: () {
                                  obscure = !obscure;
                                  setState(() {});
                                }, icon: Icon(
                                      obscure ? Icons.visibility_off : Icons
                                          .visibility,
                                      color: AppColors.softBlue,)),
                                obscureText: obscure)
                            ,
                            SizedBox(height: height * .01),
                            Row(mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(AppLocalizations.of(context)!
                                    .forget_password
                                    , style: AppStyles.bold20SoftBlue),
                              ],
                            ),
                            SizedBox(height: height * .02),

                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                text: AppLocalizations.of(context)!.login,
                                textStyle: AppStyles.bold22White,
                                onPressed: () {
                                  //todo: login
                                  login();
                                },
                              ),
                            ),
                            SizedBox(height: height * .02),

                            Row(children: [
                              Expanded(child: Divider(
                                indent: width * .05,
                                endIndent: width * .04,
                                thickness: 3,
                                color: AppColors.softBlue,
                              )),
                              Text(AppLocalizations.of(context)!.or,
                                style: AppStyles.bold24SoftBlue,),
                              Expanded(child: Divider(thickness: 3,
                                indent: width * .04,
                                endIndent: width * .06,
                                color: AppColors.softBlue,))
                            ],),
                            SizedBox(height: height * .02),

                            CustomElevatedButton(onPressed: () {},
                              text: AppLocalizations.of(context)!.login_google,
                              textStyle: AppStyles.bold24SoftBlue,
                              backgroundColor: AppColors.backgroundColor,
                              mainAxisAlignment: MainAxisAlignment.center,
                              isIcon: true,
                              iconName: AppAssets.googleIcon,),


                            SizedBox(height: height * .02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!
                                    .dont_have_account,
                                  style: AppStyles.bold16SoftBlue,),
                                InkWell(
                                    onTap: () {
                                      //todo: Navigate to register screen
                                      Navigator.pushReplacementNamed(context,
                                          AppRoutes.registerScreenRouteName);
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .create_one, style: AppStyles
                                        .extraBold16SoftBlue,)),
                              ],
                            )


                          ],
                        ),
                      ),
                    ]
                )
            )
        ));
  }

  void login() {
    if (formKey.currentState?.validate() == true) {}
  }
}
