import 'package:camply/services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camply/services/auth_service.dart';
import 'package:camply/Components/BottomNavBar.dart';
import 'package:camply/models/post_model.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Ayeshi Login Signout Functionality
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authService.currentUser != null) {
        final data = await _authService.getUserData(
          _authService.currentUser!.uid,
        );
        setState(() {
          userData = data;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Navigation will be handled by the AuthWrapper
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text(
          "Camply",
          // Can load user name to check if needed
          // title: Text(
          //   "Camper ${userData?['name'] ?? ''}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
          // IconButton(icon: const Icon(Icons.search), onPressed: _signOut),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collectionGroup('user_posts')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts found."));
          }

          // final posts =
          //     snapshot.data!.docs.where((doc) {
          //       final data = doc.data() as Map<String, dynamic>;
          //       return data['userId'] !=
          //           _authService.currentUser?.uid; // filter out own posts
          //     }).toList();
          final docs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['userId'] !=
                    _authService.currentUser?.uid; // filter out own posts
              }).toList();

          // if (posts.isEmpty) {
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No New Posts Uploaded Yet.",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            // itemCount: posts.length,
            // itemBuilder: (context, index) {
            //   final data = posts[index].data() as Map<String, dynamic>;
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              try {
                // final post = Post.fromFirestore(data);
                final post = Post.fromFirestore(doc);
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => CampDetailsDisplay()),
                    // );
                  },
                  child: PostCard(
                    postId: post.postId,
                    username: post.username,
                    location: post.location,
                    imageUrl: post.imageUrl,
                    profileId: post.profileId,
                    profilePic: post.profilePic,
                    badgeColors: [
                      Colors.brown,
                      Colors.orange,
                      Colors.grey,
                      Colors.green,
                    ],
                    likeCount: post.likeCount,
                    commentCount: post.commentCount,
                  ),
                );
              } catch (e) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Failed to load post.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }
}

// ---------- PostCard Widget ----------
class PostCard extends StatefulWidget {
  final String postId;
  final String username;
  final String location;
  final String imageUrl;
  final String profileId;
  final String profilePic;
  final List<Color> badgeColors;
  final int likeCount;
  final int commentCount;
  // final int shareCount;

  const PostCard({
    super.key,
    required this.postId,
    required this.username,
    required this.location,
    required this.imageUrl,
    required this.profileId,
    required this.profilePic,
    required this.badgeColors,
    required this.likeCount,
    required this.commentCount,
    // required this.shareCount,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isBookmarked = false;
  int currentLikeCount = 0;
  int currentCommentCount = 0;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    currentLikeCount = widget.likeCount;
    currentCommentCount = widget.commentCount;
    _checkIfLiked();
    _startAutoRefresh();
  }

  void _checkIfLiked() async {
    final liked = await PostService.isPostLiked(
      postOwnerId: widget.profileId,
      postId: widget.postId,
    );

    if (!mounted) return; // Prevent setState after dispose

    setState(() {
      isLiked = liked;
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _refreshLikeAndCommentCounts();
    });
  }

  Future<void> _refreshLikeAndCommentCounts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.profileId)
              .collection('user_posts')
              .doc(widget.postId)
              .get();

      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final newLikes = data['likeCount'] ?? 0;
      final newComments = data['commentCount'] ?? 0;

      if (!mounted) return;
      setState(() {
        currentLikeCount = newLikes;
        currentCommentCount = newComments;
      });
    } catch (e) {
      print("Failed to refresh counts: $e");
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Stop timer when widget is removed
    super.dispose();
  }

  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      currentLikeCount += isLiked ? 1 : -1;
    });

    await PostService.postsToggleLike(
      postOwnerId: widget.profileId,
      postId: widget.postId,
    );
  }

  void toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  void showCommentPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const CommentPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.profilePic),
            ),
            title: Text(
              widget.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(widget.location),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.badgeColors
                      .map(
                        (color) => Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: toggleLike,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.teal,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Beautifully displayed like count with a slight adjustment
                    Text(
                      '$currentLikeCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => showCommentPopup(context),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Beautifully displayed comment count
                    Text(
                      '${widget.commentCount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                // Share icon functionality is commented out for now
                // GestureDetector(
                //   onTap: () {
                //     // Share logic would go here
                //   },
                //   child: const Icon(Icons.send_outlined, color: Colors.blue, size: 28),
                // ),
                // Text(
                //   '${widget.shareCount}',
                //   style: const TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black54,
                //   ),
                // ),
                GestureDetector(
                  onTap: toggleBookmark,
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color:
                        isBookmarked
                            ? const Color.fromARGB(255, 218, 200, 3)
                            : Colors.green,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Comment Popup ----------
class CommentPopup extends StatefulWidget {
  const CommentPopup({super.key});

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  final List<_Comment> _comments = [];
  _Comment? _replyTo;

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = _Comment(
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

  Widget _buildCommentTile(_Comment comment, {bool isReply = false}) {
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

// ---------- Comment Model ----------
class _Comment {
  final String username;
  final String text;
  final DateTime timestamp;
  final String profilePic;
  final bool isVerified;
  List<_Comment> replies;
  bool isLiked;
  bool showReplies;
  int likeCount;

  _Comment({
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
