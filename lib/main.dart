import 'package:au_somes/providers/app_language_provider.dart';
import 'package:au_somes/splash_screen/splash_screen.dart';
import 'package:au_somes/ui/auth/login_screen/login_screen.dart';
import 'package:au_somes/ui/auth/register_screen/register_screen.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:au_somes/l10n/app_localizations.dart';


void main(){
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
        AppRoutes.registerScreenRouteName : (context) => RegisterScreen(),
        AppRoutes.loginScreenRouteName : (context) => LoginScreen(),
      },
      theme: AppTheme.lightTheme,
      locale: Locale(languageProvider.appLanguage),


    );
  }
}