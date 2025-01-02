import 'package:clinic_project/diagnosis_page.dart';
import 'package:clinic_project/doctors_page.dart';
import 'package:clinic_project/history_page.dart';
import 'package:clinic_project/home_page.dart';
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
      body: _pages[_currentIndex], // Tampilkan halaman berdasarkan indeks
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green.shade600,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update indeks saat menu ditekan
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: "Dokter",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: "Diagnosis",
          ),
        ],
      ),
    );
  }
}