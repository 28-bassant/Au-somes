import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils{
  static late SharedPreferences sharedPrefs;

  static Future<SharedPreferences> init()async{
    return sharedPrefs = await SharedPreferences.getInstance();
  }

  //todo: save data => write
  static Future<bool> saveData({required String key,required dynamic value})async{
    if(value is int){
      return await sharedPrefs.setInt(key, value);
    }else if(value is String){
      return await sharedPrefs.setString(key, value);
    }else if(value is bool){
      return await sharedPrefs.setBool(key, value);
    }else if(value is double){
      return await sharedPrefs.setDouble(key, value);
    }else{
      return await sharedPrefs.setStringList(key, value);
    }
  }

  //todo: get data => read
  static Object? getData({required String key}){
    return sharedPrefs.get(key);
  }


  //todo: remove data
  static Future<bool> removeData({required String key})async{
    return await sharedPrefs.remove(key);
  }


}