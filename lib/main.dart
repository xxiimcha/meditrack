import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/patient_form_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/medication_list_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set up local notification settings
  await _initLocalNotifications();

  runApp(MeditrackApp());
}

Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Listen to foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_channel',
            'Medication Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
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
