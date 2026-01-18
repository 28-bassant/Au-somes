import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/splash_screen/splash_screen.dart';
import 'package:au_somes/ui/auth/forget_password/forged_password_screen1.dart';
import 'package:au_somes/ui/auth/forget_password/forget_password_screen2.dart';
import 'package:au_somes/ui/auth/forget_password/forget_password_screen3.dart';
import 'package:au_somes/ui/auth/login_screen/login_screen.dart';
import 'package:au_somes/ui/auth/register_screen/register_screen.dart';
import 'package:au_somes/ui/child_screen/child_screen.dart';
import 'package:au_somes/ui/parent_screen/parent_screen.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/chatbot_screen.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/progress_level/progress_level_screen.dart';
import 'package:au_somes/ui/parent_screen/tabs/profile_tab/features/edit_profile/edit_profile_screen.dart';
import 'package:au_somes/ui/select_screen/select_screen.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:au_somes/l10n/app_localizations.dart';

import 'core/cache/shared_prefs_utils.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsUtils.init();
  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppLanguageProvider(),),
      ],

      child: MyApp()));
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<AppLanguageProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.splashScreenRouteName,
      routes:  {
        AppRoutes.splashScreenRouteName : (context) => SplashScreen(),
        AppRoutes.loginScreenRouteName : (context) => LoginScreen(),
        AppRoutes.registerScreenRouteName : (context) => RegisterScreen(),
        AppRoutes.forgetPasswordScreen1RouteName:(context)=>ForgetPasswordScreen1(),
        AppRoutes.forgetPasswordScreen2RouteName:(context)=>ForgetPasswordScreen2(),
        AppRoutes.forgetPasswordScreen3RouteName:(context)=>ForgetPasswordScreen3(),
        AppRoutes.selectScreenRouteName:(context)=>SelectScreen(),
        AppRoutes.parentScreenRouteName:(context)=>ParentScreen(),
        AppRoutes.childScreenRouteName:(context)=>ChildScreen(),
        AppRoutes.chatbotScreenRouteName:(context)=>ChatbotScreen(),
        AppRoutes.progressLevelScreenRouteName:(context)=>ProgressLevelScreen(),
        AppRoutes.editProfileScreenRouteName:(context)=>EditProfileScreen(),


      },
      theme: AppTheme.lightTheme,
      locale: Locale(languageProvider.appLanguage),


    );
  }
}