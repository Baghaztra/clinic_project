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
  final TextEditingController _search = TextEditingController();

  Future<void> fetchHistory() async {
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
              hintText: "Nama dokter, spesialis, tanggal, atau status",
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
            child: appointments.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                .format(DateTime.parse(
                                    appointments[index]["appointment_date"]))
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "Dengan ${appointments[index]["doctor"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontSize: 13),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    "Spesialis ${appointments[index]["specialization"]}",
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
