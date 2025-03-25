import 'package:flutter/material.dart';

class CreateCampSite extends StatefulWidget {
  const CreateCampSite({super.key});

  @override
  State<CreateCampSite> createState() => _CreateCampSiteState();
}

class _CreateCampSiteState extends State<CreateCampSite> {
  late TextEditingController campNameController = TextEditingController();
  late TextEditingController campDetailsController = TextEditingController();

  final List<String> amenities = [
    'Washroom',
    'Showers',
    'Tents',
    'Fire Pits',
    'BBQ Grills',
    'Electricity',
    'Parking'
  ];
  final List<String> selectedAmenities = [];

  void toggleAmenity(String amenity) {
    setState(() {
      if (selectedAmenities.contains(amenity)) {
        selectedAmenities.remove(amenity);
      } else {
        selectedAmenities.add(amenity);
      }
    });
  }

  void handleSubmit() {
    // Handle form submission logic
    print('Camp Name: ${campNameController.text}');
    print('Details: ${campDetailsController.text}');
    print('Selected Amenities: $selectedAmenities');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Camp Site"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 40, color: Colors.black54),
                        Text('Add Photo',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Destination",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: campNameController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26)),
                          focusedBorder: OutlineInputBorder(
                            // Border when focused
                            borderSide:
                                BorderSide(color: Colors.lightBlue, width: 2.5),
                          ),
                          hintText: 'Enter Name of Destination',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: campDetailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26)),
                          focusedBorder: OutlineInputBorder(
                            // Border when focused
                            borderSide:
                                BorderSide(color: Colors.lightBlue, width: 2.5),
                          ),
                          hintText: 'Enter details of the destination',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select your location',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(Icons.map, size: 40, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Property Amenities',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 10,
                        children: amenities.map((amenity) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: selectedAmenities.contains(amenity),
                                onChanged: (bool? value) {
                                  toggleAmenity(amenity);
                                },
                              ),
                              Text(amenity),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      iconAlignment: IconAlignment.end,
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Submit',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
