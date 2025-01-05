import 'dart:convert';

import 'package:clinic_project/config.dart';
import 'package:clinic_project/main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CreateAppointment extends StatefulWidget {
  const CreateAppointment({super.key});

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  List _doctors = [];
  bool isLoading = false;

  DateTime? _selectedDate;
  String? _selectedDoctor;
  String? date;

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    String appointmentUrl = "${AppConfig.backendUrl}/appointments";
    try {
      var response = await http.post(
        Uri.parse(appointmentUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'doctor_id': _selectedDoctor,
          'complaints': _complaintController.text,
          'appointment_date': _selectedDate?.toIso8601String(),
          'status': 'pending',
        }),
      );

      var responseData = jsonDecode(response.body);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => const MainPage())
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create appointment: $e')),
      );
    }
  }

  Future<void> fetchDoctors() async {
    setState(() {
      isLoading = true;
    });

    String apiUrl = "${AppConfig.backendUrl}/doctors?search=$date";
    try {
      _doctors = [];
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _doctors = jsonDecode(response.body);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil data dokter")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    date = DateFormat('EEEE').format(DateTime.now());
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    fetchDoctors();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buat Janji Temu",
          style: TextStyle(color: Colors.white),
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
                TextFormField(
                  controller: _complaintController,
                  decoration: const InputDecoration(
                    labelText: 'Keluhan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Keluhan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Tanggal',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                        date = DateFormat('EEEE').format(pickedDate);
                        _dateController.text = DateFormat('dd/MM/yyyy')
                            .format(pickedDate);
                      });
                      fetchDoctors();
                    }
                  },
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Tanggal harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Pilih Dokter',
                          border: OutlineInputBorder(),
                        ),
                        items: _doctors.map((doctor) {
                          return DropdownMenuItem<String>(
                            value: doctor['id'].toString(),
                            child: Text("${doctor['name']} (${doctor['specialization']})"),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDoctor = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Dokter harus dipilih';
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitAppointment,
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
