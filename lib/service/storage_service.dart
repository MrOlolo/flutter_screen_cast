import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final String _resKey = 'resolution';
  static final String _ipKey = 'ip';
  static final String _tokenKey = 'token';

  static Future<void> setResolution(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_resKey, value);
  }

  static Future<String> getResolution() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_resKey);
  }

  static Future<void> setIp(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_ipKey, value);
  }

  static Future<String> getIp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey);
  }

  static Future<void> setToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, value);
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
