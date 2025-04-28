import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp_model.dart';

class NearbyTab extends StatefulWidget {
  final CampSite campSite;

  const NearbyTab({Key? key, required this.campSite}) : super(key: key);

  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab> {
  final List<String> _categories = [
    'Hospitals',
    'Supermarkets',
    'Restaurants',
    'Banks',
    'Gas Stations',
    'Police Stations',
  ];

  Map<String, Map<String, dynamic>> _categorizedPlaces = {};
  bool _isLoading = true;

  static const String googleApiKey = 'AIzaSyBoB5AqC_QbDkLEw0KXBO-0LxFFb5-Kslw';

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
        final String locationString = data['location'];
        final parts = locationString.split(',');
        final double lat = double.parse(parts[0].split(':')[1].trim());
        final double lng = double.parse(parts[1].split(':')[1].trim());

        for (String category in _categories) {
          String type = _getPlaceTypeFromCategory(category);
          final places = await _fetchNearbyPlaces(lat, lng, type);
          _categorizedPlaces[category] = places;
        }

        setState(() => _isLoading = false);
      } else {
        throw Exception('Campsite not found');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getPlaceTypeFromCategory(String category) {
    switch (category) {
      case 'Hospitals':
        return 'hospital';
      case 'Supermarkets':
        return 'supermarket';
      case 'Restaurants':
        return 'restaurant';
      case 'Banks':
        return 'bank';
      case 'Gas Stations':
        return 'gas_station';
      case 'Police Stations':
        return 'police';
      default:
        return '';
    }
  }

  Future<Map<String, dynamic>> _fetchNearbyPlaces(double lat, double lng, String type) async {
    final Map<String, dynamic> placesMap = {};
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=$type&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      for (final place in data['results']) {
        final String name = place['name'];
        final String address = place['vicinity'];
        final String placeId = place['place_id'];
        final double placeLat = place['geometry']['location']['lat'];
        final double placeLng = place['geometry']['location']['lng'];
        final phone = await _fetchPlacePhoneNumber(placeId);

        placesMap[name] = {
          'address': address,
          'phone': phone ?? 'Phone not available',
          'lat': placeLat,
          'lng': placeLng,
        };
      }
    }

    return placesMap;
  }

  Future<String?> _fetchPlacePhoneNumber(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    return data['result']?['formatted_phone_number'];
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: _categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _categories.map((category) {
                final places = _categorizedPlaces[category] ?? {};
                if (places.isEmpty) {
                  return const Center(child: Text("No data available"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final name = places.keys.elementAt(index);
                    final details = places[name];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: _getPlaceIcon(category),
                        title: Text(
                          name,
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
                            _openInGoogleMaps(details['lat'], details['lng']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Direction'),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPlaceIcon(String category) {
    IconData icon;
    Color color;

    switch (category) {
      case 'Hospitals':
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'Supermarkets':
        icon = Icons.shopping_cart;
        color = Colors.orange;
        break;
      case 'Restaurants':
        icon = Icons.restaurant;
        color = Colors.purple;
        break;
      case 'Banks':
        icon = Icons.account_balance;
        color = Colors.blue;
        break;
      case 'Gas Stations':
        icon = Icons.local_gas_station;
        color = Colors.green;
        break;
      case 'Police Stations':
        icon = Icons.local_police;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.location_on;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}