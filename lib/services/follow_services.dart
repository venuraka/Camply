import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowServices {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final currentUserId = _auth.currentUser!.uid;

  static Future<bool> isFollowingCheck(String displayUserId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(displayUserId);

      final docSnapshot = await docRef.get();

      return docSnapshot.exists;
    } catch (e) {
      print('Error fetching is following data: $e');
      return false;
    }
  }

  static Future<void> toggleFollow(
    String displayUserId,
    String displayUserName,
  ) async {
    final currentUserDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final currentUserName = currentUserDoc.data()?['name'] ?? 'User';

    final followingRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(displayUserId);

    final followerRef = _firestore
        .collection('users')
        .doc(displayUserId)
        .collection('followers')
        .doc(currentUserId);

    final isFollowing = await followingRef.get();

    if (isFollowing.exists) {
      // Unfollow
      await followingRef.delete();
      await followerRef.delete();
    } else {
      // Follow
      await followingRef.set({
        'userName': displayUserName,
        'followedOn': FieldValue.serverTimestamp(),
      });
      await followerRef.set({
        'userName': currentUserName,
        'followedOn': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<List<String>> getFollowingUserIds() async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('following')
              .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting following user IDs: $e');
      return [];
    }
  }

  static Future<List<String>> getFollowerUserIds() async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('followers')
              .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting follower user IDs: $e');
      return [];
    }
  }
}
