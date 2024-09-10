import 'package:box_booking_project/Auth/1_log_in_screen.dart';
import 'package:box_booking_project/User/1_home_page.dart';
import 'package:box_booking_project/Admin/admin_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:box_booking_project/Ui/1_spalesh_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Box Booking Project',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const SplashScreen(), // Set the splash screen as the initial route
        '/login': (context) => const UserInfo2(), // Add the login route
        '/adminPanel': (context) =>
            const AdminPanelScreen(), // Add the admin panel route
        '/home': (context) => const HomePageScreen5(), // Add the home route
      },
      onUnknownRoute: (settings) {
        // Handle unknown routes
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Unknown Route')),
                  body: const Center(child: Text('404 Not Found')),
                ));
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
