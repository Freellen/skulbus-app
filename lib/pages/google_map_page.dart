import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_app/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();

  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.3861, -122.0839);

  LatLng? currentPosition;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
    final coordinates = await fetchPolylinePoints();
    generatePolyLineFromPoints(coordinates);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: googlePlex,
                    zoom: 13,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: currentPosition!,
                    ),
                    const Marker(
                      markerId: MarkerId('sourceLocation'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: googlePlex,
                    ),
                    const Marker(
                      markerId: MarkerId('destinationLocation'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: mountainView,
                    )
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LocationCard(
                      address: '8 Chaniza St, Dar es Salaam, Tanzania',
                      lastUpdated: 'Now',
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
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
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
      googleMapsApiKey,
      PointLatLng(googlePlex.latitude, googlePlex.longitude),
      PointLatLng(mountainView.latitude, mountainView.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
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