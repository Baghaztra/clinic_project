import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List appointments = [];
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();

  Future<void> fetchHistory() async {
    setState(() {
      isLoading = true;
    });
    String urlAllProduct =
        "${AppConfig.backendUrl}/appointments?search=${_search.text.toString()}";
    try {
      var response = await http.get(
        Uri.parse(urlAllProduct),
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
          const SnackBar(content: Text("Gagal mengambil data riwayat")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onItemTap(int index) {
    final appointment = appointments[index];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AppointmentDetail(
                  appointment: appointment,
                )));
  }

  @override
  void initState() {
    fetchHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: "Cari sesuatu...",
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.amber.shade900),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
            ),
            onSubmitted: (value) {
              fetchHistory();
            },
          ),
        ),
        backgroundColor: AppConfig.colorA,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
        child: Column(children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : appointments.isEmpty
                    ? const Center(
                        child: Text("Belum ada riwayat berobat."),
                      )
                    : ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => onItemTap(index),
                            child: Card(
                                margin: const EdgeInsets.only(top: 10),
                                child: ListTile(
                                  title: Text(
                                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                        .format(DateTime.parse(appointments[index]
                                            ["appointment_date"]))
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 16,
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
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 5),
                                        child: AppConfig.role != 'doctor'
                                            ? Text(
                                                "Dengan ${appointments[index]["doctor"]} (${appointments[index]["specialization"]})",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              )
                                            : Text(
                                                "Dengan ${appointments[index]["patient"]}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Keluhan: ${appointments[index]["complaints"]}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Status ${appointments[index]["status"]}",
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
                                                          ? Colors.green.shade900
                                                          : Colors.black)),
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        },
                      ),
          )
        ]),
      ),
    );
  }
}

class AppointmentDetail extends StatelessWidget {
  final dynamic appointment;
  const AppointmentDetail({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.colorA,
        title: const Text(
          'Detail Janji Temu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Pasien: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      appointment['patient'],
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.transgender, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Jenis kelamin: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      appointment['gender'],
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Usia: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "${appointment['age']}",
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                    ),
                    const Text(
                      ' tahun',
                      style:
                          TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Telepon: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      appointment['phone_number'],
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Status: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      appointment['status'],
                      style: TextStyle(
                          color: appointment["status"] == 'canceled'
                              ? Colors.red
                              : (appointment["status"] == 'pending'
                                  ? Colors.amber.shade800
                                  : (appointment["status"] == "confirmed"
                                      ? Colors.green.shade900
                                      : Colors.black)),
                          fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Tanggal: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('dd MMMM yyyy', 'id_ID').format(
                            DateTime.parse(appointment['appointment_date'])),
                        style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_hospital, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Dokter: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        appointment['doctor'],
                        style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.medical_services, color: AppConfig.colorA),
                    const SizedBox(width: 8),
                    const Text(
                      'Spesialisasi: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        appointment['specialization'],
                        style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keluhan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    appointment['complaints'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
