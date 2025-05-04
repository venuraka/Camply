import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> getFollowersCount(String uid) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('followers')
            .get();

    return snapshot.size;
  } catch (e) {
    print('Error fetching followers count: $e');
    return 0;
  }
}

Future<int> getFollowingCount(String uid) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('following')
            .get();

    return snapshot.size;
  } catch (e) {
    print('Error fetching following count: $e');
    return 0;
  }
}
