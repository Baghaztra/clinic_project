import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
   Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String dayName = DateFormat('EEEE', 'id_ID').format(now);
    final String date = DateFormat('d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  const Text(
                    "Hi ",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),                    
                  Text(
                    "User3198!",
                    style: TextStyle(
                      color: AppConfig.primaryColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ]
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: AppConfig.primaryColor,
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppConfig.secondaryColor,
                      ),
                    ),
                  ]
                ),
              )
          ]
        ),
      ),
    );
  }
}