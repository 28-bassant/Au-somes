import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../custom_widgets/custom_text_form_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_language_provider.dart';
import '../../../utils/validators.dart';

class ForgetPasswordScreen1 extends StatelessWidget{
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
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
           child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height*.02),
           Row(mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Image(image:AssetImage(AppAssets.forgetPasswordImage)),
             ],
           ),
           SizedBox(height: height*.04,),
           Text(AppLocalizations.of(context)!.email_associated_with_account,style: AppStyles.bold24SoftBlue,)
           ,SizedBox(height: height*.02)
             ,Form(key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      SizedBox(height: height*.02),
                        CustomTextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            hintText:AppLocalizations.of(context)!.email ,
                            validator: AppValidators.validateEmail,
                          prefixIcon:
                        Image(image: AssetImage(AppAssets.emailIcon)),
                          )
                        ,SizedBox(height: height*.04),
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          text: AppLocalizations.of(context)!.send_email,
                          textStyle: AppStyles.bold22White,
                          onPressed: () {
                            if (formKey.currentState?.validate() == true) {
                              Navigator.pushNamed(context, AppRoutes.forgetPasswordScreen2RouteName);
                            }

                          },
                        )),
                      ],
                    ),
             ),
                ],
              ),
         ),
   );
  }

  
}