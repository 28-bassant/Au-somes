import 'package:au_somes/ui/parent_screen/tabs/profile_tab/widget/profile_item.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/cache/token_utils.dart';
import '../../../../custom_widgets/custom_language_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);

    final name = TokenUtils.getChildName();
    final age = TokenUtils.getChildAge();

    return Scaffold(
      appBar: AppBar(
        actions: [
          CustomLanguageWidget(),
          SizedBox(width: width * .02),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(width * .05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image(image: AssetImage(AppAssets.childAvatar)),
              SizedBox(height: height * .01),
              Text(
                '$name',
                style: AppStyles.bold20BlackWithOpacity60,
              ),
              Text(
                "$age ${AppLocalizations.of(context)!.years}",
                style: AppStyles.medium20BlackWithOpacity60,
              ),
              SizedBox(height: height * .05),
              Container(
                margin: EdgeInsets.symmetric(vertical: height * .007),
                padding: EdgeInsets.symmetric(
                  horizontal: width * .05,
                  vertical: height * .03,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: AppColors.softBlue,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.whiteColor,
                ),
                child: Column(
                  children: [
                    ProfileItem(
                      text: AppLocalizations.of(context)!.edit_profile,
                      image: AppAssets.editIcon,
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.editProfileScreenRouteName,
                        );

                        if (result == true) {
                          setState(() {});
                        }
                      },
                    ),
                    SizedBox(height: height * .03),

                    ProfileItem(
                      text: AppLocalizations.of(context)!.reset_password,
                      image: AppAssets.resetIcon,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.forgetPasswordScreen1RouteName,
                      ),
                    ),

                    SizedBox(height: height * .03),

                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.faq_ScreenRouteName),

                      child: ProfileItem(
                        text: AppLocalizations.of(context)!
                            .frequently_asked_questions,
                        image: AppAssets.frequentlyQuestionIcon,
                      ),
                    ),

                    SizedBox(height: height * .03),

                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.aboutUsScreenRouteName),
                      child: ProfileItem(
                        text: AppLocalizations.of(context)!.about_us,
                        image: AppAssets.aboutIcon,
                      ),
                    ),

                    SizedBox(height: height * .03),

                    GestureDetector(
                      onTap:() => showRatingDialog(context),
                      child: ProfileItem(
                        text: AppLocalizations.of(context)!.review_au_somes,
                        image: AppAssets.reviewIcon,
                      ),
                    ),

                    SizedBox(height: height * .03),

                    ProfileItem(
                      text: AppLocalizations.of(context)!.logout,
                      image: languageProvider.isArabic()
                          ? AppAssets.logoutArabicIcon
                          : AppAssets.logoutEnglishIcon,
                      onPressed: () async {
                        await TokenUtils.clearTokens();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.loginScreenRouteName,
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  int selectedRating = 0;

  void showRatingDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.whiteColor,
              insetPadding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.04,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Center(
                child: Text(
                  AppLocalizations.of(context)!.review_au_somes,
                  textAlign: TextAlign.center,
                  style: AppStyles.bold16SoftBlue,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .how_would_you_rate_our_app,
                        textAlign: TextAlign.center,
                        style: AppStyles.medium16BlackWithOpacity60,
                      ),
                      SizedBox(height: height * 0.025),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          5,
                              (index) => IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            icon: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.softBlue,
                              size: width * 0.08, // Responsive
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: AppStyles.medium16Red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.softBlue,
                        content: Text(
                          AppLocalizations.of(context)!
                              .thank_you_for_rating,
                          style: AppStyles.bold16White,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.submit,
                    style: AppStyles.medium16SoftBlue,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }}