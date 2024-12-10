import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';

void main() {
  runApp(MeditrackApp());
}

class MeditrackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Define the routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/schedule': (context) => ScheduleScreen(),
      },
    );
  }
}
