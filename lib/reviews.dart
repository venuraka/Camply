import 'package:camply/review_details.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_review.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Campsite Details", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageSection(), _buildDetailsSection(context)],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 40, // 👈 Reduced height
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserReview()),
            );
          },
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ), // You can tweak radius here
          ),
          icon: Icon(Icons.rate_review, color: Colors.white, size: 18),
          label: Text(
            "Write a Review",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/campsite.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatings() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final docs = snapshot.data!.docs;

        List<double> accessibility = [];
        List<double> waterAccess = [];
        List<double> network = [];
        List<double> cleanliness = [];
        List<double> wildlife = [];

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (data['accessibility'] != null)
            accessibility.add(data['accessibility'].toDouble());
          if (data['waterAccess'] != null)
            waterAccess.add(data['waterAccess'].toDouble());
          if (data['network'] != null) network.add(data['network'].toDouble());
          if (data['cleanliness'] != null)
            cleanliness.add(data['cleanliness'].toDouble());
          if (data['wildlife'] != null)
            wildlife.add(data['wildlife'].toDouble());
        }

        double calcAverage(List<double> values) {
          if (values.isEmpty) return 0;
          return values.reduce((a, b) => a + b) / values.length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSingleAspect("Accessibility", calcAverage(accessibility)),
            _buildSingleAspect("Cleanliness", calcAverage(cleanliness)),
            _buildSingleAspect("Network Coverage", calcAverage(network)),
            _buildSingleAspect("Wildlife Presence", calcAverage(wildlife)),
            _buildSingleAspect("Water Access", calcAverage(waterAccess)),
            SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildSingleAspect(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(fontSize: 14))),
          Expanded(
            flex: 6,
            child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: (value / 10).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              progressColor: Colors.green,
              barRadius: Radius.circular(10),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
          SizedBox(width: 6),
          Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Yosemite Basecamp",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "Miriswatta-Gampaha",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReviewRow(BuildContext context) {
    return Row(
      children: [
        Row(
          children: List.generate(
            4,
            (index) => Icon(Icons.star, color: Colors.green, size: 20),
          )..add(Icon(Icons.star_half, color: Colors.green, size: 20)),
        ),
        SizedBox(width: 10),
        Text(
          "7.7",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text("Follow", style: TextStyle(color: Colors.white)),
        ),
        SizedBox(width: 10),
        //_buildCircularIconButton(Icons.share, () {}),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          "Details",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          "Location",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          "Near By",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          "Reviews",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 10),
          _buildReviewRow(context),
          SizedBox(height: 15),
          _buildTabs(),
           SizedBox(height: 8),
          Divider(
  color: Colors.black,
  thickness: 1,
  height: 0,
),
          SizedBox(height: 20),
          _buildAspectRatings(), 
          _buildTheme(),
          SizedBox(height: 10),
          _buildFirebaseReviews(), 
        ],
      ),
    );
  }

  Widget _buildRatingBar(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ${value.toStringAsFixed(1)}",
          style: TextStyle(fontSize: 14),
        ),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: (value / 10).clamp(0.0, 1.0), // assuming max rating is 10
          backgroundColor: Colors.grey.shade300,
          progressColor: Colors.green,
          barRadius: Radius.circular(10),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTheme() {
    return Row(
      children: [
        Text(
          "User Reviews",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFirebaseReviews() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      var docs = snapshot.data!.docs;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data()!;
          final reviewId = doc.id;
          DateTime reviewDate = data['timestamp'].toDate();

          final profilePhotoUrl = data['profilePhotoUrl'];
          final imageProvider =
              (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                  ? NetworkImage(profilePhotoUrl)
                  : AssetImage('images/profile.jpg') as ImageProvider;

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('reviews')
                .doc(reviewId)
                .collection('replies')
                .get(),
            builder: (context, replySnapshot) {
              int replyCount = 0;
              if (replySnapshot.hasData) {
                replyCount = replySnapshot.data!.docs.length;
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewDetailPage(reviewId: reviewId),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: imageProvider,
                            ),
                            SizedBox(width: 10),
                            Text(
                              data['username'] ?? "Anonymous",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          data['comment'] ?? "No comment",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$replyCount Replies",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              "Posted on ${reviewDate.day}/${reviewDate.month}/${reviewDate.year}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}


  // Widget _buildWriteReviewButton(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: ElevatedButton(
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const UserReview()),
  //         );
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Colors.green,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       ),
  //       child: Text(
  //         "Write a Review",
  //         style: TextStyle(color: Colors.white, fontSize: 14),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
  //   return Container(
  //     width: 35,
  //     height: 35,
  //     decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
  //     child: IconButton(
  //       icon: Icon(icon, color: Colors.white, size: 20),
  //       onPressed: onPressed,
  //       padding: EdgeInsets.all(8),
  //     ),
  //   );
  // }
}
