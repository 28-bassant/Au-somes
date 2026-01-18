import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/toast_utils.dart';
import 'package:flutter/material.dart';

import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../custom_widgets/custom_text_form_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_assets.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/validators.dart';

class ForgetPasswordScreen3 extends StatefulWidget {
  @override
  State<ForgetPasswordScreen3> createState() => _ForgetPasswordScreen3State();
}

class _ForgetPasswordScreen3State extends State<ForgetPasswordScreen3> {
  final formKey = GlobalKey<FormState>();

  late String email;
  late String code;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscure = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    email = args['email'];
    code = args['code'];

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.lightPastelBlue,
          elevation: 0,
          iconTheme: IconThemeData(
              color: AppColors.blackColor
          ),
          centerTitle: true,
          title: Column(
            children: [
              Text(AppLocalizations.of(context)!.forget_password,style: AppStyles.bold22Black,),
              Text(AppLocalizations.of(context)!.change_password,style: AppStyles.regular14BlackWithOpacity60,),
            ],
          )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * .04,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: height * .02), 
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Image.asset(AppAssets.forgetPasswordImage),
                  ],
                ),
                SizedBox(height: height * .04), 
                Text(
                  AppLocalizations.of(context)!.new_password,
                  style: AppStyles.medium20BlackWithOpacity60,
                ),
                CustomTextFormField(
                  controller: newPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: AppValidators.validatePassword,
                  obscureText: obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),

                SizedBox(height: height * .03),

                Text(
                  AppLocalizations.of(context)!.confirm_password,
                  style: AppStyles.medium20BlackWithOpacity60,
                ),
                SizedBox(height: height * .01),
                CustomTextFormField(
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: obscure,
                  validator: (value) =>
                      AppValidators.validateConfirmPassword(
                        value,
                        newPasswordController.text,
                      ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),

                SizedBox(height: height * .06),

                CustomElevatedButton(
                  text:  AppLocalizations.of(context)!.change_password,
                  textStyle: AppStyles.bold22White,
                  onPressed: isLoading ? null : resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    print('EMAIL => $email');
    print('CODE => ${code.trim()}');

    final errorMsg = await ApiManager.resetPassword(
      email: email,
      code: code.trim(),
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (errorMsg == null) {
      ToastUtils.ShowToast(
        msg: AppLocalizations.of(context)!.password_changed_successfully,
        bgColor: AppColors.greenColor,
        textColor: AppColors.whiteColor,
      );

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.selectScreenRouteName,
        );
      });

    } else {
      ToastUtils.ShowToast(
        msg: errorMsg.toString(),
        bgColor: AppColors.redColor,
        textColor: AppColors.whiteColor,
      );
    }
  }



  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
