import 'package:camply/pages/chat_test_site_details.dart';
import 'package:camply/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatTestCampList extends StatefulWidget {
  const ChatTestCampList({super.key});

  @override
  State<ChatTestCampList> createState() => _ChatTestCampListState();
}

class _ChatTestCampListState extends State<ChatTestCampList> {
  // Ayeshi Login Signout Functionality
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authService.currentUser != null) {
        final data = await _authService.getUserData(
          _authService.currentUser!.uid,
        );
        setState(() {
          userData = data;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campsites"),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _signOut,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('campsites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading campsites'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final campsites = snapshot.data?.docs ?? [];

          return ListView(
            scrollDirection: Axis.vertical,
            children:
                campsites.map((doc) {
                  final siteName = doc['name'] ?? 'Unnamed';
                  final siteId = doc.id;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatTestSiteDetails(
                                siteName: siteName,
                                siteId: siteId,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          siteName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
