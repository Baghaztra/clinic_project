import 'package:clinic_project/config.dart';
import 'package:clinic_project/create_appointment.dart';
import 'package:clinic_project/diagnosis_page.dart';
import 'package:clinic_project/doctors_page.dart';
import 'package:clinic_project/history_page.dart';
import 'package:clinic_project/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const DoctorsPage(),
    const HistoryPage(),
    const DiagnosisPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: AppConfig.role == 'patient' ? FloatingActionButton(
        onPressed: (() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context)=>const CreateAppointment())
          );
        }),
        splashColor: AppConfig.colorC,
        backgroundColor: AppConfig.colorA,
        child: Icon(
          CupertinoIcons.add,
          color: AppConfig.colorD,
        ),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppConfig.colorA,
        unselectedItemColor: AppConfig.colorB,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.house_fill),
            label: "Home",
            backgroundColor: AppConfig.colorD,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.rectangle_stack_person_crop_fill),
            label: "Dokter",
            backgroundColor: AppConfig.colorD,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.timer_fill),
            label: "Riwayat",
            backgroundColor: AppConfig.colorD,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.lab_flask_solid),
            label: "Diagnosis",
            backgroundColor: AppConfig.colorD,
          ),
        ],
      ),
    );
  }
}