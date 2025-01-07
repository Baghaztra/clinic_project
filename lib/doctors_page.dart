import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List doctors = [];
  final TextEditingController _search = TextEditingController();

  Future<void> fetchDoctors() async {
    String urlAllProduct =
        "${AppConfig.backendUrl}/doctors?search=${_search.text.toString()}";
    try {
      var response = await http.get(
        Uri.parse(urlAllProduct),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          doctors = jsonDecode(response.body);
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
    }
  }

  void onItemTap(int index) {
    final doctor = doctors[index];
    Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => DoctorDetail(doctor: doctor)));
  }

  @override
  void initState() {
    fetchDoctors();
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
              fetchDoctors();
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
            child: doctors.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => onItemTap(index),
                        child: Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: ClipOval(
                                child: Hero(
                                  tag: 'doctor-image-${doctors[index]["id"]}',
                                  child: Image.network(
                                    '${AppConfig.backendUrl.replaceFirst('api', '')}${doctors[index]["profile"]}',
                                    fit: BoxFit.fill,
                                    height: 50,
                                    width: 50,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes !=
                                                    null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    (loadingProgress.expectedTotalBytes ??
                                                        1)
                                                : null);
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Text(
                                        "Error",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.justify,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              title: Text(
                                doctors[index]["name"],
                                style: TextStyle(
                                    fontSize: 20,
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
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Dokter ${doctors[index]["specialization"]}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jadwal:',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 3,
                                          runSpacing: 4.0,
                                          children: [
                                            ...doctors[index]["schedule"].map<Widget>((schedule) {
                                              return Text(
                                                '$schedule, ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),

                                      ],
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

class DoctorDetail extends StatelessWidget {
  final dynamic doctor;
  const DoctorDetail({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.colorA,
        title: Text(
          doctor['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Hero(
                      tag: 'doctor-image-${doctor["id"]}',
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "${AppConfig.backendUrl.replaceFirst('api', '')}${doctor["profile"]}",
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppConfig.colorA),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    doctor['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConfig.colorA.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Dokter ${doctor['specialization']}",
                      style: TextStyle(
                        color: AppConfig.colorA,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    "Jadwal Praktik",
                    Icon(Icons.calendar_today, color: AppConfig.colorA),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...doctor["schedule_detail"].map<Widget>((schedule) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 20, color: AppConfig.colorA),
                                const SizedBox(width: 8),
                                Text(
                                  schedule,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    "Statistik",
                    Icon(Icons.bar_chart, color: AppConfig.colorA),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            "Janji Temu",
                            doctor['appointments'].toString(),
                            Icons.calendar_month,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            "Rekam Medis",
                            doctor['medical_records'].toString(),
                            Icons.medical_information,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, Icon icon, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppConfig.colorA),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}