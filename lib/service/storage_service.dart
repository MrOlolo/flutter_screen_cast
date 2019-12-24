import 'package:shared_preferences/shared_preferences.dart';

class StorageService {


 static Future<void> setResolution(String value) async  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

  }

  static Future<String> getResolution() async  {

  }
}