import 'dart:io';
import 'package:camply/screens/userprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

// Cloudinary configuration (replace with your actual values)
const String CLOUDINARY_CLOUD_NAME = 'dvoesribg';
const String CLOUDINARY_UPLOAD_PRESET = 'flutter_upload';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _image;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  String profilePic = '';
  bool _isDBPicChanged = false;
  bool _isLoading = false;

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData(userId);

      if (userData != null) {
        setState(() {
          _userNameController.text = userData['name'] ?? '';
        });

        if (userData.containsKey('facebookUrl')) {
          setState(() {
            _facebookController.text = userData['facebookUrl'] ?? '';
          });
        }
        if (userData.containsKey('instagramUrl')) {
          setState(() {
            _instagramController.text = userData['instagramUrl'] ?? '';
          });
        }
        if (userData.containsKey('youtubeUrl')) {
          setState(() {
            _youtubeController.text = userData['youtubeUrl'] ?? '';
          });
        }

        final String dbProfilePic =
            userData['profileImageUrl'] ??
            'https://img.freepik.com/premium-vector/character-avatar-isolated_729149-194801.jpg?ga=GA1.1.620892737.1745985582&semt=ais_hybrid&w=740';
        if (dbProfilePic.isNotEmpty) {
          setState(() {
            profilePic = dbProfilePic;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error loading user data: $e');
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isDBPicChanged = true;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }

  // Upload image to Cloudinary
  Future<String> uploadImageToCloudinary(List<int> imageBytes) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload',
    );
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg'),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return jsonMap['secure_url'];
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  // Submit data to Firestore
  Future<void> _submitData() async {
    // if (_image == null || _userNameController.text.isEmpty) {
    if (_userNameController.text.isEmpty) {
      _showSnackBar('User Name cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isDBPicChanged) {
        // Compress image to reduce upload time
        List<int>? compressedBytes =
            await FlutterImageCompress.compressWithFile(
              _image!.path,
              minWidth: 800,
              minHeight: 800,
              quality: 85,
            );

        List<int> imageBytes = compressedBytes ?? await _image!.readAsBytes();

        // // Upload to Cloudinary
        String imageUrl = await uploadImageToCloudinary(imageBytes);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
              'name': _userNameController.text,
              'profileImageUrl': imageUrl,
              'facebookUrl': _facebookController.text,
              'instagramUrl': _instagramController.text,
              'youtubeUrl': _youtubeController.text,
            });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {
            'name': _userNameController.text,
            // 'profileImageUrl': profilePic,
            'facebookUrl': _facebookController.text,
            'instagramUrl': _instagramController.text,
            'youtubeUrl': _youtubeController.text,
          },
        );
      }
      _showSnackBar('Profile Updated Successfully');
      Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfile()));
    } catch (e) {
      _showSnackBar('Failed to save photo: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show snackbar for user feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child:
                          (_image == null && profilePic.isEmpty)
                              ? const CircularProgressIndicator()
                              : Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage:
                                        _image != null
                                            ? FileImage(_image!)
                                                as ImageProvider
                                            : NetworkImage(profilePic),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _facebookController,
                    decoration: InputDecoration(
                      labelText: 'Facebook Url',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      labelText: 'Instagram Url',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _youtubeController,
                    decoration: InputDecoration(
                      labelText: 'Youtube Url',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
