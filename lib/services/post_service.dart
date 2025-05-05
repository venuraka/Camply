import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Likes
  static Future<void> postsToggleLike({
    required String postOwnerId,
    required String postId,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final currentUserName = userDoc.data()?['name'] ?? 'User';

    final likesDocRef = _firestore
        .collection('posts')
        .doc(postOwnerId)
        .collection('user_posts')
        .doc(postId)
        .collection('likes')
        .doc('summary');

    final likesDoc = await likesDocRef.get();

    if (likesDoc.exists) {
      final data = likesDoc.data();
      List userIds = [];
      // List userNames = [];

      if (data != null) {
        userIds = data['userIds'] ?? [];
        // userNames = data['userNames'] ?? [];
      }

      if (userIds.contains(currentUserId)) {
        // Unlike
        await likesDocRef.update({
          'userIds': FieldValue.arrayRemove([currentUserId]),
          'userNames': FieldValue.arrayRemove([currentUserName]),
        });
        await _firestore
            .collection('posts')
            .doc(postOwnerId)
            .collection('user_posts')
            .doc(postId)
            .update({'likeCount': FieldValue.increment(-1)});
      } else {
        // Like
        await likesDocRef.update({
          'userIds': FieldValue.arrayUnion([currentUserId]),
          'userNames': FieldValue.arrayUnion([currentUserName]),
        });
        await _firestore
            .collection('posts')
            .doc(postOwnerId)
            .collection('user_posts')
            .doc(postId)
            .update({'likeCount': FieldValue.increment(1)});
      }
    } else {
      // First like - create the summary document
      await likesDocRef.set({
        'userIds': [currentUserId],
        'userNames': [currentUserName],
      });
      await _firestore
          .collection('posts')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId)
          .update({'likeCount': FieldValue.increment(1)});
    }
  }

  // Check if the current user liked the post
  static Future<bool> isPostLiked({
    required String postOwnerId,
    required String postId,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    final DocumentSnapshot<Map<String, dynamic>> likesDoc =
        await _firestore
            .collection('posts')
            .doc(postOwnerId)
            .collection('user_posts')
            .doc(postId)
            .collection('likes')
            .doc('summary')
            .get();

    if (!likesDoc.exists) return false;

    final List<dynamic> userIds = likesDoc.data()?['userIds'] ?? [];

    return userIds.contains(currentUserId);
  }

  // Get list of usernames who liked
  //   static Future<List<String>> getLikeUsernames({
  //     required String postOwnerId,
  //     required String photoId,
  //   }) async {
  //     final likesDoc =
  //         await _firestore
  //             .collection('posts')
  //             .doc(postOwnerId)
  //             .collection('user_posts')
  //             .doc(photoId)
  //             .collection('likes')
  //             .doc('summary')
  //             .get();

  //     if (!likesDoc.exists) return [];

  //     return List<String>.from(likesDoc.data()!['userNames'] ?? []);
  //   }

  // Comments
  static Future<void> addPostComment({
    required String postOwnerId,
    required String photoId,
    required String commentText,
    required String username,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    final commentRef = _firestore
        .collection('posts')
        .doc(postOwnerId)
        .collection('user_posts')
        .doc(photoId)
        .collection('comments');

    await commentRef.add({
      'userId': currentUserId,
      'username': username,
      'comment': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('posts')
        .doc(postOwnerId)
        .collection('user_posts')
        .doc(photoId)
        .update({'commentCount': FieldValue.increment(1)});
  }

  // Get comments for a post
  static Future<List<Map<String, dynamic>>> getComments({
    required String postOwnerId,
    required String photoId,
  }) async {
    final commentsSnapshot =
        await _firestore
            .collection('posts')
            .doc(postOwnerId)
            .collection('user_posts')
            .doc(photoId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    return commentsSnapshot.docs.map((doc) => doc.data()).toList();
  }
}
