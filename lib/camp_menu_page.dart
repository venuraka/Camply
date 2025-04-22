import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp_detail_page.dart';
import 'camp_model.dart';

class CampMenuPage extends StatelessWidget {
  const CampMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camp Menu')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('campsites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No campsites available.'));
          }

          final campsites =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return CampSite(
                  name: data['name'] ?? '',
                  location: data['location'] ?? '',
                  details: data['details'] ?? '',
                  amenities: List<String>.from(data['amenities'] ?? []),
                  nearbyPlaces: [],
                  imageUrl: data['imageUrl'],
                  rating: 0.0,
                );
              }).toList();

          return ListView.builder(
            itemCount: campsites.length,
            itemBuilder: (context, index) {
              final camp = campsites[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading:
                      camp.imageUrl != null
                          ? Image.network(
                            camp.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image, size: 50),
                  title: Text(camp.name),
                  subtitle: Text(camp.location),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampDetailPage(campSite: camp),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
