import 'package:camply/pages/camp_details_display.dart';
import 'package:camply/pages/chat_screen.dart';
import 'package:camply/pages/chat_test_camp_list.dart';
import 'package:camply/pages/chat_test_site_details.dart';
import 'package:camply/pages/create_camp_site.dart';
import 'package:camply/screens/add_experience_screen.dart';
import 'package:camply/screens/addphoto.dart';

import 'package:camply/screens/camp_detail_page.dart';
import 'package:camply/screens/camp_menu.dart';
import 'package:camply/screens/camper_experience_page.dart';
import 'package:camply/screens/create_camp_page.dart';
// import 'package:camply/screens/camp_detail_page.dart';
// import 'package:camply/screens/create_camp_page.dart';
import 'package:camply/pages/user_review.dart';
import 'package:camply/screens/detail_tab.dart';
import 'package:camply/screens/home.dart';
import 'package:camply/screens/location_tab.dart';

import 'package:camply/screens/nearby_tab.dart';
import 'package:camply/screens/register.dart';
import 'package:camply/screens/review_tab.dart';
import 'package:camply/screens/reviews.dart';
import 'package:camply/screens/user_review.dart';
import 'package:camply/screens/userprofile.dart';

// Lock Orientation
import 'package:flutter/services.dart';

// Ayeshi Login
import 'package:camply/services/auth_wrapper.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:camply/screens/login.dart';

// Push notifications
// import 'function/notification.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:camply/firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Function for notification handling
  // await setupFirebaseMessaging();

  // Facebook Auth Function
  await FacebookAuth.instance.autoLogAppEventsEnabled(true);

  // locked orientation on portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Only portrait up
  ]);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/authWrapper',
      routes: {
        // Login and Signup
        '/authWrapper': (context) => AuthWrapper(), // Ayeshi
        '/Register': (context) => RegistrationScreen(), // Ayeshi
        '/Login': (context) => LoginScreen(), // Ayeshi

        '/home': (context) => HomeScreen(), // Ravindu
        '/camperExperience':
            (context) => CamperProfileExperienceScreen(), // Hansi
        '/addExperience': (context) => AddExperienceScreen(), // Hansi
        '/addPhoto': (context) => AddPhoto(), // Adithya
        '/uesrProfile': (context) => UserProfile(), // Adithya
        '/reviews': (context) => ReviewPage(), // Manodya
        '/user_review_Akka': (context) => UserReviewAkka(), // Manodya
        '/user_review': (context) => UserReview(), // Senuri
        '/campDetailsDisplay': (context) => CampDetailsDisplay(), // Brian
        '/createCampSite': (context) => CreateCampSite(), // Brian
        '/Senuricampdetails': (context) => CampDetailPage(),
        '/Senuricreatecamp': (context) => CreateCampPage(),
        '/Detail': (context) => DetailTab(),
        '/Location': (context) => LocationTab(),
        '/Nearby': (context) => NearbyTab(),
        '/EditCourse': (context) => ReviewTab(),
        '/campMenu': (context) => CampMenu(),

        // Chat Testing
        '/chat':
            (context) => ChatScreen(siteName: 'site-name', siteId: '000000'),
        '/çhatTestSiteDetail':
            (context) =>
                ChatTestSiteDetails(siteName: 'site-name', siteId: '000000'),
        '/çhatTestSiteList': (context) => ChatTestCampList(),

        //----------------------------------------------------
        // '/Register': (context) => RegistrationScreen(),
        // '/Login': (context) => LoginScreen(),
        // '/Senuricampdetails': (context) => CampDetailPage(campSite: ,),
        // '/CreateCampPage': (context) => CreateCampPage(),
        // '/Detail': (context) => DetailTab(campSite: ,),
        // '/Location': (context) => LocationTab(campSite: ,),
        // '/Nearby': (context) => NearbyTab(campSite: ,),
        // '/EditCourse': (context) => ReviewTab(campSite: ,),
      },
    ),
  );
}
