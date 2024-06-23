import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'print_shared_preferences.dart'; // Add this import

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();
  LatLng? googlePlex;
  LatLng? mountainView;
  LatLng? currentPosition;
  Map<PolylineId, Polyline> polylines = {};
  String? authToken; // Variable to hold the token

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeMap();
      await printSharedPreferencesContent(); // Print SharedPreferences content
    });
  }

  Future<void> initializeMap() async {
    final token = await _retrieveToken();
    if (token != null) {
      setState(() {
        authToken = token; // Save the token to display in the UI
      });
      await fetchCoordinates(token);
      if (googlePlex != null && mountainView != null) {
        await fetchLocationUpdates();
        final coordinates = await fetchPolylinePoints();
        generatePolyLineFromPoints(coordinates);
      }
    } else {
      debugPrint('Authorization token not found');
    }
  }

  Future<String?> _retrieveToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> fetchCoordinates(String token) async {
    final url = 'http://10.0.2.2:8000/skulbus_api/api/user/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            googlePlex = LatLng(
              double.parse(data[0]['start_latitude']),
              double.parse(data[0]['start_longitude']),
            );
            mountainView = LatLng(
              double.parse(data[0]['end_latitude']),
              double.parse(data[0]['end_longitude']),
            );
          });
        } else {
          debugPrint('No data found');
        }
      } else {
        debugPrint('Failed to load coordinates');
      }
    } catch (e) {
      debugPrint('Error fetching coordinates: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Google Map'),
    ),
    body: Stack(
      children: [
        googlePlex == null || mountainView == null || currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
          initialCameraPosition: CameraPosition(
            target: googlePlex!,
            zoom: 13,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('currentLocation'),
              icon: BitmapDescriptor.defaultMarker,
              position: currentPosition!,
            ),
            Marker(
              markerId: const MarkerId('sourceLocation'),
              icon: BitmapDescriptor.defaultMarker,
              position: googlePlex!,
            ),
            Marker(
              markerId: const MarkerId('destinationLocation'),
              icon: BitmapDescriptor.defaultMarker,
              position: mountainView!,
            ),
          },
          polylines: Set<Polyline>.of(polylines.values),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LocationCard(
                  address: '8 Chaniza St, Dar es Salaam, Tanzania',
                  lastUpdated: 'Now',
                ),
                if (authToken != null) ...[
                  SizedBox(height: 10),
                  Text('Token: $authToken', style: TextStyle(color: Colors.black)),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDCh7S3cE5ywcFPwfJdOC_R51tLa9a2KY8",
      PointLatLng(googlePlex!.latitude, googlePlex!.longitude),
      PointLatLng(mountainView!.latitude, mountainView!.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }
}

class LocationCard extends StatelessWidget {
  final String address;
  final String lastUpdated;

  const LocationCard({
    Key? key,
    required this.address,
    required this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16.0),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android, color: Colors.blue, size: 30),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the Bus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Timestamp: $lastUpdated',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exit the Bus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Timestamp: $lastUpdated',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(height: 4),
                  Text('Refresh', style: TextStyle(color: Colors.white)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.punch_clock, color: Colors.white),
                  SizedBox(height: 4),
                  Text('History', style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
