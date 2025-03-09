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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            campSite.details.isNotEmpty
                ? campSite.details
                : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Property amenities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: campSite.amenities.map((amenity) {
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
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
