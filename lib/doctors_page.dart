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

  @override
  void initState() {
    fetchDoctors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Column(children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              labelText: "Cari sesuatu",
              labelStyle: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              hintText: "Masukkan nama, spesialis, atau jadwal yang diinginkan",
              suffixIcon: Align(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: IconButton(
                  onPressed: () {
                    fetchDoctors();
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.amber,
                  ),
                ),
              ),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(width: 3, style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
          ),
          Expanded(
            child: doctors.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: const EdgeInsets.all(3),
                          child: ListTile(
                            leading: ClipOval(
                              child: Image.network(
                                '${AppConfig.backendUrl.replaceFirst('api', '')}${doctors[index]["profile"]}',
                                fit: BoxFit.fill,
                                height: 70,
                                width: 70,
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
                            title: Text(
                              doctors[index]["name"],
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
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Spesialis ${doctors[index]["specialization"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontSize: 13),
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
                                          fontSize: 13,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...doctors[index]["schedule"]
                                              .map<Widget>((schedule) {
                                            return Text(
                                              '$schedule, ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 13,
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
                          ));
                    },
                  ),
          )
        ]),
      ),
    );
  }
}