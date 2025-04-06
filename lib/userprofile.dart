import 'package:flutter/material.dart';
import 'addphoto.dart'; // Import addphoto.dart here

class userprofile extends StatefulWidget {
  const userprofile({super.key});

  @override
  State<userprofile> createState() => _userprofileState();
}

class _userprofileState extends State<userprofile> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text('Camper', style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.menu, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your image
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 50, right: 20),
                            child: Text(
                              'Mark Sepperd',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const CircleAvatar(radius: 6, backgroundColor: Colors.brown),
                          const SizedBox(width: 4),
                          const CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                          const SizedBox(width: 4),
                          const CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Followers\n', style: TextStyle(fontSize: 14)),
                                TextSpan(text: '12k', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Following\n', style: TextStyle(fontSize: 14)),
                                TextSpan(text: '34k', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 80), 
                            width: 130,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {
                                print('Follow button pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'Photos'),
                Tab(text: 'Experience'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Stack(
                  children: [
                    GridView.count(
                      padding: const EdgeInsets.all(10),
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: List.generate(6, (index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/photo.jpeg'), // Replace with your photo asset
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: const Color.fromARGB(255, 3, 159, 47),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddPhoto()),
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                const Center(
                  child: Text('Experience content goes here'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
