import 'package:clinic_project/config.dart';
import 'package:clinic_project/main_page.dart';
import 'package:clinic_project/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    String email = _email.text.trim();
    String password = _password.text.trim();
    String apiUrl = "${AppConfig.backendUrl}/login";

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password tidak boleh kosong")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        AppConfig.saveToken(data['access_token']);
        AppConfig.username = data['name'];
        AppConfig.role = data['role'];

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login berhasil!")),
        );

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        final error = json.decode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login gagal: ${error['message']}")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is http.Response) {
        final error = json.decode(e.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? "Terjadi kesalahan pada server.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: AppConfig.colorA,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Login",
            style: TextStyle(
              color: AppConfig.colorA,
              fontWeight: FontWeight.bold,
              fontSize: 38
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 300,
              child: ListView(
                children: [
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      filled: true, 
                      fillColor: AppConfig.colorD,
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Email",
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(
                      filled: true, 
                      fillColor: AppConfig.colorD,
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  Components.primaryButton(
                    text: "Login",
                    onPressed:_login,
                    isLoading: _isLoading
                  ),
                  const SizedBox(height: 10),
                  Components.secondaryButton(
                    text: "Register", 
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterPage())
                      );
                    },
                    isLoading: _isLoading
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

