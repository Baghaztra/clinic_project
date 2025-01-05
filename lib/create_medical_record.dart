import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CreateMedicalRecords extends StatefulWidget {
  final int appointmentId;

  const CreateMedicalRecords(this.appointmentId, {super.key});

  @override
  State<CreateMedicalRecords> createState() => _CreateMedicalRecordsState();
}

class _CreateMedicalRecordsState extends State<CreateMedicalRecords> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  Map<String, dynamic>? appointment;

  Future<void> fetchData() async {
    String apiUrl = "${AppConfig.backendUrl}/appointments/${widget.appointmentId}";
    
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          appointment = jsonDecode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch appointment data')),
      );
    }
  }

  Future<void> submitMedicalRecord() async {
    if (!_formKey.currentState!.validate()) return;

    String medicalRecordUrl = "${AppConfig.backendUrl}/medical-records";
    try {
      var response = await http.post(
        Uri.parse(medicalRecordUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'patient_id':appointment!['patient_id'],
          'diagnosis':_diagnosisController.text.toString(),
          'treatment':_treatmentController.text.toString(),
          'date':DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      var responseData = jsonDecode(response.body);


      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create medical record: $e')),
      );
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appointment == null
            ? "Memuat data..."
            : "${appointment!['patient']}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                appointment == null
                  ? const Center(
                    child: CircularProgressIndicator(),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                        .format(DateTime.parse(
                            appointment!["appointment_date"]))
                        .toString(),
                    ),
                    const Text(
                      "Keluhan:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "${appointment!['complaints']}"
                    ),
                    ]
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnosis',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Diagnosis tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _treatmentController,
                  decoration: const InputDecoration(
                    labelText: 'Treatment',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Treatment tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: submitMedicalRecord,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
