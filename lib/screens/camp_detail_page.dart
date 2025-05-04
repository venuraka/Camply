import 'package:flutter/material.dart';
import '../Components/WeatherInfo.dart';
import '../Controllers/OpenWeatherMap.dart';
import '../models/camp_model.dart';
import 'detail_tab.dart';
import 'location_tab.dart';
import 'nearby_tab.dart';
import 'review_tab.dart';

class CampDetailPage extends StatefulWidget {
  final CampSite campSite;

  const CampDetailPage({
    Key? key,
    required this.campSite,
  }) : super(key: key);

  @override
  State<CampDetailPage> createState() => _CampDetailPageState();
}

class _CampDetailPageState extends State<CampDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _currentDate = DateTime.now();
  double? temperature;
  String? description;
  String? icon;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final weatherData = await getWeatherDataFromLocationString(widget.campSite.location);
      setState(() {
        temperature = weatherData['main']['temp'];
        description = weatherData['weather'][0]['description'];
        icon = weatherData['weather'][0]['icon'];
      });
    } catch (e) {
      print('Weather fetch error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 450,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.campSite.imageUrl != null
                          ? Image.network(widget.campSite.imageUrl!, fit: BoxFit.cover)
                          : Image.asset('assets/images/default_camp.jpg', fit: BoxFit.cover),
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
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(210),
                  child: _buildCampInfoCard(),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Location'),
                  Tab(text: 'Near By'),
                  Tab(text: 'Review'),
                ],
              ),
              Expanded(
                child: TabBarView(
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show chat functionality
          },
          backgroundColor: const Color(0xFF2ECC71),
          child: const Icon(Icons.chat),
        ),
      ),
    );
  }

  Widget _buildCampInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              if (temperature != null && description != null)
                WeatherInfoCard(
                  temperature: temperature!,
                  description: description!,
                  icon: icon!,
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
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
                    color: index < 4 ? Colors.greenAccent : Colors.grey.shade300,
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
                child: const Text('Follow', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _getDayOfWeek(DateTime date) {
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}