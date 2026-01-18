import 'package:au_somes/api/api_manager.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:au_somes/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../l10n/app_localizations.dart';

class ForgetPasswordScreen2 extends StatefulWidget {
  @override
  State<ForgetPasswordScreen2> createState() => _ForgetPasswordScreen2State();
}

class _ForgetPasswordScreen2State extends State<ForgetPasswordScreen2> {
  bool isLoading = false;
  late String email;
  TextEditingController codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      email = args;
      print('Email received from previous screen: $email');
    } else {
      print('No email passed to this screen!');
    }
  }

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
          title: Column(
            children: [
              Text(AppLocalizations.of(context)!.forget_password,style: AppStyles.bold22Black,),
              Text(AppLocalizations.of(context)!.change_password,style: AppStyles.regular14BlackWithOpacity60,),
            ],
          )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .04, vertical: height * .02),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Image(image: AssetImage(AppAssets.forgetPasswordImage))],
              ),
              SizedBox(height: height * .04),
              Text(
                AppLocalizations.of(context)!.enter_verification_code,
                style: AppStyles.bold24BlackWithOpacity60,
              ),
              SizedBox(height: height * .02),
              Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.all(width * .04),
                  child: PinCodeTextField(
                    controller: codeController,
                    appContext: context,
                    length: 5,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enter_code;
                      }
                      if (value.length != 5) {
                        return AppLocalizations.of(context)!.code_must_be_5;
                      }
                      if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                        return AppLocalizations.of(context)!.code_must_contain_nums;
                      }
                      return null;
                    },
                    onChanged: (value) {},
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      borderWidth: 3,
                      activeColor: AppColors.mintGreen,
                      selectedColor: AppColors.mintGreen,
                      inactiveColor: AppColors.greyColor,
                    ),
                    animationType: AnimationType.none,
                  )
                  ,
                ),
              ),
              SizedBox(height: height * .04),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  text: AppLocalizations.of(context)!.verify,
                  textStyle: AppStyles.bold22White,
                  onPressed: isLoading ? null : verifyCodePressed,
                ),
              ),
              if (isLoading) SizedBox(height: 20),
              if (isLoading) CircularProgressIndicator(color: AppColors.softBlue),
            ],
          ),
        ),
      ),
    );
  }




  void verifyCodePressed() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final errorMsg = await ApiManager.verifyCode(
      email: email,
      code: codeController.text.trim(),
    );

    setState(() => isLoading = false);


    if (errorMsg != null && errorMsg.isNotEmpty) {
      if (!mounted) return;
      ToastUtils.ShowToast(
        msg: errorMsg,
        bgColor: AppColors.redColor,
        textColor: AppColors.whiteColor,
      );
      return;
    }

    else {
      if (!mounted) return;
      ToastUtils.ShowToast(
        msg: AppLocalizations.of(context)!.verification_successful,
        bgColor: AppColors.greenColor,
        textColor: AppColors.whiteColor,
      );

      Navigator.pushNamed(
        context,
        AppRoutes.forgetPasswordScreen3RouteName,
        arguments: {
          "email": email,
          "code": codeController.text.trim(),
        },
      );
    }
  }
}
