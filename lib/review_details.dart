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
  TextEditingController _replyController = TextEditingController();

  void _sendReply() async {
    if (_replyController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).collection('replies').add({
        'username': 'YourUsername',  // Replace with logged-in user's username
        'reply': _replyController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _replyController.clear();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('MMMM dd, yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review Details"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView( // Wrap the body with a SingleChildScrollView
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            String username = data['username'] ?? "Unknown User";
            String profilePhotoUrl = data['profilePhotoUrl'] ?? "";
            Timestamp timestamp = data['timestamp'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile photo and username
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

                  // Review comment
                  Text("Comment:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(data['comment'] ?? "No comment"),
                  SizedBox(height: 5),

                  // Display review timestamp
                  Text("Posted on: ${_formatTimestamp(timestamp)}", style: TextStyle(color: Colors.grey, fontSize: 12)),

                  SizedBox(height: 20),

                  // Display replies
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).collection('replies').orderBy('timestamp').snapshots(),
                    builder: (context, replySnapshot) {
                      if (!replySnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var replies = replySnapshot.data!.docs;

                      return Column(
                        children: replies.map((replyDoc) {
                          var replyData = replyDoc.data() as Map<String, dynamic>;
                          String replyUsername = replyData['username'];
                          String replyText = replyData['reply'];
                          Timestamp replyTimestamp = replyData['timestamp'];

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
                                      Text("Replied on: ${_formatTimestamp(replyTimestamp)}", style: TextStyle(color: Colors.grey, fontSize: 12)),
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

                  // Reply TextField
                  TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: "Write a reply...",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendReply,
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
