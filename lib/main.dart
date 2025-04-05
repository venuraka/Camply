import 'package:camply/screens/camp_detail_page.dart';
import 'package:camply/screens/create_camp_page.dart';
import 'package:camply/screens/detail_tab.dart';
import 'package:camply/screens/location_tab.dart';
import 'package:camply/screens/login.dart';
import 'package:camply/screens/nearby_tab.dart';
import 'package:camply/screens/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    initialRoute: '/Login',
    routes: {
      '/Register': (context) => RegistrationScreen(),
      '/Login': (context) => LoginScreen(),
      // '/campdetails': (context) => CampDetailPage(),
      '/createcamp': (context) => CreateCampPage(),
       // '/Detail': (context) => DetailTab(),
     // '/Location': (context) => LocationTab(),
     //  '/Nearby':(context) => NearbyTab(),
     // '/EditCourse':(context) => ReviewTab(),
    },
  ));
}
