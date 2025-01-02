import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List appointments = [];

  Future<void> getAppointment() async {
    String appointmentUrl = "${AppConfig.backendUrl}/appointments";
    try {
      var response = await http.get(
        Uri.parse(appointmentUrl),
        headers: {
          'Authorization':
              'Bearer ${AppConfig.token}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          appointments = jsonDecode(response.body);
        });
      } else {
        if (kDebugMode) {
          print("Failed to laod products, error code: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    getAppointment();
    if (kDebugMode) {
      print(jsonEncode(appointments));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String dayName = DateFormat('EEEE', 'id_ID').format(now);
    final String date = DateFormat('d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: <Widget> [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: <Widget>[
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
              ]),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(children: [
                Text(
                  dayName,
                  style: TextStyle(
                      color: AppConfig.primaryColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: AppConfig.secondaryColor,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ]),
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Janji temu",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 250,
                child: appointments.isEmpty
                    ? const Center(
                        child: Text(
                          "No appointments available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return Card(
                              color: Colors.green.shade50,
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                title: Text(
                                  "${appointments[index]["doctor"]}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.justify,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "${appointments[index][""]}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        appointments[index]["appointment_date"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
              ),
            )
          ]
        ),
      ),
    );
  }
}
