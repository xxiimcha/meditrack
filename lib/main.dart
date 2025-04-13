import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(MeditrackApp());
}

class MeditrackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Define the routes for navigation
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => LandingScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/': (context) => HomeScreen(),
        '/schedule': (context) => ScheduleScreen(),
      },
    );
  }
}
