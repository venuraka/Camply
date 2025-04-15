import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp_model.dart';

class NearbyTab extends StatefulWidget {
  final CampSite campSite;

  const NearbyTab({
    Key? key,
    required this.campSite,
  }) : super(key: key);

  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab> {
  Map<String, dynamic> _nearbyPlaces = {};
  bool _isLoading = true;

  static const String googleApiKey = 'AIzaSyAkkFszINHsPx4OykoJfdIrIIbuqV4jJC4'; // Your API Key

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlacesFromFirestore();
  }

  Future<void> _fetchNearbyPlacesFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('campsites')
          .doc(widget.campSite.id)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        print('🔥 Firestore data: $data');

        final String locationString = data['location'];
        print('📍 Raw location string: $locationString');

        final parts = locationString.split(',');
        final double lat = double.parse(parts[0].split(':')[1].trim());
        final double lng = double.parse(parts[1].split(':')[1].trim());

        print('✅ Parsed lat/lng: $lat, $lng');

        final Map<String, dynamic> fetchedPlaces =
        await _fetchNearbyHospitalsFromGoogle(lat, lng);
        print('🏥 Nearby hospitals: $fetchedPlaces');

        setState(() {
          _nearbyPlaces = fetchedPlaces;
          _isLoading = false;
        });
      } else {
        throw Exception('Campsite not found');
      }
    } catch (e) {
      print('❌ Error fetching from Firestore or Google Places: $e');
      setState(() {
        _nearbyPlaces = CampSite.getDefaultNearbyPlaces();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchNearbyHospitalsFromGoogle(
      double lat, double lng) async {
    final Map<String, dynamic> hospitalsMap = {};

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=hospital&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      List results = data['results'];

      for (final place in results) {
        final String name = place['name'];
        final String address = place['vicinity'];
        final String placeId = place['place_id'];

        final phone = await _fetchPlacePhoneNumber(placeId);

        hospitalsMap[name] = {
          'address': address,
          'phone': phone ?? 'Phone not available',
        };
      }
    } else {
      print('Google Places API error: ${data['status']}');
    }

    return hospitalsMap;
  }

  Future<String?> _fetchPlacePhoneNumber(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    return data['result']?['formatted_phone_number'];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nearbyPlaces.length,
      itemBuilder: (context, index) {
        final placeName = _nearbyPlaces.keys.elementAt(index);
        final details = _nearbyPlaces[placeName];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _getPlaceIcon(placeName),
            title: Text(
              placeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Address: ${details['address']}\nPhone: ${details['phone']}',
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Add action if needed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('More'),
            ),
          ),
        );
      },
    );
  }

  Widget _getPlaceIcon(String place) {
    IconData icon = Icons.local_hospital;
    Color color = Colors.red;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }
}