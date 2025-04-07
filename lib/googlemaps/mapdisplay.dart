import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'locationretrieval.dart';


void main() {
  runApp(
    MaterialApp(
      home: MapScreen(),
    ),
  );
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(37.4221, -122.0841); // Default location
  bool _isLoading = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateCameraPosition();
  }

  Future<void> _updateCameraPosition() async {
    try {
      final position = await determinePosition();
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        mapController?.animateCamera(CameraUpdate.newLatLng(_center));
      }
    } catch (e) {
      print("Error updating position: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Just fetch position for initial view, but don't update controller here
    determinePosition().then((position) {
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
        });
      }
    }).catchError((e) {
      print("Error getting position: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}