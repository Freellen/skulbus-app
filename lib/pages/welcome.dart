import 'package:flutter/material.dart';
import 'package:google_map_app/pages/driver_login.dart';
import 'login.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Skulbus Application'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.ice_skating),
              label: Text("Driver"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverLogin()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20.0),
                fixedSize: Size(300, 80),
                textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 15,
                shadowColor: Colors.teal,
                side: BorderSide(
                  color: Colors.black12,
                  width: 2,
                ),
                shape: StadiumBorder(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.account_circle_outlined),
              label: Text("Parent"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20.0),
                fixedSize: Size(300, 80),
                textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 15,
                shadowColor: Colors.teal,
                side: BorderSide(
                  color: Colors.black12,
                  width: 2,
                ),
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}