import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seller_app/global/global.dart';

import '../splashScreen/splash_screen.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("sellerUID",
                  isEqualTo: sharedPreferences!.getString("uid"))
              .where("status", isEqualTo: "ended")
              .where("isSuccess", isEqualTo: true)
              .snapshots(),
          builder: (c, snapshot) {
            double sellerTotalEarnings = 0;

            if (snapshot.hasData) {
              // Calculate total earnings from all completed orders with successful payments
              for (var order in snapshot.data!.docs) {
                final data = order.data() as Map<String, dynamic>;
                final amount = data["totolAmmount"];
                if (amount != null) {
                  sellerTotalEarnings +=
                      double.tryParse(amount.toString()) ?? 0;
                }
              }
            }

            return snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ignore: prefer_interpolation_to_compose_strings
                      Text(
                        "₹${sellerTotalEarnings.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontFamily: "Signatra"),
                      ),
                      const Text(
                        "Total Earnings",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                        width: 200,
                        child: Divider(
                          color: Colors.white,
                          thickness: 1.5,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "(From ${snapshot.data?.docs.length ?? 0} completed orders)",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),

                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => MySplashScreen()));
                        },
                        child: const Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(
                              vertical: 40, horizontal: 120),
                          child: ListTile(
                            leading: Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                            ),
                            title: Text(
                              "Back",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
          },
        )),
      ),
    );
  }
}
