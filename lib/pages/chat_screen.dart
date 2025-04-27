import 'package:camply/pages/chat_test_login.dart';
import 'package:camply/screens/login.dart';
import 'package:camply/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String siteName;
  final String siteId;

  const ChatScreen({super.key, required this.siteName, required this.siteId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final AuthService _authService = AuthService();

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

  CollectionReference get messages => FirebaseFirestore.instance
      .collection('campsite_chats')
      .doc(widget.siteName)
      .collection('messages');

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _signOut();
      });
    }
  }

  void sendMessage() async {
    final String text = _controller.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (text.isNotEmpty && user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      messages.add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'name': userName ?? 'Anonymous',
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.siteName} Channel")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IconButton(
              //   onPressed: () {
              //     Navigator.pushNamed(context, "/çhatTestSiteList");
              //   },
              //   icon: Icon(Icons.arrow_back),
              //   color: Colors.black,
              // ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messages.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final isMe =
                        data['userId'] ==
                        FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              data['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[200] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(data['text']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
