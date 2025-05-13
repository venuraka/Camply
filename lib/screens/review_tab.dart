// import 'package:camply/screens/user_review.dart';
// import 'package:flutter/material.dart';
// import '../models/camp_model.dart';

// class ReviewTab extends StatelessWidget {
//   final CampSite campSite;

//   const ReviewTab({
//     Key? key,
//     required this.campSite,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Rating categories and their scores
//     final Map<String, double> ratings = {
//       'Accessibility': 7.7,
//       'Cleanliness': 9.0,
//       'Network Coverage': 4.3,
//       'Wildlife Presence': 4.3,
//       'Water Access': 9.0,
//     };

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Ratings section
//           ...ratings.entries.map((entry) => _buildRatingItem(
//             context,
//             entry.key,
//             entry.value,
//           )),

//           const SizedBox(height: 24),

//           // Write a review button
//           Align(
//             alignment: Alignment.center,
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => UserReview()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2ECC71),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'Write a Review',
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRatingItem(BuildContext context, String title, double score) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 flex: 7,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: score / 10,
//                     minHeight: 16,
//                     backgroundColor: Colors.grey.shade300,
//                     color: const Color(0xFF2ECC71),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Text(
//                 score.toString(),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:camply/screens/rating_component.dart';
import 'package:camply/screens/user_review.dart';
import 'package:flutter/material.dart';
import '../models/camp_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewTab extends StatelessWidget {
  final CampSite campSite;

  const ReviewTab({Key? key, required this.campSite}) : super(key: key);

  Future<Map<String, double>> fetchAndCalculateAverages() async {
    CollectionReference reviews = FirebaseFirestore.instance.collection(
      'reviews',
    );

    try {
      QuerySnapshot snapshot = await reviews.get();
      final comments = snapshot.docs;

      List<Map<String, dynamic>> values =
          comments.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return calculateAverage(values);
    } catch (e) {
      print('Error fetching reviews: $e');
      return {
        'networkAverage': 0,
        'wildlifeAverage': 0,
        'waterAverage': 0,
        'accessibilityAverage': 0,
        'cleanlinessAverage': 0,
      };
    }
  }

  Map<String, double> calculateAverage(List<Map<String, dynamic>> values) {
    double networkTotal = 0;
    double wildlifeTotal = 0;
    double waterTotal = 0;
    double accessibilityTotal = 0;
    double cleanlinessTotal = 0;

    int count = values.length;
    if (count == 0) {
      return {
        'networkAverage': 0,
        'wildlifeAverage': 0,
        'waterAverage': 0,
        'accessibilityAverage': 0,
        'cleanlinessAverage': 0,
      };
    }

    for (var value in values) {
      networkTotal += (value['networkCoverage'] ?? 0).toDouble();
      wildlifeTotal += (value['wildlifePresence'] ?? 0).toDouble();
      waterTotal += (value['waterAccess'] ?? 0).toDouble();
      accessibilityTotal += (value['accessibility'] ?? 0).toDouble();
      cleanlinessTotal += (value['cleanliness'] ?? 0).toDouble();
    }

    double networkAverage = networkTotal / count;
    double wildlifeAverage = wildlifeTotal / count;
    double waterAverage = waterTotal / count;
    double accessibilityAverage = accessibilityTotal / count;
    double cleanlinessAverage = cleanlinessTotal / count;

    double totalAverage =
        networkAverage +
        wildlifeAverage +
        waterAverage +
        accessibilityAverage +
        cleanlinessAverage;

    double overalAverage = totalAverage / 5;

    return {
      'networkAverage': networkAverage,
      'wildlifeAverage': wildlifeAverage,
      'waterAverage': waterAverage,
      'accessibilityAverage': accessibilityAverage,
      'cleanlinessAverage': cleanlinessAverage,
      'overallAverage': overalAverage,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFF2ECC71),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF2ECC71),
              tabs: [Tab(text: 'Reviews'), Tab(text: 'Comments')],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                FutureBuilder<Map<String, double>>(
                  future: fetchAndCalculateAverages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading reviews.'),
                      );
                    }

                    final averages = snapshot.data!;
                    return _buildReviewContent(context, averages);
                  },
                ),
                _buildCommentsContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent(
    BuildContext context,
    Map<String, double> averages,
  ) {
    // Map Firestore keys to display labels
    final Map<String, String> displayLabels = {
      'accessibilityAverage': 'Accessibility',
      'cleanlinessAverage': 'Cleanliness',
      'networkAverage': 'Network Coverage',
      'wildlifeAverage': 'Wildlife Presence',
      'waterAverage': 'Water Access',
    };

    final overallRating = averages['overallAverage'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...averages.entries.map(
            (entry) => _buildRatingItem(
              context,
              displayLabels[entry.key] ?? entry.key,
              entry.value,
            ),
          ),
          const SizedBox(height: 24),
          RatingComponent(rating: overallRating),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserReview()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              child: const Text(
                'Write a Review',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(BuildContext context, String title, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (score / 10).clamp(0.0, 1.0),
                    minHeight: 16,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF2ECC71),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsContent() {
    CollectionReference reviews = FirebaseFirestore.instance.collection(
      'reviews',
    );

    return StreamBuilder<QuerySnapshot>(
      stream: reviews.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No comments yet.'));
        }

        final comments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            var data = comments[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['comment'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "- ${data['user'] ?? 'Anonymous'}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
