import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  Future addCamp(Map<String, dynamic> addcampMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("campsites")
        .doc(id)
        .set(addcampMap);
  }
}