import 'package:cloud_firestore/cloud_firestore.dart';

import '../camp_model.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future addCamp(Map<String, dynamic> addcampMap, String id) async {
    return await _firestore.collection("campsites").doc(id).set(addcampMap);
  }

  Stream<List<CampSite>> getCamps() {
    return _firestore.collection("campsites").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CampSite(
          id: doc.id,
          name: doc['name'],
          location: doc['location'],
          details: doc['details'], amenities: [],
        );
      }).toList();
    });
  }
}