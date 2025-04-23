import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceServices {
  static late SharedPreferences sharedPreferences;
  static Future<void> init()async{
    sharedPreferences = await SharedPreferences.getInstance();
  }
  static Future<bool> saveToken(String key ,dynamic value){
    if(value is int){
      return sharedPreferences.setInt(key, value);
    }
    else if(value is double){
      return sharedPreferences.setDouble(key, value);
    }
    else if(value is String){
      return sharedPreferences.setString(key, value);
    }
    else{
      return sharedPreferences.setBool(key, value);
    }
  }
  static Object? getToken(String key){
    return sharedPreferences.get(key);
  }
  static Future<bool> deleteToken(String key)async{
    return await sharedPreferences.remove(key);
  }
}