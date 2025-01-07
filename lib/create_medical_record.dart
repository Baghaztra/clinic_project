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
  bool _isLoading = false;
  Map<String, dynamic>? appointment;

  Future<void> fetchData() async {
    setState(() => _isLoading = true);
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
        const SnackBar(
          content: Text('Failed to fetch appointment data'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> submitMedicalRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String medicalRecordUrl = "${AppConfig.backendUrl}/medical-records";
    
    try {
      var response = await http.post(
        Uri.parse(medicalRecordUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'patient_id': appointment!['patient_id'],
          'diagnosis': _diagnosisController.text.trim(),
          'treatment': _treatmentController.text.trim(),
          'date': DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create medical record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.colorA,
        title: Text(
          appointment == null ? "Loading..." : appointment!['patient'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (appointment != null) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                  .format(DateTime.parse(appointment!["appointment_date"]))
                                  .toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Data Pasien:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Nama: ${appointment!['patient']}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                "Umur: ${appointment!['age']}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                "Jenis Kelamin: ${appointment!['gender']}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                "Telepon: ${appointment!['phone_number']}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Keluhan Pasien:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appointment!['complaints'],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    TextFormField(
                      controller: _diagnosisController,
                      decoration: InputDecoration(
                        labelText: 'Diagnosis',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Diagnosis tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _treatmentController,
                      decoration: InputDecoration(
                        labelText: 'Treatment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Treatment tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Components.primaryButton(
                      text: "Simpan", 
                      onPressed: submitMedicalRecord,
                      isLoading: _isLoading)
                  ],
                ),
              ),
            ),
          ),
    );
  }
}