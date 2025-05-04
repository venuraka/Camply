import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Cloudinary configuration (replace with your actual values)
const String CLOUDINARY_CLOUD_NAME = 'dvoesribg';
const String CLOUDINARY_UPLOAD_PRESET = 'flutter_upload';

class AddPhoto extends StatefulWidget {
  const AddPhoto({super.key});

  @override
  State<AddPhoto> createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  File? _image;
  final TextEditingController _locationController = TextEditingController();
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

  // Get current location
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission is denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _locationController.text =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
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
    if (_image == null || _locationController.text.isEmpty) {
      _showSnackBar('Please select a photo and enter a location');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Compress image to reduce upload time
      List<int>? compressedBytes = await FlutterImageCompress.compressWithFile(
        _image!.path,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
      );

      List<int> imageBytes = compressedBytes ?? await _image!.readAsBytes();

      // Upload to Cloudinary
      String imageUrl = await uploadImageToCloudinary(imageBytes);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(userId)
          .collection('user_posts')
          .add({
            'imageUrl': imageUrl,
            'location': _locationController.text,
            'timestamp': FieldValue.serverTimestamp(),
            'likes': 0,
            'comments': 0,
          });

      // Save to Firestore
      // await FirebaseFirestore.instance.collection('photos').add({
      //   'imageUrl': imageUrl,
      //   'location': _locationController.text,
      //   'timestamp': FieldValue.serverTimestamp(),
      //   'likes': 0,
      //   'comments': 0,
      // });

      _showSnackBar('Photo saved successfully');
      Navigator.pop(context);
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
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insert Photo"),
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
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          _image != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Tag Location',
                      border: const OutlineInputBorder(),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: _getLocation,
                      ),
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
