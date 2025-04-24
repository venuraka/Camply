
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CamperProfileScreen(),
    );
  }
}

class CamperProfileScreen extends StatefulWidget {
  @override
  _CamperProfileScreenState createState() => _CamperProfileScreenState();
}

class _CamperProfileScreenState extends State<CamperProfileScreen> {
  String selectedTab = "Experience";
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  void _toggleFollow() async {
    setState(() {
      isFollowing = !isFollowing;
      followers += isFollowing ? 1 : -1;
    });

    // Firestore update logic (example: update current user's followers)
    await FirebaseFirestore.instance.collection('users').doc('zack_night').update({
      'followers': followers,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camper", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: Icon(Icons.menu, color: Colors.white), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/images.jpeg'),
                ),
                SizedBox(height: 10),
                Row(children: [
                  Icon(FontAwesomeIcons.instagram, color: Colors.pink),
                  SizedBox(width: 10),
                  Icon(FontAwesomeIcons.facebook, color: Colors.blue),
                  SizedBox(width: 10),
                  Icon(FontAwesomeIcons.youtube, color: Colors.red),
                ]),
              ]),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Zack Night", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Followers ${followers}  |  Following ${following}"),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      child: Text(isFollowing ? "Following" : "Follow"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => selectedTab = "Photos"),
                  child: Text(
                    "Photos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedTab == "Photos" ? Colors.green : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () => setState(() => selectedTab = "Experience"),
                  child: Text(
                    "Experience",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedTab == "Experience" ? Colors.green : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (selectedTab == "Experience")
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('experiences')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final docs = snapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) {
                      return ExperienceTile(
                        docId: doc.id,
                        title: doc['title'],
                        description: doc['description'],
                        likes: doc['likes'],
                        comments: doc['comments'],
                        location: doc['location'] ?? '',
                      );
                    }).toList(),
                  );
                },
              ),
            if (selectedTab == "Photos") Center(child: Text("Photos content goes here.")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddExperienceScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}


class ExperienceTile extends StatefulWidget {
  final String docId;
  final String title;
  final String description;
  final String location;
  final int likes;
  final int comments;

  ExperienceTile({
    required this.docId,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
    required this.location,
  });

  @override
  _ExperienceTileState createState() => _ExperienceTileState();
}

class _ExperienceTileState extends State<ExperienceTile> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late int likeCount;
  late int commentCount;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
    commentCount = widget.comments;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    _controller.forward().then((_) => _controller.reverse());

    await FirebaseFirestore.instance
        .collection('experiences')
        .doc(widget.docId)
        .update({'likes': likeCount});
  }

  void _addComment() {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: commentController,
          decoration: InputDecoration(hintText: "Enter your comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (commentController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('experiences')
                    .doc(widget.docId)
                    .update({'comments': FieldValue.increment(1)});
                setState(() => commentCount++);
              }
              Navigator.pop(context);
            },
            child: Text("Submit", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (widget.location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.place, size: 16, color: Colors.green),
                  SizedBox(width: 6),
                  Text(widget.location, style: TextStyle(color: Colors.green.shade700)),
                ],
              ),
            ),
          Text(widget.description, style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.green,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Text('$likeCount'),
              SizedBox(width: 16),
              GestureDetector(
                onTap: _addComment,
                child: Icon(Icons.chat_bubble_outline, color: Colors.green, size: 22),
              ),
              SizedBox(width: 4),
              Text('$commentCount'),
              SizedBox(width: 16),
              Text("Just now", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ]),
      ),
    );
  }
}

class AddExperienceScreen extends StatefulWidget {
  @override
  _AddExperienceScreenState createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool showTag = false;

  void _submitExperience() async {
    final title = titleController.text.trim();
    final location = locationController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('experiences').add({
      'title': title,
      'description': description,
      'location': location,
      'likes': 0,
      'comments': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Success!"),
        content: Text("Your camping experience was added."),
        actions: [
          TextButton(
            child: Text("OK", style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place, size: 16, color: Colors.green),
          SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.green.shade800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text("Add Experience", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          TextField(
            controller: titleController,
            style: GoogleFonts.poppins(fontSize: 18),
            decoration: InputDecoration(
              labelText: "Experience Title",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: locationController,
            onChanged: (val) => setState(() => showTag = val.isNotEmpty),
            style: GoogleFonts.poppins(fontSize: 18),
            decoration: InputDecoration(
              labelText: "Location (e.g., Ella Rock)",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (showTag && locationController.text.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: _buildTag(locationController.text),
            ),
          SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: TextField(
              controller: descriptionController,
              style: GoogleFonts.poppins(fontSize: 16),
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                labelText: "Describe your experience...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Submit", style: TextStyle(fontSize: 18)),
              onPressed: _submitExperience,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
