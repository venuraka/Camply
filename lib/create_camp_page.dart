import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

const String cloudinaryUploadUrl =
    'https://api.cloudinary.com/v1_1/dzf4mceyk/image/upload';
const String uploadPreset = 'campsite';

class CreateCampPage extends StatefulWidget {
  const CreateCampPage({Key? key}) : super(key: key);

  @override
  State<CreateCampPage> createState() => _CreateCampPageState();
}

class _CreateCampPageState extends State<CreateCampPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _imageUrl;

  final Map<String, bool> _selectedAmenities = {
    'Washroom': false,
    'Showers': false,
    'Tents': false,
    'Fire Pits': false,
    'BBQ Grills': false,
    'Parking': false,
    'Electricity': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse(cloudinaryUploadUrl);
      final response = await http.post(
        uri,
        body: {
          'file': 'data:image/png;base64,$base64Image',
          'upload_preset': uploadPreset,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _imageUrl = data['secure_url'];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Camp Site'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Photo Container
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    image:
                        _imageUrl != null
                            ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      _imageUrl == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                          : null,
                ),
              ),

              const SizedBox(height: 20),

              // Name Field
              Text('Name', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Field
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details Field
              Text('Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Property Amenities
              Text(
                'Property Amenities',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    _selectedAmenities.entries.map((entry) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: entry.value,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedAmenities[entry.key] =
                                    newValue ?? false;
                              });
                            },
                          ),
                          Text(entry.key),
                        ],
                      );
                    }).toList(),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get selected amenities
      final List<String> amenities =
          _selectedAmenities.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

      // Create a new camp site object
      final newCampSite = {
        'name': _nameController.text,
        'location': _locationController.text,
        'details': _detailsController.text,
        'amenities': amenities,
        'imageUrl': _imageUrl,
      };

      try {
        // Save to Firestore collection 'campsites'
        await FirebaseFirestore.instance
            .collection('campsites')
            .add(newCampSite);

        // Navigate to camp_menu_page.dart
        Navigator.pushReplacementNamed(context, '/camp_menu');
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save data: $e')));
      }
    }
  }
}
