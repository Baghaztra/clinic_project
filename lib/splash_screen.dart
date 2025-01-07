import 'dart:async';

import 'package:clinic_project/onboarding_screen.dart';
import 'package:clinic_project/main_page.dart';
import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogin = false;

  Future<void> getAllData() async {
    try {
      AppConfig.token = AppConfig.getData("token").toString();
      AppConfig.username = AppConfig.getData("name").toString();
      AppConfig.role = AppConfig.getData("role").toString();
      if (AppConfig.token != "") {
        isLogin = true;
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    var isLogin = AppConfig.token != null;
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return isLogin ? const MainPage() : const OnboardingScreen();
          }
        )
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.colorD,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            'lib/assets/logo.png',
            scale: 0.75,
          ),
        ),
      ),
    );
  }
}
