import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/authentication/auth_screen.dart';
import 'package:rider_app/global/global.dart';
import 'package:rider_app/widgets/loading_dialog.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/error_Dialog.dart';
import '../mainScreens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      loginNow();
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              message: "Please Enter Email and Password",
            );
          });
    }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: 'Checking Credential',
          );
        });

    User? currentUser;

    try {
      final auth = await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      currentUser = auth.user;

      if (currentUser != null) {
        await readDataAndSetDataLocally(currentUser);
      } else {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog(
                message: "Login failed. Please try again.",
              );
            });
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: error.toString(),
            );
          });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("riders")
          .doc(currentUser.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null && data["status"] == "Approved") {
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString("email", data["riderEmail"] ?? "");
          await sharedPreferences!.setString("name", data["riderName"] ?? "");
          await sharedPreferences!.setString("PhotoUrl", data["riderAvtar"] ?? "");

          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          await firebaseAuth.signOut();
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Admin has blocked your account.\nContact: admin@gmail.com");
        }
      } else {
        await firebaseAuth.signOut();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog(
                message: 'No record exists. Please register first.',
              );
            });
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: 'Error: ${e.toString()}',
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(
                'assets/images/signup.png',
                height: 270,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              formValidation();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade100,
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
            child: const Text(
              "Login",
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}