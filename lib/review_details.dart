import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReviewDetailPage extends StatefulWidget {
  final String reviewId;

  ReviewDetailPage({required this.reviewId});

  @override
  _ReviewDetailPageState createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose(); // Important to prevent memory leaks
    super.dispose();
  }

  void _sendReply() async {
    if (_replyController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.reviewId)
          .collection('replies')
          .add({
        'username': 'YourUsername', // Replace with actual logged-in user
        'reply': _replyController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _replyController.clear();
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Loading time...";
    return DateFormat('MMMM dd, yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review Details"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("Review not found."));
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            String username = data['username'] ?? "Unknown User";
            String profilePhotoUrl = data['profilePhotoUrl'] ?? "";
            Timestamp? timestamp = data['timestamp'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: profilePhotoUrl.isNotEmpty
                            ? NetworkImage(profilePhotoUrl)
                            : AssetImage('images/profile.jpg') as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),

                  Text("Comment:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(data['comment'] ?? "No comment available."),
                  SizedBox(height: 5),

                  Text(
                    "Posted on: ${_formatTimestamp(timestamp)}",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  SizedBox(height: 20),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .doc(widget.reviewId)
                        .collection('replies')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, replySnapshot) {
                      if (replySnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No replies yet."));
                      }

                      var replies = replySnapshot.data!.docs;

                      return Column(
                        children: replies.map((replyDoc) {
                          var replyData = replyDoc.data() as Map<String, dynamic>;
                          String replyUsername = replyData['username'] ?? "Unknown User";
                          String replyText = replyData['reply'] ?? "";
                          Timestamp? replyTimestamp = replyData['timestamp'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage('images/profile.jpg'),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(replyUsername, style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(replyText),
                                      SizedBox(height: 5),
                                      Text(
                                        "Replied on: ${_formatTimestamp(replyTimestamp)}",
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: "Write a reply...",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendReply,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
