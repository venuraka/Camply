class CampSite {
  final String name;
  final String location;
  final String details;
  final List<String> amenities;
  final List<String> nearbyPlaces;
  final String? imageUrl;
  final double rating;

  CampSite({
    required this.name,
    required this.location,
    required this.details,
    required this.amenities,
    required this.nearbyPlaces,
    this.imageUrl,
    this.rating = 0.0,
  });

  static List<String> getDefaultNearbyPlaces() {
    return [
      'Hospital',
      'Police Station',
      'Fire Department',
      'Pharmacy',
      'Restaurant',
    ];
  }
}
