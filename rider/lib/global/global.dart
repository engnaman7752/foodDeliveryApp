import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;

// User data
User? currentUser;
String? userID;
String? userEmail;
String? userName;
String? userPhone;
String? userAddress;

// Location
Position? position;
List<Placemark>? placeMarks;
String completeAddress = "";

// Earnings
String previousEarnings = "0";
String previousRidersEarnings = "0";
String perParcelDeliveryAmount = "10"; // Default delivery charge