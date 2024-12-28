import 'dart:async';
import 'package:clinic_project/main_page.dart';

import 'config.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>const MainPage()))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.primaryColor,
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
