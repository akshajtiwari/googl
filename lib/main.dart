import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart'; //  NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Helpora App",

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),

      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          //  Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          //  Error
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Something went wrong")),
            );
          }

          //  Firebase ready → go to AuthWrapper
          return AuthWrapper();
        },
      ),
    );
  }
}

//  AUTH CHECK
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return DashboardScreen(); //  FIXED
    } else {
      return LoginScreen();
    }
  }
}