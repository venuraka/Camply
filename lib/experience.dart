import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExperienceTile extends StatefulWidget {
  final String docId;
  final String title;
  final String description;
  final String location;
  final int likes;
  final int comments;
  final Timestamp? timestamp; // Add timestamp parameter
  final String Function(Timestamp?)? formatTimestamp; // Add formatting function parameter

  const ExperienceTile({
    super.key,
    required this.docId,
    required this.title,
    required this.description,
    required this.location,
    required this.likes,
    required this.comments,
    this.timestamp, // Make timestamp optional
    this.formatTimestamp, // Make formatTimestamp optional
  });

  @override
  State<ExperienceTile> createState() => _ExperienceTileState();
}

class _ExperienceTileState extends State<ExperienceTile>
    with SingleTickerProviderStateMixin {
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
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
    final cCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: cCtrl,
          decoration: const InputDecoration(hintText: 'Enter comment...'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (cCtrl.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('experiences')
                    .doc(widget.docId)
                    .update({'comments': FieldValue.increment(1)});
                setState(() => commentCount++);
              }
              Navigator.pop(context);
            },
            child: const Text('Submit', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
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
            Text(widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  onTap: _toggleLike,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('$likeCount'),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _addComment,
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                ),
                const SizedBox(width: 6),
                Text('$commentCount'),
                if (widget.timestamp != null && widget.formatTimestamp != null) ...[
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

  void _submit() async {
    final title = _titleCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty || loc.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    await FirebaseFirestore.instance.collection('experiences').add({
      'title': title,
      'location': loc,
      'description': desc,
      'likes': 0,
      'comments': 0,
      'timestamp': FieldValue.serverTimestamp(), // Use serverTimestamp for consistency
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Experience'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(
            controller: _locCtrl,
            decoration: const InputDecoration(labelText: 'Location'),
            onChanged: (v) => setState(() => _showTag = v.isNotEmpty),
          ),
          if (_showTag)
            Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                    label: Text(_locCtrl.text),
                    avatar: const Icon(Icons.place,
                        size: 16, color: Colors.green))),
          const SizedBox(height: 12),
          TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Submit')),
          ),
        ]),
      ),
    );
  }
}

// ── Experience List (Stream) ────────────────────────────────
class ExperienceList extends StatelessWidget {
  final String Function(Timestamp?)? formatTimestamp; // Add formatTimestamp parameter

  const ExperienceList({super.key, this.formatTimestamp});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('experiences')
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
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final d = docs[i];
            return ExperienceTile(
              docId: d.id,
              title: d['title'],
              description: d['description'],
              location: d['location'] ?? '',
              likes: d['likes'],
              comments: d['comments'],
              timestamp: d['timestamp'] as Timestamp?, // Pass timestamp
              formatTimestamp: formatTimestamp, // Pass formatTimestamp function
            );
          },
        );
      },
    );
  }
}

// ── Experience Screen with FAB ──────────────────────────────
class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experiences'), backgroundColor: Colors.green),
      body: const ExperienceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExperienceScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}