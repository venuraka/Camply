import 'package:flutter/material.dart';
import '../models/camp_model.dart';
import 'detail_tab.dart';
import 'location_tab.dart';
import 'nearby_tab.dart';
import 'review_tab.dart';

class CampDetailPage extends StatefulWidget {
  final CampSite campSite;

  const CampDetailPage({Key? key, required this.campSite}) : super(key: key);

  @override
  State<CampDetailPage> createState() => _CampDetailPageState();
}

class _CampDetailPageState extends State<CampDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with image and camp info
          _buildHeader(),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Location'),
              Tab(text: 'Near By'),
              Tab(text: 'Review'),
            ],
            indicatorColor: Colors.black,
            unselectedLabelColor: Colors.grey,
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DetailTab(campSite: widget.campSite),
                LocationTab(campSite: widget.campSite),
                NearbyTab(campSite: widget.campSite),
                ReviewTab(campSite: widget.campSite),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show chat functionality
        },
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Camp image or placeholder
        Container(
          height: 250,
          width: double.infinity,
          color: Colors.grey.shade300,
          child:
              widget.campSite.imageUrl != null
                  ? Image.network(widget.campSite.imageUrl!, fit: BoxFit.cover)
                  : Image.asset(
                    'assets/images/default_camp.jpg',
                    fit: BoxFit.cover,
                  ),
        ),

        // Back button
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // Camp info card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and weather info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getDayOfWeek(_currentDate)}\n${_getFormattedDate(_currentDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.cloud, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('22 °C', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Camp name and location
                Text(
                  widget.campSite.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.campSite.location,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),

                // Ratings and actions
                Row(
                  children: [
                    const Text('reviews'),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color:
                              index < 4
                                  ? Colors.greenAccent
                                  : Colors.grey.shade300,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('7.7'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDayOfWeek(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
