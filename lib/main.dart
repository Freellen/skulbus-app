import 'package:flutter/material.dart';
import 'package:google_map_app/pages/welcome.dart';

import 'pages/google_map_page.dart';
import 'pages/login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Skulbus App',
        theme: ThemeData(primarySwatch: Colors.blue),
        // home: const GoogleMapPage(),
        // home: const Login(),
        home: const Welcome(),
      );
}
