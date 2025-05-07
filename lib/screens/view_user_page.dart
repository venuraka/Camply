import 'package:cached_network_image/cached_network_image.dart';
import 'package:camply/services/follow_services.dart';
import 'package:camply/services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Components/commentPopup.dart';
import 'addphoto.dart';
import 'experience.dart'; // Ensure this file exists or remove if not used
import '../function/followSystemCount.dart';

class ViewUserPage extends StatefulWidget {
  final userId;
  final userName;
  final userProfilePic;

  const ViewUserPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
  });

  @override
  State<ViewUserPage> createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // int followerCount = 110;
  bool isFollowing = false;

  bool isLiked = false;

  // int currentLikeCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isLoading = true;

  Map<String, bool> likedPosts = {};

  @override
  void initState() {
    super.initState();

    _fetchUserData();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final followers = await getFollowersCount(widget.userId);
      final following = await getFollowingCount(widget.userId);
      final followingCheck = await FollowServices.isFollowingCheck(
        widget.userId,
      );

      setState(() {
        followersCount = followers;
        followingCount = following;
        isFollowing = followingCheck;
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Failed to fetch user data: $e');
      setState(() => isLoading = false);
    }
  }

  void _checkIfLiked(String ownerId, String postId) async {
    final liked = await PostService.isPostLiked(
      postOwnerId: ownerId,
      postId: postId,
    );

    if (!mounted) return;

    setState(() {
      likedPosts[postId] = liked;
    });
  }

  void toggleLike(String ownerId, String postId) async {
    setState(() {
      isLiked = !isLiked;
      // currentLikeCount += isLiked ? 1 : -1;
    });

    await PostService.postsToggleLike(postOwnerId: ownerId, postId: postId);
  }

  void showCommentPopup(
    BuildContext context,
    String postOwnerId,
    String componentId,
    String component,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CommentPopup(
          postOwnerId: postOwnerId,
          componentId: componentId,
          component: component,
        );
      },
    );
  }

  // Format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  // Toggle follow state
  void _toggleFollow() async {
    await FollowServices.toggleFollow(widget.userId, widget.userName);

    setState(() {
      isFollowing = !isFollowing;
      followingCount += isFollowing ? 1 : -1;
    });
  }

  // Show snackbar for user feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 80),
          child: const Text('Camply', style: TextStyle(color: Colors.white)),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.userProfilePic),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            widget.userName ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 45),
                        child: Row(
                          children: [
                            Text(
                              'Followers\n${followersCount ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Following\n${followingCount ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 60, top: 10.0),
                        child: SizedBox(
                          width: 110,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                96,
                                203,
                                99,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isFollowing ? 'Following' : 'Follow'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [Tab(text: 'Photos'), Tab(text: 'Experience')],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Photos Tab
                Stack(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.userId)
                              .collection('user_posts')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {
                          return Center(child: Text('Error: ${snap.error}'));
                        }
                        final docs = snap.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No photos yet.'));
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: docs.length, // Fixed typo: Drs -> docs
                          itemBuilder: (ctx, i) {
                            final data = docs[i].data() as Map<String, dynamic>;
                            final imageUrl = data['imageUrl'] as String?;
                            final location =
                                data['location'] ?? 'Unknown Location';
                            final likes = data['likeCount'] ?? 0;
                            final comments = data['commentCount'] ?? 0;
                            final timestamp = data['timestamp'] as Timestamp?;
                            final postOwnerId =
                                data['userId'] ?? 'Unknown User';
                            final docId = docs[i].id;

                            return FutureBuilder<bool>(
                              future: PostService.isPostLiked(
                                postOwnerId: postOwnerId,
                                postId: docId,
                              ),
                              builder: (context, snapshot) {
                                final isLiked = snapshot.data ?? false;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.greenAccent,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                        leading: CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            widget.userProfilePic,
                                          ),
                                        ),
                                        title: Text(
                                          widget.userName ?? 'Loading...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(location),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            imageUrl != null
                                                ? CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  height: 250,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (
                                                        context,
                                                        url,
                                                      ) => const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => const Center(
                                                        child: Text(
                                                          'Failed to load image',
                                                        ),
                                                      ),
                                                )
                                                : const Center(
                                                  child: Text(
                                                    'No image available',
                                                  ),
                                                ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap:
                                                      () => toggleLike(
                                                        widget.userId,
                                                        docId,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isLiked
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        color:
                                                            isLiked
                                                                ? Colors.red
                                                                : Colors.green,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$likes',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap:
                                                      () => showCommentPopup(
                                                        context,
                                                        postOwnerId,
                                                        docId,
                                                        "posts",
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .chat_bubble_outline,
                                                        color: Colors.green,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$comments',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              _formatTimestamp(timestamp),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                // Experience Tab
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('experiences')
                          .doc(widget.userId)
                          .collection('user_experiences')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No experiences yet.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                      itemCount: docs.length,
                      itemBuilder: (ctx, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final timestamp = data['timestamp'] as Timestamp?;
                        return ExperienceTile(
                          docId: docs[i].id,
                          title: data['title'] ?? '',
                          experienceOwnerId: data['userId'] ?? '',
                          description: data['description'] ?? '',
                          location: data['location'] ?? '',
                          likeCount: data['likeCount'] ?? 0,
                          commentCount: data['commentCount'] ?? 0,
                          timestamp: timestamp,
                          formatTimestamp: _formatTimestamp,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
