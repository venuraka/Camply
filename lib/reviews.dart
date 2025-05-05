import 'package:camply/review_details.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_review.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserReview()),
            );
          },
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(Icons.rate_review, color: Colors.white, size: 18),
          label: Text("Write a Review", style: TextStyle(fontSize: 12)),
        ),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _buildHeaderImage(),
            _buildInfoCard(),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: "Details"),
                Tab(text: "Location"),
                Tab(text: "Near By"),
                Tab(text: "Review"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildLocationTab(),
                  _buildNearbyTab(),
                  _buildReviewTab(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        Container(
          height: 230,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/campsite.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tuesday", style: TextStyle(fontSize: 14)),
          Text("Apr 29, 2025", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Whispering Pines", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("31.94°C - Few clouds", style: TextStyle(fontSize: 12)),
                  Icon(Icons.cloud, size: 16, color: Colors.orange),
                ],
              )
            ],
          ),
          SizedBox(height: 4),
          Text("Latitude: 7.0709718, Longitude: 80.0177035", style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: List.generate(4, (_) => Icon(Icons.star, color: Colors.green, size: 18))
                ..add(Icon(Icons.star_half, color: Colors.green, size: 18)),
              ),
              SizedBox(width: 8),
              Text("7.7", style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: StadiumBorder()),
                child: Text("Follow"),
              ),
              SizedBox(width: 10),
              Icon(Icons.share, color: Colors.green),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Center(child: Text("details"));
  }

  Widget _buildLocationTab() {
    return Center(child: Text("Location"));
  }

  Widget _buildNearbyTab() {
    return Center(child: Text("Nearby"));
  }

  Widget _buildReviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAspectRatings(),
          SizedBox(height: 16),
          _buildFirebaseReviews(),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildAspectRatings() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        List<double> accessibility = [], waterAccess = [], network = [], cleanliness = [], wildlife = [];

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['accessibility'] != null) accessibility.add(data['accessibility'].toDouble());
          if (data['waterAccess'] != null) waterAccess.add(data['waterAccess'].toDouble());
          if (data['network'] != null) network.add(data['network'].toDouble());
          if (data['cleanliness'] != null) cleanliness.add(data['cleanliness'].toDouble());
          if (data['wildlife'] != null) wildlife.add(data['wildlife'].toDouble());
        }

        double calcAvg(List<double> vals) => vals.isEmpty ? 0 : vals.reduce((a, b) => a + b) / vals.length;

        return Column(
          children: [
            _buildSingleAspect("Accessibility", calcAvg(accessibility)),
            _buildSingleAspect("Cleanliness", calcAvg(cleanliness)),
            _buildSingleAspect("Network Coverage", calcAvg(network)),
            _buildSingleAspect("Wildlife Presence", calcAvg(wildlife)),
            _buildSingleAspect("Water Access", calcAvg(waterAccess)),
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
            ),
          ),
          SizedBox(width: 6),
          Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 14)),
        ],
      ),
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
            final imageProvider = (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                ? NetworkImage(profilePhotoUrl)
                : AssetImage('images/profile.jpg') as ImageProvider;

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(reviewId)
                  .collection('replies')
                  .get(),
              builder: (context, replySnapshot) {
                int replyCount = replySnapshot.hasData ? replySnapshot.data!.docs.length : 0;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReviewDetailPage(reviewId: reviewId)),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 18, backgroundImage: imageProvider),
                              SizedBox(width: 10),
                              Text(data['username'] ?? "Anonymous", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(data['comment'] ?? "No comment", maxLines: 3, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("$replyCount Replies", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text("Posted on ${reviewDate.day}/${reviewDate.month}/${reviewDate.year}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
}
