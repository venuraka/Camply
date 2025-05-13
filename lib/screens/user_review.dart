import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

const String CLOUDINARY_CLOUD_NAME = 'dvoesribg';
const String CLOUDINARY_UPLOAD_PRESET = 'flutter_upload';

class UserReview extends StatefulWidget {
  const UserReview({super.key});

  @override
  UserReviewState createState() => UserReviewState();
}

class UserReviewState extends State<UserReview> {
  double accessibility = 0;
  double cleanliness = 0;
  double networkCoverage = 0;
  double wildlifePresence = 0;
  double waterAccess = 0;
  String selectedStatus = "Select";
  TextEditingController commentController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
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

  // Show snackbar for user feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Submit data to Firestore
  Future<void> _submitData() async {
    if (commentController.text.isEmpty || selectedStatus == "Select") {
      _showSnackBar('Please select a Status and add a Comment');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('name')) {
        throw Exception("User Name not found.");
      }

      final username = userData['name'];

      if (_image != null) {
        // Compress image to reduce upload time
        List<int>? compressedBytes =
            await FlutterImageCompress.compressWithFile(
              _image!.path,
              minWidth: 800,
              minHeight: 800,
              quality: 85,
            );

        List<int> imageBytes = compressedBytes ?? await _image!.readAsBytes();

        // Upload to Cloudinary
        String imageUrl = await uploadImageToCloudinary(imageBytes);

        final newReviewRef =
            FirebaseFirestore.instance.collection('reviews').doc();

        await newReviewRef.set({
          'id': newReviewRef.id,
          'userId': userId,
          'userName': username,
          'imageUrl': imageUrl ?? null,
          'accessibility': accessibility,
          'cleanliness': cleanliness,
          'networkCoverage': networkCoverage,
          'wildlifePresence': wildlifePresence,
          'waterAccess': waterAccess,
          'status': selectedStatus,
          'comment': commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        final newReviewRef =
            FirebaseFirestore.instance.collection('reviews').doc();

        await newReviewRef.set({
          'id': newReviewRef.id,
          'userId': userId,
          'userName': username,
          'imageUrl': null,
          'accessibility': accessibility,
          'cleanliness': cleanliness,
          'networkCoverage': networkCoverage,
          'wildlifePresence': wildlifePresence,
          'waterAccess': waterAccess,
          'status': selectedStatus,
          'comment': commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      _showSnackBar('Review added successfully');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to add review: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        title: Text("Add your Review", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    _image == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Add Photo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Add Your Comment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),

            Text(
              "Current Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              underline: SizedBox(),
              items:
                  ["Select", "Open", "Closed", "Under Maintenance"].map((
                    status,
                  ) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) => setState(() => selectedStatus = value!),
            ),
            SizedBox(height: 20),

            _buildSlider(
              "Accessibility",
              accessibility,
              (val) => setState(() => accessibility = val),
            ),
            _buildSlider(
              "Cleanliness",
              cleanliness,
              (val) => setState(() => cleanliness = val),
            ),
            _buildSlider(
              "Network Coverage",
              networkCoverage,
              (val) => setState(() => networkCoverage = val),
            ),
            _buildSlider(
              "Wildlife Presence",
              wildlifePresence,
              (val) => setState(() => wildlifePresence = val),
            ),
            _buildSlider(
              "Water Access",
              waterAccess,
              (val) => setState(() => waterAccess = val),
            ),

            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "Submit",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: const Color(0xFF2ECC71),
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
