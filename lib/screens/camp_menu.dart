import 'package:camply/models/camp_model.dart';
import 'package:camply/pages/camp_details_display.dart';
import 'package:flutter/material.dart';

class CampMenu extends StatefulWidget {
  const CampMenu({Key? key}) : super(key: key);

  @override
  State<CampMenu> createState() => _CampMenuState();
}

class _CampMenuState extends State<CampMenu> {
  final List<CampSite> campSites = [
    CampSite(
      name: "Yosmite Basecamp",
      location: "East California",
      details:
          "Yosemite National Park, a UNESCO World Heritage Site, is a stunning area in California's Sierra Nevada, known for its granite cliffs, waterfalls, giant sequoia groves, and diverse ecosystems, attracting millions of visitors annually.",
      amenities: ["Washroom", "Electricity"],
      nearbyPlaces: [
        'Hospital',
        'Police Station',
        'Fire Department',
        'Pharmacy',
        'Restaurant',
      ],
    ),
    CampSite(
      name: "Yala National Park",
      location: " Southern Province and Uva Province, Sri Lanka",
      details:
          "Yosemite National Park, a UNESCO World Heritage Site, is a stunning area in California's Sierra Nevada, known for its granite cliffs, waterfalls, giant sequoia groves, and diverse ecosystems, attracting millions of visitors annually.",
      amenities: ["Washroom", "Electricity"],
      nearbyPlaces: [
        'Hospital',
        'Police Station',
        'Fire Department',
        'Pharmacy',
        'Restaurant',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camping App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final newCampSite = await Navigator.pushNamed(
                  context,
                  '/createCampSite',
                );
                if (newCampSite != null && newCampSite is CampSite) {
                  setState(() {
                    campSites.add(newCampSite);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Create Camp Site',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            if (campSites.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: campSites.length,
                  itemBuilder: (context, index) {
                    final camp = campSites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(camp.name),
                        subtitle: Text(camp.location),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CampDetailsDisplay(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            if (campSites.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No camp sites created yet. Tap the button above to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
