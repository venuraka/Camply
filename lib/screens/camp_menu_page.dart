import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/camp_model.dart';
import 'camp_detail_page.dart';
import 'create_camp_page.dart';

class CampMenuPage extends StatefulWidget {
  const CampMenuPage({Key? key}) : super(key: key);

  @override
  State<CampMenuPage> createState() => _CampMenuPageState();
}

class _CampMenuPageState extends State<CampMenuPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<CampSite> _allCampsites = [];
  List<CampSite> _filteredCampsites = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String query) {
    final filtered =
        _allCampsites.where((camp) {
          final name = camp.name.toLowerCase();
          // final location = camp.location.toLowerCase();
          final q = query.toLowerCase();

          // return name.contains(q) || location.contains(q);
          return name.contains(q);
        }).toList();

    setState(() {
      _filteredCampsites = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2ECC71),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search camps...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _onSearchTextChanged,
                )
                : const Text(
                  "Camply",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _filteredCampsites = _allCampsites;
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
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
                  id: doc.id,
                  name: data['name'] ?? '',
                  location: data['location'] ?? '',
                  details: data['details'] ?? '',
                  amenities: List<String>.from(data['amenities'] ?? []),
                  imageUrl: data['imageUrl'],
                );
              }).toList();

          if (_allCampsites.isEmpty) {
            _allCampsites = campsites;
            _filteredCampsites = campsites;
          }

          return ListView.builder(
            // itemCount: campsites.length,
            // itemBuilder: (context, index) {
            //   final camp = campsites[index];
            itemCount: _filteredCampsites.length,
            itemBuilder: (context, index) {
              final camp = _filteredCampsites[index];
              return Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampDetailPage(campSite: camp),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image on top
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child:
                            camp.imageUrl != null && camp.imageUrl!.isNotEmpty
                                ? Image.network(
                                  camp.imageUrl!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: double.infinity,
                                  height: 150,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 8),

                      // Camp name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          camp.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Camp location
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          camp.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCampPage()),
          );
        },
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
