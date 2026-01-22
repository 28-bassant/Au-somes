import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/cache/token_utils.dart';
import '../../../../../../custom_widgets/custom_elevated_button.dart';
import '../../../../../../custom_widgets/custom_text_form_field.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_styles.dart';
import '../../../../../../utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController parentEmailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    childNameController.text = TokenUtils.getChildName() ?? '';
    ageController.text = TokenUtils.getChildAge()?.toString() ?? '';
    parentEmailController.text = TokenUtils.getEmail() ?? '';
    print(parentEmailController.text);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPastelBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blackColor),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.edit_profile,
          style: AppStyles.bold22Black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: height * .02, horizontal: width * .04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.edit_profile_text,
                style: AppStyles.bold24BlackWithOpacity60,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * .04),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.child_name,
                      style: AppStyles.medium20BlackWithOpacity60,
                    ),
                    CustomTextFormField(
                      controller: childNameController,
                      validator: AppValidators.validateFullName,
                      prefixIcon: const Icon(Icons.person, color: AppColors.greyColor),
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      AppLocalizations.of(context)!.age,
                      style: AppStyles.medium20BlackWithOpacity60,
                    ),
                    CustomTextFormField(
                      controller: ageController,
                      validator: (value) => AppValidators.validateAge(ageController.text),
                      prefixIcon: const Icon(Icons.person, color: AppColors.greyColor),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      AppLocalizations.of(context)!.parent_email,
                      style: AppStyles.medium20BlackWithOpacity60,
                    ),
                    CustomTextFormField(
                      controller: parentEmailController,
                      validator: AppValidators.validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.greyColor),
                      keyboardType: TextInputType.emailAddress,
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
                          if (formKey.currentState!.validate()) {
                            updateProfile();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateProfile() {
  }
}
