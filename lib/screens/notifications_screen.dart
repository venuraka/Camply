import 'package:camply/Components/BottomNavBar.dart';
import 'package:camply/pages/chat_screen.dart';
import 'package:camply/screens/view_user_page.dart';
import 'package:camply/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 3;

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await NotificationService.getUserNotifications(user.uid);
  }

  String _formatTimestamp(DateTime? notificationDateTime) {
    if (notificationDateTime == null) return 'Unknown time';
    final now = DateTime.now();
    final difference = now.difference(notificationDateTime);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text("No New Notifications"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final id = notification['id'] ?? 'No Id';
              final title = notification['title'] ?? 'No Title';
              final content = notification['content'] ?? 'No Content';
              final timestamp =
                  notification['timestamp'] != null
                      ? (notification['timestamp'] as Timestamp).toDate()
                      : null;

              final String type = notification['type'] ?? '';

              return Dismissible(
                key: Key(id), // Use notification ID as unique key
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red[400],
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // Confirmation dialog
                  return await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Delete Notification"),
                          content: const Text(
                            "Are you sure you want to delete this notification?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                  );
                },
                onDismissed: (_) async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await NotificationService.deleteNotification(
                      userId: user.uid,
                      notificationId: id,
                    );

                    setState(() {
                      notifications.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notification deleted")),
                    );
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    if (type == "post") {
                      final postId = notification['postId'] ?? '';
                      final postOwnerId = notification['postOwnerId'] ?? '';
                      final postOwnerName = notification['postOwnerName'] ?? '';
                      final postOwnerPic = notification['postOwnerPic'] ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => (ViewUserPage(
                                userId: postOwnerId,
                                userName: postOwnerName,
                                userProfilePic: postOwnerPic,
                              )),
                        ),
                      );
                    } else if (type == "experience") {
                      final experienceId = notification['experienceId'] ?? '';
                      final experienceOwnerId =
                          notification['experienceOwnerId'] ?? '';
                      final experienceOwnerName =
                          notification['experienceOwnerName'] ?? '';
                      final experienceOwnerPic =
                          notification['experienceOwnerPic'] ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => (ViewUserPage(
                                userId: experienceOwnerId,
                                userName: experienceOwnerName,
                                userProfilePic: experienceOwnerPic,
                              )),
                        ),
                      );
                    } else {
                      final siteId = notification['siteId'] ?? '';
                      final siteName = notification['siteName'] ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => (ChatScreen(
                                siteName: siteName,
                                siteId: siteId,
                              )),
                        ),
                      );
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Color(0xFF2ECC71),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(content),
                          if (timestamp != null)
                            Text(
                              _formatTimestamp(timestamp),
                              // '${timestamp.toLocal()}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }
}
