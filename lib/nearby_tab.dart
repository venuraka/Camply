import 'package:flutter/material.dart';
import 'camp_model.dart';

class NearbyTab extends StatelessWidget {
  final CampSite campSite;

  const NearbyTab({
    Key? key,
    required this.campSite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nearbyPlaces = campSite.nearbyPlaces.isEmpty
        ? CampSite.getDefaultNearbyPlaces()
        : campSite.nearbyPlaces;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nearbyPlaces.length,
      itemBuilder: (context, index) {
        final place = nearbyPlaces.keys.elementAt(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _getPlaceIcon(place),
            title: Text(
              place,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () {},
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
    IconData icon;
    Color color;

    switch (place.toLowerCase()) {
      case 'hospital':
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'fire department':
        icon = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case 'police':
        icon = Icons.local_police;
        color = Colors.blue;
        break;
      case 'pharmacy':
        icon = Icons.local_pharmacy;
        color = Colors.green;
        break;
      case 'restaurant':
        icon = Icons.restaurant;
        color = Colors.amber;
        break;
      default:
        icon = Icons.place;
        color = Colors.grey;
    }

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
