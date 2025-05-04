import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserReview(),
  ));
}

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

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle form submission
  void _submitReview() {
    print("Accessibility: $accessibility");
    print("Cleanliness: $cleanliness");
    print("Network Coverage: $networkCoverage");
    print("Wildlife Presence: $wildlifePresence");
    print("Water Access: $waterAccess");
    print("Status: $selectedStatus");
    print("Image Selected: ${_selectedImage != null ? "Yes" : "No"}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: const Color(0xFF2ECC71),
        title: Text("User Review Section", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload 
              GestureDetector(
                onTap: _pickImage, 
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage == null
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
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              Text("Current Status", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: SizedBox(),
                  value: selectedStatus,
                  items: ["Select", "Open", "Closed", "Under Maintenance"]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),

              _buildSlider("Accessibility", accessibility, (value) {
                setState(() {
                  accessibility = value;
                });
              }),
              _buildSlider("Cleanliness", cleanliness, (value) {
                setState(() {
                  cleanliness = value;
                });
              }),
              _buildSlider("Network Coverage", networkCoverage, (value) {
                setState(() {
                  networkCoverage = value;
                });
              }),
              _buildSlider("Wildlife Presence", wildlifePresence, (value) {
                setState(() {
                  wildlifePresence = value;
                });
              }),
              _buildSlider("Water Access", waterAccess, (value) {
                setState(() {
                  waterAccess = value;
                });
              }),

              SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF2ECC71),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _submitReview, // Calls submit function
                  child: Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
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
