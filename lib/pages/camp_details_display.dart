import 'package:camply/pages/create_camp_site.dart';
import 'package:flutter/material.dart';

class CampDetailsDisplay extends StatefulWidget {
  const CampDetailsDisplay({super.key});

  @override
  State<CampDetailsDisplay> createState() => _CampDetailsDisplayState();
}

class _CampDetailsDisplayState extends State<CampDetailsDisplay> {
  String selectedTab = 'Details';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  "https://img.freepik.com/free-photo/silhouette-happy-man-with-holding-coffee-cup-stay-near-tent-around-mountains_1150-9145.jpg?ga=GA1.1.1735124578.1741663265&semt=ais_hybrid",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Set color to transparent
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sunday',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'May 19, 2024',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              '22°C',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yosemite Basecamp',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Miriswatta - Gampaha',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // Row containing stars, rating, Follow button, and Share icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Star Ratings + 7.7 Rating
                      Row(
                        children: [
                          ...List.generate(
                            4,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                          const Icon(
                            Icons.star_half,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '7.7',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Follow Button & Share Icon
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8), // Space between buttons
                          IconButton(
                            onPressed: () {
                              // TODO: Implement Share functionality
                            },
                            icon: const Icon(Icons.share, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['Details', 'Location', 'Near By', 'Review'].map((
                        tab,
                      ) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = tab;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                tab,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedTab == tab
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              if (selectedTab == tab)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 2,
                                  width: 40,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed euismod tempor enim, in vehicula nisi hendrerit ac. '
                    'Pellentesque habitant morbi tristique senectus et netus et malesuada fames.'
                    'Pellentesque habitant morbi tristique senectus et netus et malesuada fames.'
                    'Pellentesque habitant morbi tristique senectus et netus et malesuada fames.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Property Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.wc_sharp, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Washroom'),
                      SizedBox(width: 16),
                      Icon(Icons.electric_bolt, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Electricity'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateCampSite()));
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
