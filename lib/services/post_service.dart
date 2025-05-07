import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Post Likes
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
  //   static Future<List<String>> getPostLikeUsernames({
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

  // Experience Likes
  static Future<void> experiencesToggleLike({
    required String postOwnerId,
    required String postId,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final currentUserName = userDoc.data()?['name'] ?? 'User';

    final likesDocRef = _firestore
        .collection('experiences')
        .doc(postOwnerId)
        .collection('user_experiences')
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
            .collection('experiences')
            .doc(postOwnerId)
            .collection('user_experiences')
            .doc(postId)
            .update({'likeCount': FieldValue.increment(-1)});
      } else {
        // Like
        await likesDocRef.update({
          'userIds': FieldValue.arrayUnion([currentUserId]),
          'userNames': FieldValue.arrayUnion([currentUserName]),
        });
        await _firestore
            .collection('experiences')
            .doc(postOwnerId)
            .collection('user_experiences')
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
          .collection('experiences')
          .doc(postOwnerId)
          .collection('user_experiences')
          .doc(postId)
          .update({'likeCount': FieldValue.increment(1)});
    }
  }

  // Check if the current user liked the post
  static Future<bool> isExperienceLiked({
    required String postOwnerId,
    required String postId,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    final DocumentSnapshot<Map<String, dynamic>> likesDoc =
        await _firestore
            .collection('experiences')
            .doc(postOwnerId)
            .collection('user_experiences')
            .doc(postId)
            .collection('likes')
            .doc('summary')
            .get();

    if (!likesDoc.exists) return false;

    final List<dynamic> userIds = likesDoc.data()?['userIds'] ?? [];

    return userIds.contains(currentUserId);
  }

  // Get list of usernames who liked
  //   static Future<List<String>> getExperienceLikeUsernames({
  //     required String postOwnerId,
  //     required String photoId,
  //   }) async {
  //     final likesDoc =
  //         await _firestore
  //             .collection('experiences')
  //             .doc(postOwnerId)
  //             .collection('user_experiences')
  //             .doc(photoId)
  //             .collection('likes')
  //             .doc('summary')
  //             .get();

  //     if (!likesDoc.exists) return [];

  //     return List<String>.from(likesDoc.data()!['userNames'] ?? []);
  //   }

  // Comments
  static Future<void> addComment({
    required String component,
    required String postOwnerId,
    required String componentId,
    required bool isReplied,
    required String commentText,
    String? replyToCommentId,
    String? replyToUserId,
    String? replyToUserName,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final currentUserName = userDoc.data()?['name'] ?? 'User';
    final profilePic = userDoc.data()?['profileImageUrl'] ?? '';

    final commentRef =
        _firestore
            .collection(component)
            .doc(postOwnerId)
            .collection('user_$component')
            .doc(componentId)
            .collection('comments')
            .doc();

    final commentId = commentRef.id;

    final commentData = {
      'commentId': commentId,
      'componentId': componentId,
      'ownerId': postOwnerId,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'commentText': commentText,
      'profilePic': profilePic,
      'isReplied': isReplied,
      'likeCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (isReplied) {
      commentData.addAll({
        'replyToCommentId': replyToCommentId,
        'replyToUserId': replyToUserId,
        'replyToUserName': replyToUserName,
      });
    }
    await commentRef.set(commentData);

    await _firestore
        .collection(component)
        .doc(postOwnerId)
        .collection('user_$component')
        .doc(componentId)
        .update({'commentCount': FieldValue.increment(1)});
  }

  static Future<List<Map<String, dynamic>>> getComments({
    required String component,
    required String postOwnerId,
    required String componentId,
  }) async {
    final commentsSnapshot =
        await _firestore
            .collection(component)
            .doc(postOwnerId)
            .collection('user_$component')
            .doc(componentId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    return commentsSnapshot.docs.map((doc) => doc.data()).toList();
  }
}
