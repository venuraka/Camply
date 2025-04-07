import 'package:flutter/material.dart';
import 'camp_model.dart';

class DetailTab extends StatelessWidget {
  final CampSite campSite;

  const DetailTab({
    Key? key,
    required this.campSite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug: Print amenities data to check if it's coming through correctly
    print(campSite.amenities);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Camp Description ---
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            campSite.details?.isNotEmpty == true
                ? campSite.details!
                : 'No description available for this campsite.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // --- Amenities Section ---
          const Text(
            'Property Amenities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Check if amenities are available and display
          if (campSite.amenities != null && campSite.amenities!.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: campSite.amenities!.map((amenity) {
                IconData icon;
                Color color;

                switch (amenity.toLowerCase()) {
                  case 'washroom':
                    icon = Icons.wc;
                    color = Colors.teal;
                    break;
                  case 'electricity':
                    icon = Icons.electrical_services;
                    color = Colors.amber;
                    break;
                  case 'showers':
                    icon = Icons.shower;
                    color = Colors.blue;
                    break;
                  case 'fire pits':
                    icon = Icons.local_fire_department;
                    color = Colors.red;
                    break;
                  case 'bbq grills':
                    icon = Icons.outdoor_grill;
                    color = Colors.orange;
                    break;
                  case 'parking':
                    icon = Icons.local_parking;
                    color = Colors.indigo;
                    break;
                  case 'tents':
                    icon = Icons.night_shelter;
                    color = Colors.green;
                    break;
                  default:
                    icon = Icons.check_circle;
                    color = Colors.grey;
                }

                return Chip(
                  avatar: Icon(icon, color: color, size: 18),
                  label: Text(amenity),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            )
          else
            const Text(
              'No amenities listed for this campsite.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}