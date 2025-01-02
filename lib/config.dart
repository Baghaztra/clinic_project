import 'package:flutter/material.dart';

class AppConfig {
  static Color primaryColor = Colors.green.shade600;
  static Color secondaryColor = Colors.green.shade200;
  
  static const String backendUrl = "http://10.0.2.2:8000/api";
  static String? token;

  static void saveToken(String newToken) {
    token = newToken;
  }

  static void removeToken() {
    token = null;
  }
}
