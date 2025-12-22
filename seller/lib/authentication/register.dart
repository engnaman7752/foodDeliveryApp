import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_app/widgets/custom_text_field.dart';
import 'package:seller_app/widgets/error_Dialog.dart';
import 'package:seller_app/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';
import '../global/global.dart';
import '../mainScreens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmePasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      position = newPosition;

      placeMarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);

      Placemark pMarks = placeMarks![0];
      completeAddress =
      '${pMarks.subThoroughfare} ${pMarks.thoroughfare},${pMarks.subLocality} ${pMarks.locality},${pMarks.subAdministrativeArea}, ${pMarks.administrativeArea} ${pMarks.postalCode},${pMarks.country}';
      locationController.text = completeAddress;

      setState(() {});
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(message: "Error getting location: ${e.toString()}");
          });
    }
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(message: "Please select an image");
          });
      return;
    }

    if (passwordController.text != confirmePasswordController.text) {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(message: "Passwords don't match");
          });
      return;
    }

    if (passwordController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        locationController.text.isEmpty ||
        emailController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
                message: "Please fill all required fields");
          });
      return;
    }

    if (position == null) {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
                message: "Please get your current location first");
          });
      return;
    }

    // Start registration process
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const LoadingDialog(
              message: "Registering Account...",
            );
          });

      // First, create the user account
      await authenticateSellerAndSignUp();
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(message: "Error: ${e.toString()}");
          });
    }
  }

  Future<void> authenticateSellerAndSignUp() async {
    try {
      User? currentUser;

      // Create Firebase Auth account
      final auth = await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      currentUser = auth.user;

      if (currentUser != null) {
        // NOW upload the image (user is authenticated)
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        fStorage.Reference reference = fStorage.FirebaseStorage.instance
            .ref()
            .child('sellers')
            .child(currentUser.uid)
            .child(fileName);

        fStorage.UploadTask uploadTask =
        reference.putFile(File(imageXFile!.path));

        fStorage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() {});
        sellerImageUrl = await taskSnapshot.ref.getDownloadURL();

        // Save to Firestore
        await saveDataToFireStore(currentUser);

        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
          'This email is already registered. Please login instead.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Use at least 6 characters.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }

      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(message: errorMessage);
          });
    } catch (error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: 'An unexpected error occurred: ${error.toString()}',
            );
          });
    }
  }

  Future<void> saveDataToFireStore(User currentUser) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(currentUser.uid)
        .set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvtar": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "Approved",
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    // Save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email ?? "");
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("PhotoUrl", sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              _getImage();
            },
            child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile == null
                    ? null
                    : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? Icon(
                  Icons.add_photo_alternate,
                  size: MediaQuery.of(context).size.width * 0.20,
                  color: Colors.grey,
                )
                    : null),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.person,
                  controller: nameController,
                  hintText: 'Name',
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: 'Email',
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: 'Password',
                  isObsecre: true,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: confirmePasswordController,
                  hintText: 'Confirm Password',
                  isObsecre: true,
                ),
                CustomTextField(
                  data: Icons.phone,
                  controller: phoneController,
                  hintText: 'Phone',
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.my_location,
                  controller: locationController,
                  hintText: 'Cafe/Restaurant Address',
                  isObsecre: false,
                  enabled: true,
                ),
                Container(
                  width: 400,
                  height: 40,
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getCurrentLocation();
                    },
                    icon: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Get My Current Location',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 250, 171, 119),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              formValidation();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 249, 117, 161),
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
            child: const Text(
              "Sign Up",
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}