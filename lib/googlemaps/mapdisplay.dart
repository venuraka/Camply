import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
    _fetchLocationFromFirestore();
  }

  Future<void> _fetchLocationFromFirestore() async {
    try {
      // Replace with your collection and document path
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('campsites')
          .doc('id')
          .get();

      if (doc.exists) {
        final locationString = doc['location'];
        // Use RegExp to extract the values
        final regex = RegExp(r'Latitude:\s*(-?\d+\.\d+),\s*Longitude:\s*(-?\d+\.\d+)');
        final match = regex.firstMatch(locationString);

        if (match != null) {
          final latitude = double.parse(match.group(1)!);
          final longitude = double.parse(match.group(2)!);

          if (mounted) {
            setState(() {
              _center = LatLng(latitude, longitude);
              _isLoading = false;
            });

            mapController?.animateCamera(CameraUpdate.newLatLng(_center));
          }
        } else {
          print('Could not parse location string');
          setState(() => _isLoading = false);
        }
      } else {
        print('Document not found');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching location: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
    void initState() {
      super.initState();
      _fetchLocationFromFirestore();
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