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
  /// **'What is spatial visualization?'**
  String get what_is_visual_spatial_perception;

  /// No description provided for @how_is_visual_spatial_perception_related_to_autism.
  ///
  /// In en, this message translates to:
  /// **'How is spatial visualization related to autism?'**
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

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminder_message.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for today\'s visual-spatial perception exercise.'**
  String get reminder_message;

  /// No description provided for @new_activity.
  ///
  /// In en, this message translates to:
  /// **'New Activity'**
  String get new_activity;

  /// No description provided for @new_activity_message.
  ///
  /// In en, this message translates to:
  /// **'A new activity is ready for your child.'**
  String get new_activity_message;

  /// No description provided for @daily_tips_message.
  ///
  /// In en, this message translates to:
  /// **'A new tip to support your child.'**
  String get daily_tips_message;

  /// No description provided for @ask_chatbot_now.
  ///
  /// In en, this message translates to:
  /// **'Ask Chatbot Now'**
  String get ask_chatbot_now;

  /// No description provided for @ask_chatbot_message.
  ///
  /// In en, this message translates to:
  /// **'Have a question? Ask the assistant now.'**
  String get ask_chatbot_message;

  /// No description provided for @support_message.
  ///
  /// In en, this message translates to:
  /// **'Your support makes a difference for your child'**
  String get support_message;

  /// No description provided for @minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'23min'**
  String get minutes_ago;

  /// No description provided for @days_ago.
  ///
  /// In en, this message translates to:
  /// **' day'**
  String get days_ago;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @visual_spatial_perception.
  ///
  /// In en, this message translates to:
  /// **'Spatial Visualization'**
  String get visual_spatial_perception;

  /// No description provided for @spatial_concepts.
  ///
  /// In en, this message translates to:
  /// **'Spatial Concepts'**
  String get spatial_concepts;

  /// No description provided for @spatial_relations.
  ///
  /// In en, this message translates to:
  /// **'Spatial Relations'**
  String get spatial_relations;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @above_under.
  ///
  /// In en, this message translates to:
  /// **'Above & Under Activities'**
  String get above_under;

  /// No description provided for @right_left.
  ///
  /// In en, this message translates to:
  /// **'Right & Left Activities'**
  String get right_left;

  /// No description provided for @front_back.
  ///
  /// In en, this message translates to:
  /// **'Front & Back Activities'**
  String get front_back;

  /// No description provided for @near_far.
  ///
  /// In en, this message translates to:
  /// **'Near & Far Activities'**
  String get near_far;

  /// No description provided for @inside_outside.
  ///
  /// In en, this message translates to:
  /// **'Inside & Outside Activities'**
  String get inside_outside;

  /// No description provided for @between.
  ///
  /// In en, this message translates to:
  /// **'Between'**
  String get between;

  /// No description provided for @current_progress.
  ///
  /// In en, this message translates to:
  /// **'Current Progress'**
  String get current_progress;

  /// No description provided for @of_word.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get of_word;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @morning_routine.
  ///
  /// In en, this message translates to:
  /// **'Morning Routine'**
  String get morning_routine;

  /// No description provided for @afternoon_routine.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Routine'**
  String get afternoon_routine;

  /// No description provided for @evening_routine.
  ///
  /// In en, this message translates to:
  /// **'Evening Routine'**
  String get evening_routine;

  /// No description provided for @wake_up.
  ///
  /// In en, this message translates to:
  /// **'Wake up & Stretch'**
  String get wake_up;

  /// No description provided for @morning_hygiene.
  ///
  /// In en, this message translates to:
  /// **'Morning Hygiene'**
  String get morning_hygiene;

  /// No description provided for @breakfast_time.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Time'**
  String get breakfast_time;

  /// No description provided for @quiet_time.
  ///
  /// In en, this message translates to:
  /// **'Quiet Time'**
  String get quiet_time;

  /// No description provided for @school_work.
  ///
  /// In en, this message translates to:
  /// **'School Work'**
  String get school_work;

  /// No description provided for @snack_time.
  ///
  /// In en, this message translates to:
  /// **'Snack Time'**
  String get snack_time;

  /// No description provided for @physical_activity.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity '**
  String get physical_activity;

  /// No description provided for @lunch_time.
  ///
  /// In en, this message translates to:
  /// **'Lunch Time'**
  String get lunch_time;

  /// No description provided for @nap.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get nap;

  /// No description provided for @interactive_activity.
  ///
  /// In en, this message translates to:
  /// **'Interactive Activity'**
  String get interactive_activity;

  /// No description provided for @dinner_time.
  ///
  /// In en, this message translates to:
  /// **'Dinner Time'**
  String get dinner_time;

  /// No description provided for @stories_time.
  ///
  /// In en, this message translates to:
  /// **'Stories Time'**
  String get stories_time;

  /// No description provided for @bed_time_routine.
  ///
  /// In en, this message translates to:
  /// **'Bed Time Routine'**
  String get bed_time_routine;

  /// No description provided for @bed_time.
  ///
  /// In en, this message translates to:
  /// **'Bed Time'**
  String get bed_time;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @complete_activity.
  ///
  /// In en, this message translates to:
  /// **'Well done 👏\nYou completed all the activities'**
  String get complete_activity;

  /// No description provided for @asperger.
  ///
  /// In en, this message translates to:
  /// **'The next 3 activities are for children with Asperger’s'**
  String get asperger;

  /// No description provided for @asperger2.
  ///
  /// In en, this message translates to:
  /// **'The next activity is for children with Asperger’s'**
  String get asperger2;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @first_activity.
  ///
  /// In en, this message translates to:
  /// **'This is actually the first activity!'**
  String get first_activity;

  /// No description provided for @helpful_tips.
  ///
  /// In en, this message translates to:
  /// **'Helpful tips for today'**
  String get helpful_tips;

  /// No description provided for @all_tips.
  ///
  /// In en, this message translates to:
  /// **'All Tips'**
  String get all_tips;

  /// No description provided for @sensory_tips.
  ///
  /// In en, this message translates to:
  /// **'Sensory Tips'**
  String get sensory_tips;

  /// No description provided for @sensory.
  ///
  /// In en, this message translates to:
  /// **'Sensory'**
  String get sensory;

  /// No description provided for @communication_tips.
  ///
  /// In en, this message translates to:
  /// **'Communication Tips'**
  String get communication_tips;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @behavioural_tips.
  ///
  /// In en, this message translates to:
  /// **'Behavioural Tips'**
  String get behavioural_tips;

  /// No description provided for @behavioural.
  ///
  /// In en, this message translates to:
  /// **'Behavioural'**
  String get behavioural;

  /// No description provided for @featured_article.
  ///
  /// In en, this message translates to:
  /// **'Featured Article'**
  String get featured_article;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @expert_advice.
  ///
  /// In en, this message translates to:
  /// **'Expert Advice'**
  String get expert_advice;

  /// No description provided for @article_title.
  ///
  /// In en, this message translates to:
  /// **'Establishing Morning Routines'**
  String get article_title;

  /// No description provided for @article_content.
  ///
  /// In en, this message translates to:
  /// **'Learn how visual schedules can significantly reduce transition anxiety for your child during the busy morning rush'**
  String get article_content;

  /// No description provided for @sensory_tip1_title.
  ///
  /// In en, this message translates to:
  /// **'Sound (Auditory)'**
  String get sensory_tip1_title;

  /// No description provided for @sensory_tip1_content1.
  ///
  /// In en, this message translates to:
  /// **'• Noise reduction: Use high-quality noise-cancelling earmuffs or soft silicone earplugs in loud or echoey environments.'**
  String get sensory_tip1_content1;

  /// No description provided for @sensory_tip1_content2.
  ///
  /// In en, this message translates to:
  /// **'• Calming sounds: Utilize white noise, pink noise, or ambient, soothing playlists during stressful moments or before bedtime.'**
  String get sensory_tip1_content2;

  /// No description provided for @sensory_tip1_content3.
  ///
  /// In en, this message translates to:
  /// **'• Headphone pairing: If your child is sensitive to sound but dislikes how headphones feel, slowly desensitize them by pairing headphones with highly preferred activities (e.g., watching a favorite video).'**
  String get sensory_tip1_content3;

  /// No description provided for @sensory_tip2_title.
  ///
  /// In en, this message translates to:
  /// **'Touch (Tactile)'**
  String get sensory_tip2_title;

  /// No description provided for @sensory_tip2_content1.
  ///
  /// In en, this message translates to:
  /// **'• Clothing modifications: Cut out scratchy tags, flip clothes inside out to hide seams, or opt for seamless, soft-knit clothing and Lycra undergarments.'**
  String get sensory_tip2_content1;

  /// No description provided for @sensory_tip2_content2.
  ///
  /// In en, this message translates to:
  /// **'• Deep pressure: Offer comforting, deep-pressure input through weighted lap pads, weighted blankets, or tight, secure hugs.'**
  String get sensory_tip2_content2;

  /// No description provided for @sensory_tip2_content3.
  ///
  /// In en, this message translates to:
  /// **'• Tactile play: Encourage hands-on play with non-food or food items to build tolerance to different textures. Examples include kinetic sand, playdough, dry beans, or water beads.'**
  String get sensory_tip2_content3;

  /// No description provided for @sensory_tip3_title.
  ///
  /// In en, this message translates to:
  /// **'Balance and Movement (Vestibular & Proprioceptive)'**
  String get sensory_tip3_title;

  /// No description provided for @sensory_tip3_content1.
  ///
  /// In en, this message translates to:
  /// **'• Heavy work: Heavy lifting, pushing, or pulling gives muscles and joints feedback that helps the brain relax. Try wheelbarrow walking or carrying weighted objects.'**
  String get sensory_tip3_content1;

  /// No description provided for @sensory_tip3_content2.
  ///
  /// In en, this message translates to:
  /// **'• Movement breaks: Incorporate a small indoor trampoline, a therapy ball to bounce on, or a sensory swing to give them the motion they crave safely.'**
  String get sensory_tip3_content2;

  /// No description provided for @sensory_tip3_content3.
  ///
  /// In en, this message translates to:
  /// **'• Active seating: Use wobble stools or inflatable canoe chairs to allow movement while staying seated at a desk or table.'**
  String get sensory_tip3_content3;

  /// No description provided for @sensory_tip4_title.
  ///
  /// In en, this message translates to:
  /// **'Sight (Visual)'**
  String get sensory_tip4_title;

  /// No description provided for @sensory_tip4_content1.
  ///
  /// In en, this message translates to:
  /// **'• Adjust lighting: Dim overhead fluorescent lights and utilize softer, warmer lamps, or string lights in specific zones.'**
  String get sensory_tip4_content1;

  /// No description provided for @sensory_tip4_content2.
  ///
  /// In en, this message translates to:
  /// **'• Sensory go-bags: Always carry good-quality sunglasses and a wide-brimmed hat to protect against bright lights in public.'**
  String get sensory_tip4_content2;

  /// No description provided for @sensory_tip4_content3.
  ///
  /// In en, this message translates to:
  /// **'• Visual calming: Use visually mesmerizing, calming tools like lava lamps, bubble walls, or DIY \"calm down\" bottles (glitter and water in a sealed jar).'**
  String get sensory_tip4_content3;

  /// No description provided for @sensory_tip5_title.
  ///
  /// In en, this message translates to:
  /// **'Smell & Taste (Olfactory & Gustatory)'**
  String get sensory_tip5_title;

  /// No description provided for @sensory_tip5_content1.
  ///
  /// In en, this message translates to:
  /// **'• Masking triggers: If your child is overwhelmed by smells (like perfumes or cleaning supplies), apply a drop of a calming, preferred essential oil or lotion to a sweatband they can wear and sniff.'**
  String get sensory_tip5_content1;

  /// No description provided for @sensory_tip5_content2.
  ///
  /// In en, this message translates to:
  /// **'• Oral sensory tools: Provide safe chewing options like chewable jewelry or chew toys to satisfy oral fixation.'**
  String get sensory_tip5_content2;

  /// No description provided for @sensory_tip5_content3.
  ///
  /// In en, this message translates to:
  /// **'• Flavor exploration: Encourage food play and gradual exposure to strongly flavored or distinct temperature foods to help with aversions.'**
  String get sensory_tip5_content3;

  /// No description provided for @sensory_tip6_title.
  ///
  /// In en, this message translates to:
  /// **'Create a \"Calm Corner\"'**
  String get sensory_tip6_title;

  /// No description provided for @sensory_tip6_content1.
  ///
  /// In en, this message translates to:
  /// **'• Designate a specific, quiet, and clutter-free space in your home featuring low lighting, pillows, and a weighted blanket. Allow your child to retreat to this space when they feel overwhelmed or just need to \"recharge\" their batteries.'**
  String get sensory_tip6_content1;

  /// No description provided for @general_sensory_tip_title.
  ///
  /// In en, this message translates to:
  /// **'Supporting Sensory Needs'**
  String get general_sensory_tip_title;

  /// No description provided for @general_sensory_tip_description.
  ///
  /// In en, this message translates to:
  /// **'Many children with autism are sensitive to sound, light, touch, or textures.'**
  String get general_sensory_tip_description;

  /// No description provided for @general_sensory_tip_title1.
  ///
  /// In en, this message translates to:
  /// **'• Create a quiet, safe space at home.'**
  String get general_sensory_tip_title1;

  /// No description provided for @general_sensory_tip_title2.
  ///
  /// In en, this message translates to:
  /// **'• Allow headphones if noise is stressful.'**
  String get general_sensory_tip_title2;

  /// No description provided for @general_sensory_tip_title3.
  ///
  /// In en, this message translates to:
  /// **'• Respect food texture preferences.'**
  String get general_sensory_tip_title3;

  /// No description provided for @general_sensory_tip_title4.
  ///
  /// In en, this message translates to:
  /// **'• Introduce new sensations slowly.'**
  String get general_sensory_tip_title4;

  /// No description provided for @general_communication_tip_title.
  ///
  /// In en, this message translates to:
  /// **'Supporting Communication'**
  String get general_communication_tip_title;

  /// No description provided for @general_communication_tip_description.
  ///
  /// In en, this message translates to:
  /// **'Children with autism may communicate in different ways including words or gestures.'**
  String get general_communication_tip_description;

  /// No description provided for @general_communication_tip_title1.
  ///
  /// In en, this message translates to:
  /// **'• Get your child’s attention before speaking.'**
  String get general_communication_tip_title1;

  /// No description provided for @general_communication_tip_title2.
  ///
  /// In en, this message translates to:
  /// **'• Speak slowly and clearly.'**
  String get general_communication_tip_title2;

  /// No description provided for @general_communication_tip_title3.
  ///
  /// In en, this message translates to:
  /// **'• Use consistent words.'**
  String get general_communication_tip_title3;

  /// No description provided for @general_communication_tip_title4.
  ///
  /// In en, this message translates to:
  /// **'• Allow extra time to respond.'**
  String get general_communication_tip_title4;

  /// No description provided for @general_behavioural_tip_title.
  ///
  /// In en, this message translates to:
  /// **'Understanding Behaviour'**
  String get general_behavioural_tip_title;

  /// No description provided for @general_behavioural_tip_description.
  ///
  /// In en, this message translates to:
  /// **'Behaviour is a form of communication for children with autism. Challenging behaviour often means the child is feeling overwhelmed, confused, or unable to express needs.'**
  String get general_behavioural_tip_description;

  /// No description provided for @general_behavioural_tip_title1.
  ///
  /// In en, this message translates to:
  /// **'• Observe behaviour patterns carefully.'**
  String get general_behavioural_tip_title1;

  /// No description provided for @general_behavioural_tip_title2.
  ///
  /// In en, this message translates to:
  /// **'• Look for reasons behind the behaviour.'**
  String get general_behavioural_tip_title2;

  /// No description provided for @general_behavioural_tip_title3.
  ///
  /// In en, this message translates to:
  /// **'• Remember that behaviour is not intentional misbehaviour.'**
  String get general_behavioural_tip_title3;

  /// No description provided for @general_behavioural_tip_title4.
  ///
  /// In en, this message translates to:
  /// **'• Focus on understanding, not punishment.'**
  String get general_behavioural_tip_title4;

  /// No description provided for @communication_tip1_title.
  ///
  /// In en, this message translates to:
  /// **'Speak directly and literally:'**
  String get communication_tip1_title;

  /// No description provided for @communication_tip1_content.
  ///
  /// In en, this message translates to:
  /// **'Avoid sarcasm, idioms, or abstract concepts. Use short, clear phrases and tell them exactly what you want them to do, rather than what not to do.'**
  String get communication_tip1_content;

  /// No description provided for @communication_tip2_title.
  ///
  /// In en, this message translates to:
  /// **'Allow processing time:'**
  String get communication_tip2_title;

  /// No description provided for @communication_tip2_content.
  ///
  /// In en, this message translates to:
  /// **'It can take autistic children longer to process spoken information. Ask your question or give your instruction, then wait at least 10 seconds before speaking again.'**
  String get communication_tip2_content;

  /// No description provided for @communication_tip3_title.
  ///
  /// In en, this message translates to:
  /// **'Use visual supports:'**
  String get communication_tip3_title;

  /// No description provided for @communication_tip3_content.
  ///
  /// In en, this message translates to:
  /// **'Many autistic children are highly visual learners. Pair your words with pointing, gestures, or use visual schedules and picture boards (like PECS) to help them understand daily routines and choices.'**
  String get communication_tip3_content;

  /// No description provided for @communication_tip4_title.
  ///
  /// In en, this message translates to:
  /// **'Follow their lead:'**
  String get communication_tip4_title;

  /// No description provided for @communication_tip4_content.
  ///
  /// In en, this message translates to:
  /// **'Instead of interrupting their focus to prompt speech, join in and comment on what they are doing. This builds trust and shared attention.'**
  String get communication_tip4_content;

  /// No description provided for @communication_tip5_title.
  ///
  /// In en, this message translates to:
  /// **'Offer clear choices:'**
  String get communication_tip5_title;

  /// No description provided for @communication_tip5_content.
  ///
  /// In en, this message translates to:
  /// **'Open-ended questions (e.g., \"What do you want to do?\") can be overwhelming. Instead, offer a clear, limited set of physical choices (e.g., \"Do you want the red cup or the blue cup?\").'**
  String get communication_tip5_content;

  /// No description provided for @communication_tip6_title.
  ///
  /// In en, this message translates to:
  /// **'Accept all forms of communication:'**
  String get communication_tip6_title;

  /// No description provided for @communication_tip6_content.
  ///
  /// In en, this message translates to:
  /// **' Speech is only one way to communicate. Be responsive to gestures, sounds, pointing, and Augmentative and Alternative Communication (AAC) devices.'**
  String get communication_tip6_content;

  /// No description provided for @behavioural_tip1_title.
  ///
  /// In en, this message translates to:
  /// **'Identify the Root Cause'**
  String get behavioural_tip1_title;

  /// No description provided for @behavioural_tip1_content1.
  ///
  /// In en, this message translates to:
  /// **'• Observe Triggers: Figure out what happens immediately before a behavior. Is the child trying to avoid a task, seeking sensory input, or feeling overstimulated in a noisy environment?'**
  String get behavioural_tip1_content1;

  /// No description provided for @behavioural_tip1_content2.
  ///
  /// In en, this message translates to:
  /// **'• Address Sensory Needs: If a child becomes overwhelmed, provide a safe, calm-down space with sensory tools like weighted blankets or noise-canceling headphones.'**
  String get behavioural_tip1_content2;

  /// No description provided for @behavioural_tip2_title.
  ///
  /// In en, this message translates to:
  /// **'Communicate Clearly & Predictably'**
  String get behavioural_tip2_title;

  /// No description provided for @behavioural_tip2_content1.
  ///
  /// In en, this message translates to:
  /// **'• Use Visual Schedules: Use pictures or a timeline to help the child understand daily routines and transitions, which reduces anxiety.'**
  String get behavioural_tip2_content1;

  /// No description provided for @behavioural_tip2_content2.
  ///
  /// In en, this message translates to:
  /// **'• Give \"First/Then\" Statements: Instead of saying \"stop playing,\" say, \"First we finish our lunch, then we can play\".'**
  String get behavioural_tip2_content2;

  /// No description provided for @behavioural_tip2_content3.
  ///
  /// In en, this message translates to:
  /// **'• Limit \"Don\'ts\": Phrase instructions positively. Instead of \"Don\'t run,\" try \"Walk on the sidewalk\".'**
  String get behavioural_tip2_content3;

  /// No description provided for @behavioural_tip3_title.
  ///
  /// In en, this message translates to:
  /// **'Foster Agency and Success'**
  String get behavioural_tip3_title;

  /// No description provided for @behavioural_tip3_content1.
  ///
  /// In en, this message translates to:
  /// **'• Offer Controlled Choices: Give a sense of control by offering limited, acceptable choices (e.g., \"Do you want to wear the red or blue shirt?\").'**
  String get behavioural_tip3_content1;

  /// No description provided for @behavioural_tip3_content2.
  ///
  /// In en, this message translates to:
  /// **'• Chunk Tasks: Break down overwhelming tasks (like homework) into small, manageable steps.'**
  String get behavioural_tip3_content2;

  /// No description provided for @behavioural_tip4_title.
  ///
  /// In en, this message translates to:
  /// **'Apply Positive Reinforcement'**
  String get behavioural_tip4_title;

  /// No description provided for @behavioural_tip4_content1.
  ///
  /// In en, this message translates to:
  /// **'• Catch Them Being Good: Praise specific positive behaviors immediately. (e.g., \"I love how nicely you are sitting at the table!\")'**
  String get behavioural_tip4_content1;

  /// No description provided for @behavioural_tip4_content2.
  ///
  /// In en, this message translates to:
  /// **'• Provide Breaks: Teach your child to request a break using a specific cue or \"Break\" card to regroup when frustrated.'**
  String get behavioural_tip4_content2;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated Successfully'**
  String get profile_updated;

  /// No description provided for @failed_profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failed_profile_updated;

  /// No description provided for @enter_valid_age.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid Age'**
  String get enter_valid_age;

  /// No description provided for @autism_centers.
  ///
  /// In en, this message translates to:
  /// **'Specialized Autism Centers in Egypt'**
  String get autism_centers;

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get nearest;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sorts'**
  String get sort;

  /// No description provided for @no_centers_found.
  ///
  /// In en, this message translates to:
  /// **'No Centers Found'**
  String get no_centers_found;

  /// No description provided for @visual_spatial_perception_definition.
  ///
  /// In en, this message translates to:
  /// **'Spatial visualization is the ability to mentally imagine objects, understand their positions and directions, and manipulate them in space.'**
  String get visual_spatial_perception_definition;

  /// No description provided for @visual_spatial_autism_info.
  ///
  /// In en, this message translates to:
  /// **'Although some autistic individuals demonstrate strengths in specific visual-spatial tasks, spatial skills vary widely across the autism spectrum. Structured training can help improve spatial orientation, directional awareness, and functional navigation skills.'**
  String get visual_spatial_autism_info;

  /// No description provided for @visual_spatial_games.
  ///
  /// In en, this message translates to:
  /// **'Jigsaw puzzles, tangrams, LEGO building, maze games, and shape-matching activities can help improve visual–spatial skills.'**
  String get visual_spatial_games;

  /// No description provided for @visual_spatial_training_tips.
  ///
  /// In en, this message translates to:
  /// **'Help your child learn directions through visual cues, simple navigation games, obstacle courses, and consistent practice with concepts like left/right, up/down, and front/back.'**
  String get visual_spatial_training_tips;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Food Delivery'**
  String get title;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivering the hot pizza to Grandma\'s house 🧓'**
  String get subtitle;

  /// No description provided for @above.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get above;

  /// No description provided for @under.
  ///
  /// In en, this message translates to:
  /// **'Under'**
  String get under;

  /// No description provided for @near.
  ///
  /// In en, this message translates to:
  /// **'Near'**
  String get near;

  /// No description provided for @far.
  ///
  /// In en, this message translates to:
  /// **'Far'**
  String get far;

  /// No description provided for @inside.
  ///
  /// In en, this message translates to:
  /// **'Inside'**
  String get inside;

  /// No description provided for @outside.
  ///
  /// In en, this message translates to:
  /// **'Outside'**
  String get outside;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @visual_perception.
  ///
  /// In en, this message translates to:
  /// **'Visual Perception'**
  String get visual_perception;

  /// No description provided for @interactive_story.
  ///
  /// In en, this message translates to:
  /// **'Interactive Story'**
  String get interactive_story;

  /// No description provided for @story_time_header.
  ///
  /// In en, this message translates to:
  /// **'Custom Story + Spatial Training + Visual Perception'**
  String get story_time_header;

  /// No description provided for @enter_child_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Child Name'**
  String get enter_child_name;

  /// No description provided for @story_theme.
  ///
  /// In en, this message translates to:
  /// **'Story Theme'**
  String get story_theme;

  /// No description provided for @spatial_visual_for_training.
  ///
  /// In en, this message translates to:
  /// **'Spatial and Visual Concepts for Training'**
  String get spatial_visual_for_training;

  /// No description provided for @start_interactive_story.
  ///
  /// In en, this message translates to:
  /// **'✨ Start the Interactive Story ✨'**
  String get start_interactive_story;

  /// No description provided for @day_at_kindergarten.
  ///
  /// In en, this message translates to:
  /// **'A Day at Kindergarten🏠'**
  String get day_at_kindergarten;

  /// No description provided for @park_outing.
  ///
  /// In en, this message translates to:
  /// **'Park Outing🌴'**
  String get park_outing;

  /// No description provided for @day_at_school.
  ///
  /// In en, this message translates to:
  /// **'A Day at School 🏫'**
  String get day_at_school;

  /// No description provided for @fun_at_kitchen.
  ///
  /// In en, this message translates to:
  /// **'Fun in the Kitchen 🍳'**
  String get fun_at_kitchen;

  /// No description provided for @space_adventure.
  ///
  /// In en, this message translates to:
  /// **'Space Adventure🚀'**
  String get space_adventure;

  /// No description provided for @underwater_world.
  ///
  /// In en, this message translates to:
  /// **'Underwater World🐠'**
  String get underwater_world;

  /// No description provided for @supermarket_trip.
  ///
  /// In en, this message translates to:
  /// **'Supermarket Trip🛒'**
  String get supermarket_trip;

  /// No description provided for @generating_interactive_story.
  ///
  /// In en, this message translates to:
  /// **'Generating Interactive Story'**
  String get generating_interactive_story;

  /// No description provided for @excellent_you_answered.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You answered all correctly!'**
  String get excellent_you_answered;

  /// No description provided for @well_done_keep_practicing.
  ///
  /// In en, this message translates to:
  /// **'Well done! Keep practicing!'**
  String get well_done_keep_practicing;

  /// No description provided for @keep_trying_you_will_improve.
  ///
  /// In en, this message translates to:
  /// **'Keep trying, you\'ll improve'**
  String get keep_trying_you_will_improve;

  /// No description provided for @story_complete.
  ///
  /// In en, this message translates to:
  /// **'Story Complete! 🎊'**
  String get story_complete;

  /// No description provided for @your_score.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get your_score;

  /// No description provided for @new_story.
  ///
  /// In en, this message translates to:
  /// **'New Story ✨'**
  String get new_story;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @where_is_pizza.
  ///
  /// In en, this message translates to:
  /// **'Where is the pizza?'**
  String get where_is_pizza;

  /// No description provided for @inside_box.
  ///
  /// In en, this message translates to:
  /// **'Inside the box'**
  String get inside_box;

  /// No description provided for @outside_box.
  ///
  /// In en, this message translates to:
  /// **'Outside the box'**
  String get outside_box;

  /// No description provided for @where_is_bag.
  ///
  /// In en, this message translates to:
  /// **'Where is the delivery bag?'**
  String get where_is_bag;

  /// No description provided for @at_back.
  ///
  /// In en, this message translates to:
  /// **'At the back'**
  String get at_back;

  /// No description provided for @at_front.
  ///
  /// In en, this message translates to:
  /// **'At the front'**
  String get at_front;

  /// No description provided for @where_is_grandma.
  ///
  /// In en, this message translates to:
  /// **'Where is Grandma standing?'**
  String get where_is_grandma;

  /// No description provided for @in_front_of_door.
  ///
  /// In en, this message translates to:
  /// **'In front of the door'**
  String get in_front_of_door;

  /// No description provided for @behind_door.
  ///
  /// In en, this message translates to:
  /// **'Behind the door'**
  String get behind_door;

  /// No description provided for @pizza_hint.
  ///
  /// In en, this message translates to:
  /// **'The pizza is inside the cardboard box.'**
  String get pizza_hint;

  /// No description provided for @bag_hint.
  ///
  /// In en, this message translates to:
  /// **'The bag is placed at the back of the bicycle.'**
  String get bag_hint;

  /// No description provided for @grandma_hint.
  ///
  /// In en, this message translates to:
  /// **'Grandma is standing in front of the house door.'**
  String get grandma_hint;

  /// No description provided for @keep_going.
  ///
  /// In en, this message translates to:
  /// **'Keep going like this'**
  String get keep_going;

  /// No description provided for @wonderful.
  ///
  /// In en, this message translates to:
  /// **'Wonderful! 🎉'**
  String get wonderful;

  /// No description provided for @lets_try_again.
  ///
  /// In en, this message translates to:
  /// **'Let\'s try again together'**
  String get lets_try_again;

  /// No description provided for @please_choose_story_theme.
  ///
  /// In en, this message translates to:
  /// **'Please choose story theme'**
  String get please_choose_story_theme;

  /// No description provided for @please_select_exactly_concepts.
  ///
  /// In en, this message translates to:
  /// **'Please select exactly 3 concepts'**
  String get please_select_exactly_concepts;

  /// No description provided for @how_would_you_rate_our_app.
  ///
  /// In en, this message translates to:
  /// **'How would you rate our app?'**
  String get how_would_you_rate_our_app;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @learning_status.
  ///
  /// In en, this message translates to:
  /// **'Learning Status'**
  String get learning_status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @thank_you_for_rating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback'**
  String get thank_you_for_rating;

  /// No description provided for @about_us_title.
  ///
  /// In en, this message translates to:
  /// **'Empowering Every Child to Learn, Grow, and Shine'**
  String get about_us_title;

  /// No description provided for @about_us_content.
  ///
  /// In en, this message translates to:
  /// **'AU-Somes is an educational and interactive application designed to support children with Autism Spectrum Disorder (ASD) in developing essential cognitive, communication, and daily living skills through engaging activities and personalized learning experiences.\n\nOur mission is to provide a safe, enjoyable, and accessible environment where children can learn at their own pace while helping parents and therapists monitor their progress. The application includes educational games, storytelling, visual learning activities, and progress tracking to encourage continuous development.\n\nAt AU-Somes, we believe that every child has unique abilities and deserves learning tools that meet their individual needs. Our goal is to make learning more enjoyable, inclusive, and effective for every child.'**
  String get about_us_content;

  /// No description provided for @ques1.
  ///
  /// In en, this message translates to:
  /// **'What is Autism Spectrum Disorder (ASD)?'**
  String get ques1;

  /// No description provided for @ans1.
  ///
  /// In en, this message translates to:
  /// **'Autism Spectrum Disorder (ASD) is a developmental condition that affects communication, social interaction, behavior, and learning. Every child with autism is unique and may have different strengths and challenges.'**
  String get ans1;

  /// No description provided for @ques2.
  ///
  /// In en, this message translates to:
  /// **'What are the early signs of autism?'**
  String get ques2;

  /// No description provided for @ans2.
  ///
  /// In en, this message translates to:
  /// **'Common early signs include delayed speech, limited eye contact, difficulty responding to their name, repetitive behaviors, and reduced interest in social interaction. Signs vary from one child to another.'**
  String get ans2;

  /// No description provided for @ques3.
  ///
  /// In en, this message translates to:
  /// **'Can children with autism improve their skills?'**
  String get ques3;

  /// No description provided for @ans3.
  ///
  /// In en, this message translates to:
  /// **'Yes. With early intervention, consistent practice, and personalized learning, many children improve their communication, cognitive, social, and daily living skills.'**
  String get ans3;

  /// No description provided for @ques4.
  ///
  /// In en, this message translates to:
  /// **'Why are visual activities important for children with autism?'**
  String get ques4;

  /// No description provided for @ans4.
  ///
  /// In en, this message translates to:
  /// **'Visual activities help children improve attention, problem-solving, spatial awareness, and memory while making learning more engaging and easier to understand.'**
  String get ans4;

  /// No description provided for @ques5.
  ///
  /// In en, this message translates to:
  /// **'What is visual-spatial perception?'**
  String get ques5;

  /// No description provided for @ans5.
  ///
  /// In en, this message translates to:
  /// **'Visual-spatial perception is the ability to understand where objects are located in space and how they relate to each other. It helps children recognize shapes, directions, distances, and positions.'**
  String get ans5;

  /// No description provided for @ques6.
  ///
  /// In en, this message translates to:
  /// **'Why is visual-spatial perception important?'**
  String get ques6;

  /// No description provided for @ans6.
  ///
  /// In en, this message translates to:
  /// **'It supports reading, writing, drawing, solving puzzles, navigating environments, and performing everyday tasks independently.'**
  String get ans6;

  /// No description provided for @ques7.
  ///
  /// In en, this message translates to:
  /// **'What activities improve visual-spatial skills?'**
  String get ques7;

  /// No description provided for @ans7.
  ///
  /// In en, this message translates to:
  /// **'Puzzles, matching games, block building, sorting objects, drawing, mazes, and memory games can strengthen visual-spatial perception.'**
  String get ans7;

  /// No description provided for @ques8.
  ///
  /// In en, this message translates to:
  /// **'Why is routine important for children with autism?'**
  String get ques8;

  /// No description provided for @ans8.
  ///
  /// In en, this message translates to:
  /// **'A consistent daily routine helps children feel safe, reduces anxiety, and makes it easier to understand expectations and transitions.'**
  String get ans8;

  /// No description provided for @ques9.
  ///
  /// In en, this message translates to:
  /// **'How can parents support learning at home?'**
  String get ques9;

  /// No description provided for @ans9.
  ///
  /// In en, this message translates to:
  /// **'Parents can encourage learning by practicing activities regularly, giving clear instructions, using positive reinforcement, and celebrating small achievements.'**
  String get ans9;

  /// No description provided for @ques10.
  ///
  /// In en, this message translates to:
  /// **'What are sensory sensitivities?'**
  String get ques10;

  /// No description provided for @ans10.
  ///
  /// In en, this message translates to:
  /// **'Some children with autism may be highly sensitive or less responsive to sounds, lights, textures, smells, or touch. These sensitivities differ from child to child.'**
  String get ans10;

  /// No description provided for @ques11.
  ///
  /// In en, this message translates to:
  /// **'Why is positive reinforcement important?'**
  String get ques11;

  /// No description provided for @ans11.
  ///
  /// In en, this message translates to:
  /// **'Positive reinforcement motivates children by rewarding desired behaviors, increasing confidence, and encouraging continued learning.'**
  String get ans11;

  /// No description provided for @ques12.
  ///
  /// In en, this message translates to:
  /// **'Can autism be cured?'**
  String get ques12;

  /// No description provided for @ans12.
  ///
  /// In en, this message translates to:
  /// **'Autism is not a disease and does not have a cure. However, therapy, education, and support can help children develop important life skills and reach their full potential.'**
  String get ans12;

  /// No description provided for @ques13.
  ///
  /// In en, this message translates to:
  /// **'How can technology help children with autism?'**
  String get ques13;

  /// No description provided for @ans13.
  ///
  /// In en, this message translates to:
  /// **'Educational applications provide interactive activities, personalized learning, and engaging experiences that support communication, cognitive development, and independence.'**
  String get ans13;

  /// No description provided for @ques14.
  ///
  /// In en, this message translates to:
  /// **'Why should progress be tracked?'**
  String get ques14;

  /// No description provided for @ans14.
  ///
  /// In en, this message translates to:
  /// **'Tracking progress helps parents and specialists identify strengths, recognize areas that need improvement, and adjust learning plans accordingly.'**
  String get ans14;

  /// No description provided for @ques15.
  ///
  /// In en, this message translates to:
  /// **'What should I do if my child struggles with an activity?'**
  String get ques15;

  /// No description provided for @ans15.
  ///
  /// In en, this message translates to:
  /// **'Stay patient, encourage your child, simplify the task if needed, and allow breaks. Learning happens gradually, and every small achievement is valuable.'**
  String get ans15;

  /// No description provided for @ques16.
  ///
  /// In en, this message translates to:
  /// **'How often should my child use the app?'**
  String get ques16;

  /// No description provided for @ans16.
  ///
  /// In en, this message translates to:
  /// **'Short, regular sessions of 15–30 minutes a day are generally more effective than long sessions, depending on the child\'s attention span and individual needs.'**
  String get ans16;
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
