import 'package:camply/pages/chat_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatTestSiteDetails extends StatefulWidget {
  final String siteName;
  final String siteId;

  const ChatTestSiteDetails({
    super.key,
    required this.siteName,
    required this.siteId,
  });

  @override
  State<ChatTestSiteDetails> createState() => _ChatTestSiteDetailsState();
}

class _ChatTestSiteDetailsState extends State<ChatTestSiteDetails> {
  bool isFollowing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkFollowingStatus();
  }

  Future<void> checkFollowingStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final snapshot = await userDoc.get();
    final List<dynamic> followingSites =
        snapshot.data()?['followingSites'] ?? [];

    setState(() {
      isFollowing = followingSites.contains(widget.siteId);
      isLoading = false;
    });
  }

  Future<void> toggleFollow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final snapshot = await userDoc.get();
    final List<dynamic> followingSites =
        snapshot.data()?['followingSites'] ?? [];

    if (followingSites.contains(widget.siteId)) {
      await userDoc.update({
        'followingSites': FieldValue.arrayRemove([widget.siteId]),
      });
      setState(() {
        isFollowing = false;
      });
    } else {
      await userDoc.update({
        'followingSites': FieldValue.arrayUnion([widget.siteId]),
      });
      setState(() {
        isFollowing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.siteName)),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: toggleFollow,
                      child: Text(isFollowing ? "Following" : "Follow"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          isFollowing
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatScreen(
                                          siteName: widget.siteName,
                                          siteId: widget.siteId,
                                        ),
                                  ),
                                );
                              }
                              : null, // Disabled if not following
                      child: const Text("Chat"),
                    ),
                  ],
                ),
      ),
    );
  }
}
