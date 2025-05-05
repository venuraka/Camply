import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  File? _selectedImage;
  TextEditingController commentController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReview() async {
    String? imageUrl;
    if (_selectedImage != null) {
      final ref = FirebaseStorage.instance.ref().child('review_images/${DateTime.now()}.jpg');
      await ref.putFile(_selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('reviews').add({
      'accessibility': accessibility,
      'cleanliness': cleanliness,
      'networkCoverage': networkCoverage,
      'wildlifePresence': wildlifePresence,
      'waterAccess': waterAccess,
      'status': selectedStatus,
      'comment': commentController.text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
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
                // child: _selectedImage == null
                //     ? Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(Icons.add_photo_alternate, size: 50, color: Colors.black54),
                //           SizedBox(height: 5),
                //           Text("Add Photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                //         ],
                //       )
                //     : ClipRRect(
                //         borderRadius: BorderRadius.circular(12),
                //         child: Image.file(_selectedImage!, width: double.infinity, height: 150, fit: BoxFit.cover),
                //       ),
                child: (_selectedImage == null || !_selectedImage!.existsSync())
    ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 50, color: Colors.black54),
          SizedBox(height: 5),
          Text("Add Photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      )
    : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),

              ),
            ),
            SizedBox(height: 20),

            Text("Add Your Comment", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),

            Text("Current Status", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              underline: SizedBox(),
              items: ["Select", "Open", "Closed", "Under Maintenance"].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) => setState(() => selectedStatus = value!),
            ),
            SizedBox(height: 20),

            _buildSlider("Accessibility", accessibility, (val) => setState(() => accessibility = val)),
            _buildSlider("Cleanliness", cleanliness, (val) => setState(() => cleanliness = val)),
            _buildSlider("Network Coverage", networkCoverage, (val) => setState(() => networkCoverage = val)),
            _buildSlider("Wildlife Presence", wildlifePresence, (val) => setState(() => wildlifePresence = val)),
            _buildSlider("Water Access", waterAccess, (val) => setState(() => waterAccess = val)),

            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white)),
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
          activeColor: Colors.green,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
