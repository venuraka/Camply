import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'create_camp_page.dart';
import 'camp_detail_page.dart';
import 'camp_model.dart';
import 'camp_menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camping App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2ECC71),
          foregroundColor: Colors.white,
        ),
      ),
      home: const CreateCampPage(), // Set CreateCampPage as the home page
      routes: {
        '/create_camp': (context) => const CreateCampPage(),
        '/camp_menu': (context) => const CampMenuPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<CampSite> campSites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camping App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final newCampSite = await Navigator.pushNamed(
                  context,
                  '/create_camp',
                );
                if (newCampSite != null && newCampSite is CampSite) {
                  setState(() {
                    campSites.add(newCampSite);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Create Camp Site',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            if (campSites.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: campSites.length,
                  itemBuilder: (context, index) {
                    final camp = campSites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(camp.name),
                        subtitle: Text(camp.location),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CampDetailPage(campSite: camp),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            if (campSites.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No camp sites created yet. Tap the button above to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
