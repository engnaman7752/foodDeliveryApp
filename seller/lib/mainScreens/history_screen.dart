import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_app/global/global.dart';
import 'package:seller_app/widgets/progress_bar.dart';
import 'package:seller_app/widgets/simple_Appbar.dart';

import '../assistant_methods/assistant_methods.dart';
import '../widgets/order_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(
          title: "History",
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("sellerUID",
                  isEqualTo: sharedPreferences!.getString("uid"))
              .where("status", isEqualTo: "ended")
              .snapshots(),
          builder: (c, snapshot) {
            if (snapshot.hasData) {
              final allDocs = snapshot.data!.docs;

              // Sort locally by orderTime
              allDocs.sort((a, b) {
                final timeA =
                    (a.data() as Map<String, dynamic>)['orderTime'] ?? '';
                final timeB =
                    (b.data() as Map<String, dynamic>)['orderTime'] ?? '';
                return timeB.compareTo(timeA);
              });

              return allDocs.isEmpty
                  ? Center(child: Text("No Order History Found"))
                  : ListView.builder(
                      itemCount: allDocs.length,
                      itemBuilder: (c, index) {
                        final orderData =
                            allDocs[index].data() as Map<String, dynamic>;
                        final productIds = orderData["productIds"] as List?;

                        if (productIds == null || productIds.isEmpty) {
                          return ListTile(
                            title: Text("Invalid Order"),
                          );
                        }

                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("items")
                              .where("itemId",
                                  whereIn: separateOrderItemIds(productIds))
                              .get(),
                          builder: (c, snap) {
                            return snap.hasData
                                ? OrderCard(
                                    itemCount: snap.data?.docs.length,
                                    data: snap.data?.docs,
                                    orderId: allDocs[index].id,
                                    seperateQuantitiesList:
                                        separateOrderItemQuantities(productIds),
                                  )
                                : Center(
                                    child: circularProgress(),
                                  );
                          },
                        );
                      },
                    );
            } else {
              return Center(
                child: circularProgress(),
              );
            }
          },
        ),
      ),
    );
  }
}
