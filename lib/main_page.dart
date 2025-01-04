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
      floatingActionButton: FloatingActionButton(
        onPressed: (() {}),
        splashColor: Colors.green.shade500,
        backgroundColor: Colors.green.shade700,
        child: const Icon(
          CupertinoIcons.add,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green.shade600,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.rectangle_stack_person_crop_fill),
            label: "Dokter",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.timer_fill),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lab_flask_solid),
            label: "Diagnosis",
          ),

        ],
      ),
    );
  }
}