import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Services/Database.dart';
import 'create_camp_page.dart';
import 'camp_detail_page.dart';
import 'camp_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
      home: const HomePage(),
      routes: {
        '/create_camp': (context) => const CreateCampPage(),
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
  final DatabaseMethods db = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camping App'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final newCampSite =
              await Navigator.pushNamed(context, '/create_camp');
              // Firebase handles the update, no need to update local list.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text(
              'Create Camp Site',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: StreamBuilder<List<CampSite>>(
              stream: db.getCamps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No camp sites created yet. Tap the button above to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final camps = snapshot.data!;
                return ListView.builder(
                  itemCount: camps.length,
                  itemBuilder: (context, index) {
                    final camp = camps[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(camp.name),
                        subtitle: Text(camp.location),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CampDetailPage(campSite: camp),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}