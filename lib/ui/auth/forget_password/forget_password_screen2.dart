
import 'package:au_somes/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_assets.dart';
import '../../../utils/app_styles.dart';

class ForgetPasswordScreen2 extends StatelessWidget {
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
                  ), SizedBox(height: height*.04),
                  Text (AppLocalizations.of(context)!.enter_verification_code,
                    style: AppStyles.bold24SoftBlue,),
                  SizedBox(height: height*.02),
                  Padding(
                    padding: EdgeInsets.all(width*.04),
                    child: PinCodeTextField(
                      enableActiveFill: false,
                      appContext: context,
                      length: 5,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 50,
                        fieldWidth: 50,
                        borderWidth: 3,
                        activeColor: AppColors.mintGreen,
                        selectedColor:AppColors.softBlue ,
                        inactiveColor:AppColors.softBlue,
                      ),animationType: AnimationType.none,
                    ),
                  ),
                  SizedBox(height: height*.04),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      text: AppLocalizations.of(context)!.verify,
                      textStyle: AppStyles.bold22White,
                      onPressed: () {
                      },
                    ),
                  ),




    ])));
  }

}