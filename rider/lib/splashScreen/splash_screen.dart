import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/authentication/auth_screen.dart';
import 'package:rider_app/mainScreens/home_screen.dart';
import 'package:rider_app/global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 2), () async {
      // Check if user is already logged in
      User? currentUser = firebaseAuth.currentUser;

      if (currentUser != null &&
          sharedPreferences != null &&
          sharedPreferences!.getString("uid") != null) {
        print("User already logged in: ${currentUser.uid}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print("No user logged in, going to AuthScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("Splash screen initialized");
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    print("Building splash screen");
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delivery_dining,
                size: 120,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Riders Food App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
