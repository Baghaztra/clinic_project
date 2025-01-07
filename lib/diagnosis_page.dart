import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  List diagnosis = [];
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();

  Future<void> fetchHistory() async {
    setState(() {
      isLoading = true;
    });
    String urlAllProduct = "${AppConfig.backendUrl}/medical-records?search=${_search.text.toString()}";
    try {
      var response = await http.get(
        Uri.parse(urlAllProduct),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          diagnosis = jsonDecode(response.body);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil data dokter")),
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
    final record = diagnosis[index];
    Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => MedicalRecordDetail(medicalRecord: record,)));
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
                : diagnosis.isEmpty
                    ? const Center(
                        child: Text("Belum ada reakm medis tersimpan."),
                      )
                    : ListView.builder(
                        itemCount: diagnosis.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => onItemTap(index),
                            child: Card(
                                margin: const EdgeInsets.only(top: 10),
                                child: ListTile(
                                  title: Text(
                                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                        .format(DateTime.parse(
                                            diagnosis[index]["date"]))
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.justify,
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: AppConfig.role != 'doctor'
                                            ? Text(
                                                "Dengan ${diagnosis[index]["doctor"]} (${diagnosis[index]["specialization"]})",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              )
                                            : Text(
                                                "Dengan ${diagnosis[index]["patient"]}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Diagnosis: ${diagnosis[index]["diagnosis"]}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Pengobatan: ${diagnosis[index]["treatment"]}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 13),
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

class MedicalRecordDetail extends StatelessWidget {
  final dynamic medicalRecord;
  const MedicalRecordDetail({Key? key, required this.medicalRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.colorA,
        title: const Text(
          'Detail Rekam Medis',
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      medicalRecord['patient'],
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      medicalRecord['doctor'],
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      medicalRecord['specialization'],
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(
                          DateTime.parse(medicalRecord['date'])),
                      style: TextStyle(color: AppConfig.colorA, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Diagnosis:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    medicalRecord['diagnosis'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pengobatan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    medicalRecord['treatment'],
                    style: const TextStyle(fontSize: 16),
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