class CampSite {
  final String id;
  final String name;
  final String location;
  final String? imageUrl;
  final String? details;
  final List<String>? amenities;
  final Map<String, String>? nearbyPlaces;

  CampSite({
    required this.id,
    required this.name,
    required this.location,
    this.imageUrl,
    this.amenities,
    this.details,
    this.nearbyPlaces,
  });

  factory CampSite.fromMap(Map<String, dynamic> map, String id) {
    return CampSite(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'],
      details: map['details'],
      amenities: List<String>.from(map['amenities'] ?? []),
      nearbyPlaces: map['nearbyPlaces'] != null
          ? Map<String, String>.from(map['nearbyPlaces'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'amenities': amenities,
      'details': details,
      'nearbyPlaces': nearbyPlaces,
    };
  }

  static Map<String, String> getDefaultNearbyPlaces() {
    return {
      'Hospital': '2 km',
      'Fire Department': '5 km',
      'Police': '3 km',
      'Pharmacy': '1 km',
      'Restaurant': '500 m',
    };
  }
}