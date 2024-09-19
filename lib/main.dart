import 'package:box_booking_project/Auth/1_sing_in_screen.dart';
import 'package:box_booking_project/Users/1_home_page.dart';
import 'package:box_booking_project/Admin/admin_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:box_booking_project/Ui/1_spalesh_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Box Booking Project',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal,
          hintColor: Colors.tealAccent,
          buttonTheme: const ButtonThemeData(
            buttonColor: Colors.teal,
            textTheme: ButtonTextTheme.primary,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              color: Colors.black,
            ),
            bodyMedium: TextStyle(color: Colors.black),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
            labelStyle: TextStyle(color: Colors.black),
          ),
          // Customize the cursor color globally
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromARGB(
                255, 83, 83, 83), // Set the cursor color to black
          ),
          // Set the default background color for Scaffold
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) =>
              const SplashScreen(), // Set the splash screen as the initial route
          '/login': (context) => SingInScreen1(), // Add the login route
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
      ),
    );
  }
}
