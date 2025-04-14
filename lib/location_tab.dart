import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp_model.dart';

class LocationTab extends StatefulWidget {
  final CampSite campSite;

  const LocationTab({
    Key? key,
    required this.campSite,
  }) : super(key: key);

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(37.4221, -122.0841); // Default location
  bool _isLoading = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fetchLocationFromFirestore();
  }

  Future<void> _fetchLocationFromFirestore() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('campsites')
          .doc(widget.campSite.id)
          .get();

      if (doc.exists) {
        final locationString = doc['location'];
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map section
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
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
          ),
          const SizedBox(height: 16),

          // Location details
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.campSite.location,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Coordinates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_center.latitude.toStringAsFixed(5)}° N, ${_center.longitude.toStringAsFixed(5)}° E',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add navigation logic here if needed
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}