import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/models/address.dart';
import 'package:user_app/widgets/simple_Appbar.dart';
import 'package:user_app/widgets/text_field.dart';

class SaveAddressScreen extends StatefulWidget {
  const SaveAddressScreen({super.key});

  @override
  State<SaveAddressScreen> createState() => _SaveAddressScreenState();
}

class _SaveAddressScreenState extends State<SaveAddressScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _flatNumber = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _completeAddress = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  List<Placemark>? placemarks;
  Position? position;
  bool isLoading = false;

  String completeAddress = '';

  getUserLocationAddress() async {
    setState(() => isLoading = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enable location services")),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      // Request permission
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Location permission denied permanently. Open app settings."),
            ),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      // Get current position
      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      position = newPosition;

      // Get address from coordinates
      placemarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      if (placemarks != null && placemarks!.isNotEmpty) {
        Placemark pMarks = placemarks![0];

        String fullAddress =
            '${pMarks.street}, ${pMarks.locality}, ${pMarks.administrativeArea} ${pMarks.postalCode}, ${pMarks.country}';

        if (mounted) {
          setState(() {
            _locationController.text = fullAddress;
            _flatNumber.text = pMarks.street ?? '';
            _city.text = pMarks.locality ?? '';
            _state.text = pMarks.country ?? '';
            _completeAddress.text = fullAddress;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phoneNumber.dispose();
    _flatNumber.dispose();
    _city.dispose();
    _state.dispose();
    _completeAddress.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: "Fresh Dine",
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (position == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please get your location first")),
            );
            return;
          }

          if (formKey.currentState!.validate()) {
            String? uid = sharedPreferences!.getString("uid");

            // Debug: Check if UID exists
            if (uid == null || uid.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User not logged in properly")),
              );
              return;
            }

            final model = Address(
              name: _name.text.trim(),
              state: _state.text.trim(),
              fullAddress: _completeAddress.text.trim(),
              phoneNumber: _phoneNumber.text.trim(),
              flatNumber: _flatNumber.text.trim(),
              city: _city.text.trim(),
              lat: position!.latitude.toString(),
              lng: position!.longitude.toString(),
            ).toJson();

            print("Saving address with UID: $uid"); // Debug

            FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("addresses")
                .doc(DateTime.now().millisecondsSinceEpoch.toString())
                .set(model)
                .then((value) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New Address has been saved.")),
                );
              }
              formKey.currentState!.reset();
              Navigator.pop(context);
            }).catchError((e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error saving address: $e")),
                );
              }
            });
          }
        },
        label: const Text("Save Now"),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Save New Address :",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isLoading ? null : getUserLocationAddress,
              icon: const Icon(Icons.location_on, color: Colors.white),
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.redAccent),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
              label: Text(
                isLoading ? "Getting location..." : "Get my address",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: formKey,
              child: Column(
                children: [
                  MyTextField(
                    hint: "Name",
                    controller: _name,
                  ),
                  MyTextField(
                    hint: "Phone Number",
                    controller: _phoneNumber,
                  ),
                  MyTextField(
                    hint: "City",
                    controller: _city,
                  ),
                  MyTextField(
                    hint: "State",
                    controller: _state,
                  ),
                  MyTextField(
                    hint: "Address Line",
                    controller: _flatNumber,
                  ),
                  MyTextField(
                    hint: "Complete Address",
                    controller: _completeAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
