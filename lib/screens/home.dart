import 'package:camply/screens/view_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:camply/services/post_service.dart';
import 'package:camply/services/auth_service.dart';
import 'package:camply/Components/BottomNavBar.dart';
import 'package:camply/Components/commentPopup.dart';
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
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text(
          "Camply",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
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

          final docs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['userId'] !=
                    _authService.currentUser?.uid; // filter out own posts
              }).toList();

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
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              try {
                final post = Post.fromFirestore(doc);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ViewUserPage(
                              userId: post.profileId,
                              userName: post.username,
                              userProfilePic: post.profilePic,
                            ),
                      ),
                    );
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
    _loadPostData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Stop timer when widget is removed
    super.dispose();
  }

  void _loadPostData() {
    _checkIfLiked();
    _checkBookmarkStatus();
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

  Future<void> _checkBookmarkStatus() async {
    final bookmarked = await PostService.isPostBookmarked(widget.postId);
    if (!mounted) return;
    setState(() {
      isBookmarked = bookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
    await PostService.toggleBookmark(
      postId: widget.postId,
      ownerId: widget.profileId,
    );
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
        return CommentPopup(
          postOwnerId: widget.profileId,
          componentId: widget.postId,
          component: "posts",
        );
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
                  onTap: _toggleBookmark,
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.green,
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
