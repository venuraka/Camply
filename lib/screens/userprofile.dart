import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addphoto.dart';
import 'experience.dart'; // Ensure this file exists or remove if not used

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  int followerCount = 110;
  bool isFollowing = false;

  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchUserId();

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

  Future<void> _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userId = user.uid;
        isLoading = false;
      });
    } else {
      // Handle null user case if needed
      setState(() => isLoading = false);
    }
  }

  // Increment likes count
  Future<void> _incrementLikes(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(userId)
          .collection('user_posts')
          .doc(docId)
          .update({'likes': FieldValue.increment(1)});
    } catch (e) {
      _showSnackBar('Failed to update likes: $e');
    }
  }

  // Add comment and increment comments count
  Future<void> _addComment(String docId) async {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add Comment'),
            content: TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Enter your comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(userId)
                          .collection('user_posts')
                          .doc(docId)
                          .update({'comments': FieldValue.increment(1)});
                      Navigator.pop(ctx);
                      _showSnackBar('Comment added successfully');
                    } catch (e) {
                      _showSnackBar('Failed to add comment: $e');
                    }
                  } else {
                    _showSnackBar('Please enter a comment');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
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
  void _toggleFollow() {
    if (!isFollowing) {
      setState(() {
        isFollowing = true;
        followerCount += 1;
      });
    }
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

    if (userId == null) {
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
          child: const Text('CAMPER', style: TextStyle(color: Colors.white)),
        ),
        actions: const [],
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
               backgroundColor: const Color(0xFF2ECC71),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddExperienceScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
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
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/proimg.jpg'),
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
                          child: const Text(
                            'Markensan Sepperd',
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
                              'Followers\n$followerCount',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'Following\n28',
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
                        padding: const EdgeInsets.only(left: 60),
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
                              .doc(userId)
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
                            final likes = data['likes'] ?? 0;
                            final comments = data['comments'] ?? 0;
                            final timestamp = data['timestamp'] as Timestamp?;
                            final docId = docs[i].id;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.greenAccent),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    leading: const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(
                                        'assets/images/proimg.jpg',
                                      ),
                                    ),
                                    title: const Text(
                                      'Mark Sepperd',
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
                                              child: Text('No image available'),
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
                                                  () => _incrementLikes(docId),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.green,
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
                                              onTap: () => _addComment(docId),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.chat_bubble_outline,
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
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                       backgroundColor: const Color(0xFF2ECC71),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddPhoto(),
                              ),
                            ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Experience Tab
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('experiences')
                          .doc(userId)
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
                          description: data['description'] ?? '',
                          location: data['location'] ?? '',
                          likes: data['likes'] ?? 0,
                          comments: data['comments'] ?? 0,
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
