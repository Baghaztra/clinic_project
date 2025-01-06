import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static Color colorA = const Color.fromARGB(255, 17, 139, 80);
  static Color colorB = const Color.fromARGB(255, 93, 185, 150);
  static Color colorC = const Color.fromARGB(255, 227, 240, 175);
  static Color colorD = const Color.fromARGB(255, 251, 246, 233);

  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: "http://10.0.2.2:8000/api",
  );

  static String? token;
  static String? username;
  static String? role;

  static const String _prefix = "AppConfig_";

  static Future<void> saveData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("$_prefix$key", value);
    } catch (e) {
      debugPrint("Error saving data for key $key: $e");
    }
  }

  static Future<String?> getData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("$_prefix$key");
    } catch (e) {
      debugPrint("Error fetching data for key $key: $e");
      return null;
    }
  }

  static Future<void> deleteData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("$_prefix$key");
    } catch (e) {
      debugPrint("Error deleting data for key $key: $e");
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint("Error clearing all data: $e");
    }
  }

  static Future<void> initialize() async {
    token = await getData("token");
    username = await getData("name");
    role = await getData("role");
  }
}

class Components {
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.colorA,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConfig.colorD),
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: AppConfig.colorD, 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.colorB,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // side: BorderSide(
        //   color: AppConfig.colorA,
        //   width: 2, 
        // ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConfig.colorD),
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: AppConfig.colorD, 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
    );
  }
}