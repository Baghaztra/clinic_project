import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  List diagnosis = [];
  final TextEditingController _search = TextEditingController();

  Future<void> fetchHistory() async {
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
    }
  }

  @override
  void initState() {
    fetchHistory();
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
              hintText: "Masukkan kata kunci",
              suffixIcon: Align(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: IconButton(
                  onPressed: () {
                    fetchHistory();
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
            child: diagnosis.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: diagnosis.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              diagnosis[index]["date"],
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
                                  child: Text(
                                    "Dengan ${diagnosis[index]["doctor"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontSize: 13),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    "Spesialis ${diagnosis[index]["specialization"]}",
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
                                    "Treatment: ${diagnosis[index]["treatment"]}",
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
          )
        ]),
      ),
    );
  }
}
