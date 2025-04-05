import 'package:flutter/material.dart';
import '../models/camp_model.dart';

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
              Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_photo_alternate_outlined, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get selected amenities
      final List<String> amenities =
          _selectedAmenities.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

      // Create a new camp site object
      final newCampSite = CampSite(
        name: _nameController.text,
        location: _locationController.text,
        details: _detailsController.text,
        amenities: amenities,
        nearbyPlaces: CampSite.getDefaultNearbyPlaces(),
        imageUrl: _imageUrl,
      );

      // Return the new camp site to the previous screen
      Navigator.pop(context, newCampSite);
    }
  }
}
