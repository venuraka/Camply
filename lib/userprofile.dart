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
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your image
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       const SizedBox(height: 10),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'Mark Sepperd',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text('Followers\n12k', style: TextStyle(fontSize: 14)),
                          Text('Following\n34k', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 100),
                            width: 130,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {
                                // Your logic when 'Follow' button is pressed
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
                        crossAxisCount: 1,
                        mainAxisSpacing: 12,
                        children: List.generate(6, (index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.greenAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage('assets/profile.jpg'),
                                  ),
                                  title: Text(
                                    'Zack Night',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Yosemite Basecamp'),
                                ),
                                ClipRRect(
                                  child: Image.asset(
                                    'assets/photo.jpeg',
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Row(
                                        children: [
                                          Icon(Icons.favorite_border, color: Colors.green),
                                          SizedBox(width: 12),
                                          Icon(Icons.chat_bubble_outline, color: Colors.green),
                                        ],
                                      ),
                                      Icon(Icons.bookmark_border, color: Colors.green),
                                    ],
                                  ),
                                )
                              ],
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
