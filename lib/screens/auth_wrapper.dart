import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login.dart';
import '../screens/home_screen.dart'; // You'll create this later

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is logged in
        if (snapshot.hasData) {
          return const HomeScreen(); // Navigate to home screen
        }
        // If the user is not logged in
        else {
          return const LoginScreen(); // Navigate to login screen
        }
      },
    );
  }
}