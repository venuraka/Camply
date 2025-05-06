// ---------- Comment Popup ----------
import 'package:flutter/material.dart';
import 'package:camply/models/comment_model.dart';

class CommentPopup extends StatefulWidget {
  const CommentPopup({super.key});

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  Comment? _replyTo;

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      username: "User",
      text: _commentController.text.trim(),
      timestamp: DateTime.now(),
      replies: [],
      profilePic: "https://randomuser.me/api/portraits/men/30.jpg",
      isVerified: true,
    );

    setState(() {
      if (_replyTo != null) {
        _replyTo!.replies.insert(0, newComment);
        _replyTo = null;
      } else {
        _comments.insert(0, newComment);
      }
      _commentController.clear();
    });
  }

  String _formatTimeDifference(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }

  Widget _buildCommentTile(Comment comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: isReply ? 40 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.profilePic),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTimeDifference(comment.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(comment.text),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: comment.isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              comment.isLiked = !comment.isLiked;
                              if (comment.isLiked) {
                                comment.likeCount++;
                              } else {
                                comment.likeCount--;
                              }
                            });
                          },
                        ),
                        Text(comment.likeCount.toString()),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _replyTo = comment;
                            });
                          },
                          child: const Text(
                            "Reply",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        if (comment.replies.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                comment.showReplies = !comment.showReplies;
                              });
                            },
                            child: Text(
                              comment.showReplies ? "Hide " : "View ",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 84, 97, 108),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.showReplies)
            Column(
              children:
                  comment.replies
                      .map((reply) => _buildCommentTile(reply, isReply: true))
                      .toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Comments",
          style: TextStyle(
            color: Colors.white, // Change text color here
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF2ECC71),
        toolbarHeight: 80, // Change the height here
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white, // Change the back arrow color here
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child:
                _comments.isEmpty
                    ? const Center(child: Text("No comments yet."))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      reverse: true,
                      itemCount: _comments.length,
                      itemBuilder:
                          (context, index) =>
                              _buildCommentTile(_comments[index]),
                    ),
          ),
          const Divider(),
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText:
                          _replyTo == null
                              ? "Add a comment..."
                              : "Replying to ${_replyTo!.username}",
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
