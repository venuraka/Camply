import 'package:camply/screens/login.dart';
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
    //   '/events': (context) => Events(),
    //   '/searchPeople': (context) => UserSearchScreen(),
    //   '/courses': (context) => Courses(),
    //   '/account': (context) => ProfilePage(),
    //   '/Editjob':(context) => Editjob(jobId: '2'),
    //   '/EditCourse':(context) => EditCourse(CourseId: '2'),
    },
  ));
}
