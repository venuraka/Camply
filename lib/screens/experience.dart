import 'dart:async';

import 'package:camply/services/notification_service.dart';
import 'package:camply/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Components/commentPopup.dart';

class ExperienceTile extends StatefulWidget {
  final String docId;
  final String experienceOwnerId;

  // final String experienceOwnerName;
  final String title;
  final String description;
  final String location;
  final int likeCount;
  final int commentCount;
  final Timestamp? timestamp; // Add timestamp parameter
  final String Function(Timestamp?)?
  formatTimestamp; // Add formatting function parameter

  const ExperienceTile({
    super.key,
    required this.docId,
    required this.experienceOwnerId,
    required this.title,
    required this.description,
    required this.location,
    required this.likeCount,
    required this.commentCount,
    this.timestamp, // Make timestamp optional
    this.formatTimestamp, // Make formatTimestamp optional
  });

  @override
  State<ExperienceTile> createState() => _ExperienceTileState();
}

class _ExperienceTileState extends State<ExperienceTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool isLiked = false;
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Stop timer when widget is removed
    _controller.dispose();
    super.dispose();
  }

  void _checkIfLiked() async {
    final liked = await PostService.isExperienceLiked(
      postOwnerId: widget.experienceOwnerId,
      postId: widget.docId,
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
              .collection('experiences')
              .doc(widget.experienceOwnerId)
              .collection('user_experiences')
              .doc(widget.docId)
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

    await PostService.experiencesToggleLike(
      postOwnerId: widget.experienceOwnerId,
      postId: widget.docId,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(widget.location),
                  ],
                ),
              ),
            Text(widget.description),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: toggleLike,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('$currentLikeCount'),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap:
                      () => showCommentPopup(
                        context,
                        widget.experienceOwnerId,
                        widget.docId,
                        "experiences",
                      ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 6),
                Text('$currentCommentCount'),
                if (widget.timestamp != null &&
                    widget.formatTimestamp != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.formatTimestamp!(widget.timestamp),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── AddExperienceScreen ─────────────────────────────────────
class AddExperienceScreen extends StatefulWidget {
  const AddExperienceScreen({super.key});

  @override
  State<AddExperienceScreen> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final _titleCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _showTag = false;

  String userId = "";
  String userName = "";
  String userProfilePic = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      try {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          final name = data['name'] ?? 'User';
          final profilePic =
              data['profileImageUrl'] ??
              'https://img.freepik.com/premium-vector/character-avatar-isolated_729149-194801.jpg?ga=GA1.1.620892737.1745985582&semt=ais_hybrid&w=740';

          setState(() {
            userId = uid;
            userName = name;
            userProfilePic = profilePic;
            isLoading = false;
          });
        } else {
          _showSnackBar('User document not found.');
          setState(() => isLoading = false);
        }
      } catch (e) {
        _showSnackBar('Failed to fetch user data: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void _submit() async {
    final title = _titleCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty || loc.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final newExperienceRef =
        FirebaseFirestore.instance
            .collection('experiences')
            .doc(userId)
            .collection('user_experiences')
            .doc();

    await newExperienceRef.set({
      'userId': userId,
      'title': title,
      'location': loc,
      'description': desc,
      'likeCount': 0,
      'commentCount': 0,
      'timestamp':
          FieldValue.serverTimestamp(), // Use serverTimestamp for consistency
    });

    await NotificationService.sendNewExperienceNotificationToFollowers(
      experienceId: newExperienceRef.id,
      experienceOwnerId: userId,
      experienceOwnerName: userName,
      experienceOwnerPic: userProfilePic,
    );
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 55),
          child: const Text(
            'Add Experience',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF2ECC71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locCtrl,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _showTag = v.isNotEmpty),
            ),
            if (_showTag)
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(_locCtrl.text),
                  avatar: const Icon(
                    Icons.place,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
