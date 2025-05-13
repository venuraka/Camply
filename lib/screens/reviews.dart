import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'user_review.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReviewPage(),
  ));
}

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: const Color(0xFF2ECC71),
        title: Text("Campsite Details", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildDetailsSection(context),
          ],
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

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 10),
          _buildReviewRow(context),
          SizedBox(height: 15),
          _buildTabs(),
          SizedBox(height: 15),
          Divider(),
          _buildReviewSection("Accessibility", 7.7, 0.77),
          _buildReviewSection("Cleanliness", 9.0, 0.9),
          _buildReviewSection("Network Coverage", 4.3, 0.43),
          _buildReviewSection("Wildlife Presence", 4.3, 0.43),
          _buildReviewSection("Water Access", 9.0, 0.9),
          SizedBox(height: 20),
          _buildWriteReviewButton(context),
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
        Text("7.7", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Spacer(),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
           backgroundColor: const Color(0xFF2ECC71),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text("Follow", style: TextStyle(color: Colors.white)),
        ),
        SizedBox(width: 10),
        _buildCircularIconButton(Icons.share, () {}),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("Location", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("Near By", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("Review", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }

  Widget _buildReviewSection(String title, double rating, double percent) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 12,
                  percent: percent,
                  backgroundColor: Colors.grey[300]!,
                  progressColor: Colors.green,
                  barRadius: Radius.circular(10),
                ),
              ),
              SizedBox(width: 10),
              Text(rating.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserReview()), 
          );
        },
        //         onPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) {
        //         return UserReview();
        //       },
        //     ),
        //   );
        // },
        
        // onPressed: () {
        //   Navigator.pop(context);
        // },
        style: ElevatedButton.styleFrom(
         backgroundColor: const Color(0xFF2ECC71),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text("Write a Review", style: TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.all(8),
      ),
    );
  }
}
