class CampSite {
  final String name;
  final String location;
  final String details;
  final List<String> amenities;
  final String? imageUrl;
  final Map<String, String> nearbyPlaces;

  CampSite({
    required this.name,
    required this.location,
    required this.details,
    required this.amenities,
    this.imageUrl,
    this.nearbyPlaces = const {},
  });

  // Default nearby places that will be shown for all camps
  static Map<String, String> getDefaultNearbyPlaces() {
    return {
      'Hospital': 'assets/icons/hospital.png',
      'Fire Department': 'assets/icons/fire_department.png',
    };
  }
}