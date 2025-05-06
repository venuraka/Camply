// ---------- Comment Model ----------
class Comment {
  final String username;
  final String text;
  final DateTime timestamp;
  final String profilePic;
  final bool isVerified;
  List<Comment> replies;
  bool isLiked;
  bool showReplies;
  int likeCount;

  Comment({
    required this.username,
    required this.text,
    required this.timestamp,
    required this.profilePic,
    required this.isVerified,
    this.isLiked = false,
    this.replies = const [],
    this.showReplies = true,
    this.likeCount = 0,
  });
}
