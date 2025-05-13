// ---------- Comment Model ----------
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String ownerId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String profilePic;
  final bool isReplied;
  final String? replyToCommentId;
  final String? replyToUserId;
  final String? replyToUserName;
  List<Comment> replies;
  bool isLiked;
  bool showReplies;
  int likeCount;

  Comment({
    required this.commentId,
    required this.ownerId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.profilePic,
    required this.isReplied,
    this.replyToCommentId,
    this.replyToUserId,
    this.replyToUserName,
    this.isLiked = false,
    List<Comment>? replies,
    this.showReplies = true,
    this.likeCount = 0,
  }) : replies = replies ?? [];

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      commentId: data['commentId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['commentText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profilePic:
      data['profilePic'] ??
          'https://randomuser.me/api/portraits/men/30.jpg',
      // add this field in Firestore
      isReplied: data['isReplied'] ?? false,
      replyToCommentId: data['replyToCommentId'],
      replyToUserId: data['replyToUserId'],
      replyToUserName: data['replyToUserName'],
      likeCount: data['likeCount'] ?? 0,
      isLiked: data['isLiked'] ?? false,
    );
  }
}
