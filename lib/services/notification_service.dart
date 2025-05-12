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
}
