import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'camp_menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const CampMenuPage(),
    );
  }
}
