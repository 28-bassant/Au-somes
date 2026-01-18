import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @join_us.
  ///
  /// In en, this message translates to:
  /// **'Join Us !'**
  String get join_us;

  /// No description provided for @register_qoute.
  ///
  /// In en, this message translates to:
  /// **'Begin today to build a brighter tomorrow for you child .'**
  String get register_qoute;

  /// No description provided for @child_name.
  ///
  /// In en, this message translates to:
  /// **'Child Name'**
  String get child_name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @parent_email.
  ///
  /// In en, this message translates to:
  /// **'Parent Email'**
  String get parent_email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back !'**
  String get welcome_back;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account ? '**
  String get dont_have_account;

  /// No description provided for @already_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account ? '**
  String get already_have_an_account;

  /// No description provided for @create_one.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get create_one;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @login_google.
  ///
  /// In en, this message translates to:
  /// **'Login With Google'**
  String get login_google;

  /// No description provided for @forget_passwordd.
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forget_passwordd;

  /// No description provided for @forget_password.
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forget_password;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @email_associated_with_account.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address associated with your account.'**
  String get email_associated_with_account;

  /// No description provided for @send_email.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get send_email;

  /// No description provided for @enter_verification_code.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enter_verification_code;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @this_field_is_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get this_field_is_required;

  /// No description provided for @enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get enter_valid_email;

  /// No description provided for @enter_strong_password.
  ///
  /// In en, this message translates to:
  /// **'Enter strong password please'**
  String get enter_strong_password;

  /// No description provided for @password_not_matching.
  ///
  /// In en, this message translates to:
  /// **'Passwords not matching'**
  String get password_not_matching;

  /// No description provided for @enter_nums_only.
  ///
  /// In en, this message translates to:
  /// **'Enter nums only'**
  String get enter_nums_only;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @caring_for_my_child.
  ///
  /// In en, this message translates to:
  /// **'Caring for My Child'**
  String get caring_for_my_child;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome !\nHow can i help you ?'**
  String get welcome;

  /// No description provided for @what_is_visual_spatial_perception.
  ///
  /// In en, this message translates to:
  /// **'What is visual–spatial perception?'**
  String get what_is_visual_spatial_perception;

  /// No description provided for @how_is_visual_spatial_perception_related_to_autism.
  ///
  /// In en, this message translates to:
  /// **'How is visual–spatial perception related to autism?'**
  String get how_is_visual_spatial_perception_related_to_autism;

  /// No description provided for @game_improve.
  ///
  /// In en, this message translates to:
  /// **'What games improve visual–spatial skills'**
  String get game_improve;

  /// No description provided for @confusion.
  ///
  /// In en, this message translates to:
  /// **'How can I help my child with direction confusion?'**
  String get confusion;

  /// No description provided for @another_question.
  ///
  /// In en, this message translates to:
  /// **'Another Question'**
  String get another_question;

  /// No description provided for @visual_spatial_perception_meaning.
  ///
  /// In en, this message translates to:
  /// **'Visual–spatial perception is the ability to understand what we see and how objects relate to each other in space, such as shape, size, distance, and position (up, down, left, right).'**
  String get visual_spatial_perception_meaning;

  /// No description provided for @type_your_question_here.
  ///
  /// In en, this message translates to:
  /// **'Type your question here ...'**
  String get type_your_question_here;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password;

  /// No description provided for @frequently_asked_questions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequently_asked_questions;

  /// No description provided for @about_us.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get about_us;

  /// No description provided for @review_au_somes.
  ///
  /// In en, this message translates to:
  /// **'Review Au-somes'**
  String get review_au_somes;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @verification_code_sent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully'**
  String get verification_code_sent;

  /// No description provided for @failed_to_send_verification_code.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get failed_to_send_verification_code;

  /// No description provided for @verification_successful.
  ///
  /// In en, this message translates to:
  /// **'Verification successful'**
  String get verification_successful;

  /// No description provided for @enter_code.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enter_code;

  /// No description provided for @code_must_be_5.
  ///
  /// In en, this message translates to:
  /// **'Code must be exactly 5 digits'**
  String get code_must_be_5;

  /// No description provided for @code_must_contain_nums.
  ///
  /// In en, this message translates to:
  /// **'Code must contain only numbers'**
  String get code_must_contain_nums;

  /// No description provided for @password_changed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get password_changed_successfully;

  /// No description provided for @ask_chatbot.
  ///
  /// In en, this message translates to:
  /// **'Ask Chatbot'**
  String get ask_chatbot;

  /// No description provided for @get_instant_answers.
  ///
  /// In en, this message translates to:
  /// **'Get instant answers'**
  String get get_instant_answers;

  /// No description provided for @progress_level.
  ///
  /// In en, this message translates to:
  /// **'Progress Level'**
  String get progress_level;

  /// No description provided for @your_child_progress.
  ///
  /// In en, this message translates to:
  /// **'Your child\'s progress'**
  String get your_child_progress;

  /// No description provided for @overall_progress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overall_progress;

  /// No description provided for @activities_done.
  ///
  /// In en, this message translates to:
  /// **'Activities Done'**
  String get activities_done;

  /// No description provided for @stories_done.
  ///
  /// In en, this message translates to:
  /// **'Stories Done'**
  String get stories_done;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @new_word.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_word;

  /// No description provided for @today_progress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get today_progress;

  /// No description provided for @visual_spatial_visualization_activities.
  ///
  /// In en, this message translates to:
  /// **'Visual–Spatial Visualization Activities'**
  String get visual_spatial_visualization_activities;

  /// No description provided for @spatial_relations_activities.
  ///
  /// In en, this message translates to:
  /// **'Spatial Relations Activities'**
  String get spatial_relations_activities;

  /// No description provided for @spatial_concepts_activities.
  ///
  /// In en, this message translates to:
  /// **'Spatial Concepts Activities'**
  String get spatial_concepts_activities;

  /// No description provided for @update_profile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get update_profile;

  /// No description provided for @edit_profile_text.
  ///
  /// In en, this message translates to:
  /// **'Update your child\'s info for a better personalized experience.'**
  String get edit_profile_text;

  /// No description provided for @well_done.
  ///
  /// In en, this message translates to:
  /// **'Well Done'**
  String get well_done;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'...Thinking'**
  String get thinking;

  /// No description provided for @show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get show_more;

  /// No description provided for @show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get show_less;

  /// No description provided for @exceeded_api.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your daily API request limit. Please try again later.'**
  String get exceeded_api;

  /// No description provided for @error_try_again.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get error_try_again;

  /// No description provided for @daily_tips.
  ///
  /// In en, this message translates to:
  /// **'Daily Tips'**
  String get daily_tips;

  /// No description provided for @daily_routine.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get daily_routine;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
