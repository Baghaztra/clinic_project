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

    setState(() => isLoading = true);
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
          'complaints': _complaintController.text.trim(),
          'appointment_date': _selectedDate?.toIso8601String(),
          'status': 'pending',
        }),
      );

      var responseData = jsonDecode(response.body);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const MainPage()));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message']),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchDoctors() async {
    setState(() => isLoading = true);

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
          const SnackBar(
            content: Text("Gagal mengambil data dokter"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
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
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buat Janji Temu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConfig.colorA,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Kunjungan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon:
                            Icon(Icons.calendar_today, color: AppConfig.colorA),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppConfig.colorA,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                            date = DateFormat('EEEE').format(pickedDate);
                            _dateController.text =
                                DateFormat('dd/MM/yyyy').format(pickedDate);
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
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _complaintController,
                      decoration: InputDecoration(
                        labelText: 'Keluhan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Keluhan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppConfig.colorA),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Pilih Dokter',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _doctors.map((doctor) {
                              return DropdownMenuItem<String>(
                                value: doctor['id'].toString(),
                                child: Text(
                                  "${doctor['name']} (${doctor['specialization']})",
                                  style: const TextStyle(fontSize: 15),
                                ),
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
                  ],
                ),
                const SizedBox(height: 32),
                Components.primaryButton(
                    text: "Buat janji temu",
                    onPressed: _submitAppointment,
                    isLoading: isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
