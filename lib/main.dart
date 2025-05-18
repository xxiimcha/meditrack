import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/patient_form_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/medication_list_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MeditrackApp());
}

class MeditrackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => LandingScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/': (context) => HomeScreen(),
        '/schedule': (context) => ScheduleScreen(),
        '/list': (context) => const MedicationScheduleListScreen(),
        '/patient_form': (context) => const PatientFormScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
