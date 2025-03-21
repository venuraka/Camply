import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camper App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const CamperScreen(),
    );
  }
}

class CamperScreen extends StatefulWidget {
  const CamperScreen({super.key});

  @override
  State<CamperScreen> createState() => _CamperScreenState();
}

class _CamperScreenState extends State<CamperScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Camper",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            PostCard(
              username: "Zack Night",
              location: "Yosemite Basecamp",
              imageUrl:
                  "https://img.freepik.com/free-photo/silhouette-happy-man-with-holding-coffee-cup-stay-near-tent-around-mountains_1150-9145.jpg?ga=GA1.1.1735124578.1741663265&semt=ais_hybrid",
              profileUrl: "https://randomuser.me/api/portraits/men/32.jpg",
              badgeColors: [
                Colors.brown,
                Colors.orange,
                Colors.grey,
                Colors.green,
              ],
            ),
            PostCard(
              username: "Yoshiko Mura",
              location: "Yosemite Basecamp",
              imageUrl:
                  "https://img.freepik.com/free-photo/silhouette-happy-man-with-holding-coffee-cup-stay-near-tent-around-mountains_1150-9145.jpg?ga=GA1.1.1735124578.1741663265&semt=ais_hybrid",
              profileUrl: "https://randomuser.me/api/portraits/women/45.jpg",
              badgeColors: [
                Colors.brown,
                Colors.orange,
                Colors.grey,
                Colors.green,
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String username;
  final String location;
  final String imageUrl;
  final String profileUrl;
  final List<Color> badgeColors;

  const PostCard({
    super.key,
    required this.username,
    required this.location,
    required this.imageUrl,
    required this.profileUrl,
    required this.badgeColors,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isBookmarked = false;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  void showCommentPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.profileUrl),
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
            padding: const EdgeInsets.all(12),
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
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap:
                          () => showCommentPopup(context), // Show comment popup
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.green,
                        size: 28,
                      ),
                    ),
                  ],
                ),
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

class CommentPopup extends StatefulWidget {
  const CommentPopup({super.key});

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  void _addComment() {
    setState(() {
      _comments.add(_commentController.text);
      _commentController.clear(); // Clear text field after adding comment
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures keyboard does not overlap
      appBar: AppBar(title: const Text('Comments')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Displaying comments
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(title: Text(_comments[index]));
                      },
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: "Add a comment...",
                suffixIcon: Icon(Icons.send),
              ),
              onSubmitted:
                  (_) => _addComment(), // Automatically submit on enter
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.green,
      unselectedItemColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 5, 58, 7),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore, size: 30),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: 30),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark, size: 30),
          label: "Save",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, size: 30),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30),
          label: "Profile",
        ),
      ],
    );
  }
}
