import 'package:camply/screens/user_review.dart';
import 'package:flutter/material.dart';
import '../models/camp_model.dart';

class ReviewTab extends StatelessWidget {
  final CampSite campSite;

  const ReviewTab({
    Key? key,
    required this.campSite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Rating categories and their scores
    final Map<String, double> ratings = {
      'Accessibility': 7.7,
      'Cleanliness': 9.0,
      'Network Coverage': 4.3,
      'Wildlife Presence': 4.3,
      'Water Access': 9.0,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ratings section
          ...ratings.entries.map((entry) => _buildRatingItem(
            context,
            entry.key,
            entry.value,
          )),

          const SizedBox(height: 24),

          // Write a review button
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 16,
                ),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: score / 10,
                    minHeight: 16,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF2ECC71),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                score.toString(),
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
}