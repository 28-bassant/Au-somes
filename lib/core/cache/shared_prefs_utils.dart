import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static late SharedPreferences sharedPrefs;

  static Future<void> init() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is int) {
      return sharedPrefs.setInt(key, value);
    } else if (value is String) {
      return sharedPrefs.setString(key, value);
    } else if (value is bool) {
      return sharedPrefs.setBool(key, value);
    } else if (value is double) {
      return sharedPrefs.setDouble(key, value);
    } else if (value is List<String>) {
      return sharedPrefs.setStringList(key, value);
    }
    return false;
  }

  static Object? getData({required String key}) {
    if (!sharedPrefs.containsKey(key)) return null;
    return sharedPrefs.get(key);
  }

  static Future<bool> removeData({required String key}) async {
    return sharedPrefs.remove(key);
  }
}