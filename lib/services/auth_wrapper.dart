import 'package:camply/pages/chat_test_camp_list.dart';
import 'package:camply/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Add loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
          // return const ChatTestCampList();
        }
        // If the user is not logged in
        else {
          return const LoginScreen();
        }
      },
    );
  }
}
