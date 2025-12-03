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
  var formKey = GlobalKey<FormState>();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
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
           title:Text (AppLocalizations.of(context)!.forget_password,style: AppStyles.bold24SoftBlue,)
           , centerTitle: true,
           leading: IconButton(onPressed: (){
             Navigator.pop(context);
           }, icon:Icon(Icons.arrow_back,size: 35,))
       ),
       body: Padding(
           padding: EdgeInsets.symmetric(horizontal: width*.04,vertical: height*.02),
           child: SingleChildScrollView(
             child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   SizedBox(height: height*.02),
                   Row(mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Image(image:AssetImage(AppAssets.forgetPasswordImage)),
                     ],
                   ), SizedBox(height: height*.02),
                   Form(
                       key: formKey,
                       child: Column(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                             Text(AppLocalizations.of(context)!.new_password,
                                 style: AppStyles.semiBold20SoftBlue),
             
             
                             CustomTextFormField(
                                 controller: newPasswordController,
                                 keyboardType: TextInputType.visiblePassword,
                                 validator: AppValidators.validatePassword,
                                 suffixIcon: IconButton(onPressed: () {
                                   obscure = !obscure;
                                   setState(() {});
                                 }, icon: Icon(
                                   obscure ? Icons.visibility_off : Icons
                                       .visibility,
                                   color: AppColors.softBlue,)),
                                 obscureText: obscure),
             
                             SizedBox(height: height * .02),
             
                             Text(AppLocalizations.of(context)!.confirm_password,
                                 style: AppStyles.semiBold20SoftBlue),
             
             
                             CustomTextFormField(
                                 controller: confirmPasswordController,
                                 keyboardType: TextInputType.visiblePassword,
                                 validator: AppValidators.validatePassword,
                                 suffixIcon: IconButton(onPressed: () {
                                   obscure = !obscure;
                                   setState(() {});
                                 }, icon: Icon(
                                   obscure ? Icons.visibility_off : Icons
                                       .visibility,
                                   color: AppColors.softBlue,)),
                                 obscureText: obscure),
                             SizedBox(height: height * .06),

                             SizedBox(
                               width: double.infinity,
                               child: CustomElevatedButton(
                                 text: AppLocalizations.of(context)!.change_password,
                                 textStyle: AppStyles.bold22White,
                                 onPressed: () {
                                   //todo: Navigate to login screen
                                   if (formKey.currentState?.validate() == true) {
                                   Navigator.pushNamed(context, AppRoutes.loginScreenRouteName);
                                 }},
                               ),)
             
                           ])),
             
             
             
                 ]),
           )
       )
      );
  }
}