import 'package:flutter/material.dart';

class AppConfig {
  static Color colorA = const Color.fromARGB(255, 17, 139, 80);
  static Color colorB = const Color.fromARGB(255, 93, 185, 150);
  static Color colorC = const Color.fromARGB(255, 227, 240, 175);
  static Color colorD = const Color.fromARGB(255, 251, 246, 233);
  
  static const String backendUrl = "http://10.0.2.2:8000/api";
  static String? token;
  static String? username;
  static String? role;

  static void saveToken(String newToken) {
    token = newToken;
  }

  static void removeToken() {
    token = null;
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