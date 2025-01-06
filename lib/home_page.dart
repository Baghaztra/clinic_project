import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:clinic_project/create_medical_record.dart';
import 'package:clinic_project/login_page.dart';
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
  bool isLoading = false;

  Future<void> getAppointment() async {
    setState(() {
      isLoading = true;
    });
    String appointmentUrl = "${AppConfig.backendUrl}/appointment/latest";
    try {
      var response = await http.get(
        Uri.parse(appointmentUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          appointments = jsonDecode(response.body);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching data")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> action(String action, String id) async {
    String apiUrl = "${AppConfig.backendUrl}/appointments/$id";
    try {
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"status": action}),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment $action")),
        );
        getAppointment();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error")),
      );
    }
  }

  Future<void> logout() async {
    const String apiUrl = "${AppConfig.backendUrl}/logout";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage()));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erroe, status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching logout")),
      );
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
      appBar: AppBar(
        backgroundColor: AppConfig.colorD,
        title: Row(
          children: [
            const Text(
              "Hi ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              "${AppConfig.username}",
              style: TextStyle(
                fontSize: 16,
                color: AppConfig.colorA,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: isLoading
                ? null
                : () async {
                    await logout();
                  },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.logout,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppConfig.colorD,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                                color: AppConfig.colorA,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
                child: Text(
                  "Janji temu",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: appointments.isEmpty
                      ? const Center(
                          child: Text(
                            "No appointments available",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            return Card(
                                color: Colors.green.shade50,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(
                                    AppConfig.role == 'doctor'
                                        ? "${appointments[index]["patient"]}"
                                        : "${appointments[index]["doctor"]}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.justify,
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      AppConfig.role != 'doctor'
                                      ? Text(
                                          "Doketer ${appointments[index]["specialization"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey.shade900,
                                              fontSize: 13),
                                      ) : const SizedBox(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                            "Keluhan: ${appointments[index]["complaints"]}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                                fontSize: 13),
                                          ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          appointments[index]["status"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: appointments[index]
                                                          ["status"] ==
                                                      'canceled'
                                                  ? Colors.red
                                                  : (appointments[index]
                                                              ["status"] ==
                                                          'pending'
                                                      ? Colors.amber.shade800
                                                      : (appointments[index]
                                                                  ["status"] ==
                                                              "confirmed"
                                                          ? Colors
                                                              .green.shade900
                                                          : Colors.black)),
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          DateFormat(
                                                  'EEEE, dd MMMM yyyy', 'id_ID')
                                              .format(DateTime.parse(
                                                  appointments[index]
                                                      ["appointment_date"]))
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: AppConfig.role == 'doctor' &&
                                          appointments[index]["status"] !=
                                              'completed'
                                      ? appointments[index]["status"] ==
                                              'confirmed'
                                          ? Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                      return CreateMedicalRecords(
                                                          appointments[index]
                                                              ["id"]);
                                                    }));
                                                  },
                                                  child: const Icon(
                                                    Icons.file_present_rounded,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                const Spacer(),
                                                InkWell(
                                                    onTap: () => action(
                                                        'completed',
                                                        appointments[index]
                                                                ["id"]
                                                            .toString()),
                                                    child: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                    )),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                InkWell(
                                                  onTap: () => action(
                                                      'confirmed',
                                                      appointments[index]["id"]
                                                          .toString()),
                                                  child: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                const Spacer(),
                                                InkWell(
                                                    onTap: () => action(
                                                        'canceled',
                                                        appointments[index]
                                                                ["id"]
                                                            .toString()),
                                                    child: const Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.red,
                                                    )),
                                              ],
                                            )
                                      : const Text(''),
                                ));
                          },
                        ),
                ),
        ]),
      ),
    );
  }
}
