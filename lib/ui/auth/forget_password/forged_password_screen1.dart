import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:au_somes/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../custom_widgets/custom_text_form_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/validators.dart';

class ForgetPasswordScreen1 extends StatefulWidget {
  @override
  State<ForgetPasswordScreen1> createState() => _ForgetPasswordScreen1State();
}

class _ForgetPasswordScreen1State extends State<ForgetPasswordScreen1> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.forget_password,
          style: AppStyles.bold24SoftBlue,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: 35),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .04, vertical: height * .02),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * .02),
              Image.asset(AppAssets.forgetPasswordImage),
              SizedBox(height: height * .04),
              Text(
                AppLocalizations.of(context)!.email_associated_with_account,
                style: AppStyles.bold24SoftBlue,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * .02),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hintText: AppLocalizations.of(context)!.email,
                      validator: AppValidators.validateEmail,
                      prefixIcon: Image.asset(AppAssets.emailIcon),
                    ),
                    SizedBox(height: height * .04),
                    CustomElevatedButton(
                      text: AppLocalizations.of(context)!.send_email,
                      textStyle: AppStyles.bold22White,
                      onPressed: forgetPassword,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void forgetPassword() async {
    if (formKey.currentState?.validate() != true) return;
    setState(() => isLoading = true);
    try {
      String email = emailController.text.trim();
      print('Sending forgetPassword request for email: $email');

      await ApiManager.forgetPassword(email: email);

      ToastUtils.ShowToast(
        msg: AppLocalizations.of(context)!.verification_code_sent,
        bgColor: AppColors.greenColor,
        textColor: AppColors.whiteColor,
      );

      Navigator.pushNamed(
        context,
        AppRoutes.forgetPasswordScreen2RouteName,
        arguments: emailController.text.trim(),
      );

    } catch (e) {
      print('Error in forgetPassword: $e');
      ToastUtils.ShowToast(
        msg: e.toString(),
        bgColor: AppColors.redColor,
        textColor: AppColors.whiteColor,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
