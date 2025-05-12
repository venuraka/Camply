import 'package:camply/services/follow_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendNewPostNotificationToFollowers({
    required String postId,
    required String postOwnerId,
    required String postOwnerName,
    required String postOwnerPic,
  }) async {
    try {
      final List<String> followerIds =
          await FollowServices.getFollowerUserIds();

      if (followerIds.isEmpty) {
        print('No followers to notify for user $postOwnerId');
        return; // Exit early since there are no users to notify
      }

      final timestamp = FieldValue.serverTimestamp();

      final notificationData = {
        'title': 'New Post Added',
        'content': '$postOwnerName has posted a new post. Let\'s check it out',
        'timestamp': timestamp,
        'type': 'post',
        'postId': postId,
        'postOwnerId': postOwnerId,
        'postOwnerName': postOwnerName,
        'postOwnerPic': postOwnerPic,
      };

      for (String followerId in followerIds) {
        try {
          final notificationDocRef =
              _firestore
                  .collection('users')
                  .doc(followerId)
                  .collection('notifications')
                  .doc();

          await notificationDocRef.set({
            'id': notificationDocRef.id,
            ...notificationData,
          });
        } catch (ex) {
          print('Failed to send notification to $followerId: $ex');
        }
      }
    } catch (e) {
      print('Error sending notifications to followers: $e');
    }
  }

  static Future<void> sendNewExperienceNotificationToFollowers({
    required String experienceId,
    required String experienceOwnerId,
    required String experienceOwnerName,
    required String experienceOwnerPic,
  }) async {
    try {
      final List<String> followerIds =
          await FollowServices.getFollowerUserIds();

      if (followerIds.isEmpty) {
        print('No followers to notify for user $experienceOwnerId');
        return; // Exit early since there are no users to notify
      }

      final timestamp = FieldValue.serverTimestamp();

      final notificationData = {
        'title': 'New Experience Added',
        'content':
            '$experienceOwnerName has posted a new experience. Let\'s check it out',
        'timestamp': timestamp,
        'type': 'experience',
        'experienceId': experienceId,
        'experienceOwnerId': experienceOwnerId,
        'experienceOwnerName': experienceOwnerName,
        'experienceOwnerPic': experienceOwnerPic,
      };

      for (String followerId in followerIds) {
        try {
          final notificationDocRef =
              _firestore
                  .collection('users')
                  .doc(followerId)
                  .collection('notifications')
                  .doc();

          await notificationDocRef.set({
            'id': notificationDocRef.id,
            ...notificationData,
          });
        } catch (ex) {
          print('Failed to send notification to $followerId: $ex');
        }
      }
    } catch (e) {
      print('Error sending notifications to followers: $e');
    }
  }

  static Future<void> sendNewMessageNotification({
    required String siteId,
    required String siteName,
    required String userId,
  }) async {
    try {
      // final List<String> followerIds =
      //     await FollowServices.getFollowerUserIds();

      // Step 1: Query users where 'followingSites' contains the siteId
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('followingSites', arrayContains: siteId)
              .get();

      // Step 2: Extract user IDs of matching users
      final List<String> followerIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      if (followerIds.isEmpty) {
        print('No followers to notify for user $userId');
        return; // Exit early since there are no users to notify
      }

      followerIds.remove(userId);

      final timestamp = FieldValue.serverTimestamp();

      final notificationData = {
        'title': 'New Message',
        'content': '$siteName Channel has a new message. Let\'s check it out',
        'timestamp': timestamp,
        'type': 'message',
        'siteId': siteId,
        'siteName': siteName,
      };

      for (String followerId in followerIds) {
        try {
          final notificationDocRef =
              _firestore
                  .collection('users')
                  .doc(followerId)
                  .collection('notifications')
                  .doc();

          await notificationDocRef.set({
            'id': notificationDocRef.id,
            ...notificationData,
          });
        } catch (ex) {
          print('Failed to send notification to $followerId: $ex');
        }
      }
    } catch (e) {
      print('Error sending notifications to followers: $e');
    }
  }
}
