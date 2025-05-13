import 'package:camply/screens/bookmarks_screen.dart';

import 'package:camply/screens/camp_menu_page.dart';

import 'package:camply/screens/home.dart';
import 'package:camply/screens/notifications_screen.dart';

import 'package:camply/screens/register.dart';
import 'package:camply/screens/user_review.dart';

// Lock Orientation
import 'package:flutter/services.dart';

// Chat
import 'package:camply/pages/chat_screen.dart';

// Ayeshi Login
import 'package:camply/services/auth_wrapper.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:camply/screens/login.dart';

// Adithya Hansi Profile & Experience
import 'package:camply/screens/userprofile.dart';
import 'package:camply/screens/addphoto.dart';

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
        // User Profile and Experience
        '/addPhoto': (context) => AddPhoto(), // Adithya
        '/userProfile': (context) => UserProfile(), // Adithya

        '/user_review': (context) => UserReview(), // Senuri
        '/CampMenuPage': (context) => CampMenuPage(), //Senuri,venuraka
        // Chat Testing
        '/chat':
            (context) => ChatScreen(siteName: 'site-name', siteId: '000000'),

        '/bookmarks': (context) => BookmarksScreen(),

        '/notifications': (context) => NotificationsScreen(),
      },
    ),
  );
}
