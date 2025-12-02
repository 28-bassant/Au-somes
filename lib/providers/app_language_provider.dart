import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/lang_shared_prefs.dart';

class AppLanguageProvider extends ChangeNotifier{
  String appLanguage = 'en';

  void changeLanguage(String newLanguage) async {
    if(appLanguage == newLanguage){
      return;
    }
    appLanguage = newLanguage;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPrefsKeys.languageKey, newLanguage);
    notifyListeners();
  }

  Future<void> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString(SharedPrefsKeys.languageKey);
    if (language != null && language.isNotEmpty) {
      appLanguage = language;
      notifyListeners();
    }
  }
  bool isArabic() {
    return appLanguage == 'ar';
  }
}