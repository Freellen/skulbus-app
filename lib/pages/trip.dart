import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TripPage extends StatefulWidget {
  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRoute;
  String? _selectedBusStop;
  TextEditingController _textController = TextEditingController();
  List<dynamic> _routes = [];
  List<dynamic> _busStops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token == null) {
      showErrorDialog('No token found. Please log in again.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await Future.wait([fetchRoutes(token), fetchBusStops(token)]);
    } catch (error) {
      showErrorDialog('Failed to load data. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchRoutes(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/skulbus_api/api/route/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _routes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load routes');
    }
  }

  Future<void> fetchBusStops(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/skulbus_api/api/bus-stop/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _busStops = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load bus stops');
    }
  }

  Future<void> submitTrip() async {
    if (!_formKey.currentState!.validate()) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token == null) {
      showErrorDialog('No token found. Please log in again.');
      return;
    }

    final Map<String, dynamic> tripData = {
      'parent': '1',
      'firstname': 'JESSE',
      'middlename': 'HENRY',
      'lastname': 'KIRARI',
      'verification': 'frd-aman',
      'latitude': '-6.7794806',
      'longitude': '39.2712475',
      'status': 'end',
      'bus_stop': _selectedBusStop,
      'bus_stop_name': 'Mbuyuni Bus Stop'
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/skulbus_api/api/trip/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(tripData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip added successfully!')),
        );
      } else {
        throw Exception('Failed to add trip');
      }
    } catch (error) {
      showErrorDialog('Failed to submit trip. Please try again later.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skulbus Trip'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedRoute,
                decoration: InputDecoration(
                  labelText: 'SKULBUS TRIP',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select Route'),
                items: _routes.map<DropdownMenuItem<String>>((route) {
                  return DropdownMenuItem<String>(
                    value: route['id'].toString(),
                    child: Text(route['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRoute = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a route';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedBusStop,
                decoration: InputDecoration(
                  labelText: 'BUS STOP',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select Bus Stop'),
                items: _busStops.map<DropdownMenuItem<String>>((busStop) {
                  return DropdownMenuItem<String>(
                    value: busStop['id'].toString(),
                    child: Text(busStop['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedBusStop = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a bus stop';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter some text',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitTrip,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
