import 'package:flutter/material.dart';
import 'package:google_map_app/pages/trip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'google_map_page.dart';
import 'print_shared_preferences.dart'; // Add this import

class DriverLogin extends StatefulWidget {
  const DriverLogin({Key? key}) : super(key: key);

  @override
  State<DriverLogin> createState() => _LoginState();
}

class _LoginState extends State<DriverLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/skulbus_api/api/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final token = responseBody['token']; // Ensure this matches your API response

        // Print the token to the console
        // print('Token: $token');

        // Store the token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        // Print SharedPreferences content for debugging
        await printSharedPreferencesContent();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripPage()),
        );
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Driver Login',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter your phone number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter phone number" : null;
                  },
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? "Please enter password" : null;
                  },
                ),
                SizedBox(height: 30),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : MaterialButton(
                  minWidth: double.infinity,
                  onPressed: _login,
                  child: Text('Login'),
                  color: Colors.teal,
                  textColor: Colors.white,
                  shape: StadiumBorder(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
