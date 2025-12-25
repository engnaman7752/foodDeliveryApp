import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seller_app/assistant_methods/assistant_methods.dart';
import 'package:seller_app/global/global.dart';
import 'package:seller_app/widgets/order_card.dart';
import 'package:seller_app/widgets/progress_bar.dart';
import 'package:seller_app/widgets/simple_Appbar.dart';

class NewOrdersScreen extends StatefulWidget {
  const NewOrdersScreen({super.key});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(
          title: "New Orders",
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("orders").snapshots(),
          builder: (c, snapshot) {
            if (snapshot.hasData) {
              String? sellerUid = sharedPreferences!.getString("uid");

              print("DEBUG: Seller UID = $sellerUid");
              print(
                  "DEBUG: Total orders in DB = ${snapshot.data!.docs.length}");

              // Filter orders locally by status and sellerUID
              final allDocs = snapshot.data!.docs;
              final docs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'];
                final docSellerUID = data['sellerUID'];
                print("DEBUG: Order - status=$status, sellerUID=$docSellerUID");
                return status == 'normal' && docSellerUID == sellerUid;
              }).toList();

              print(
                  "DEBUG: Filtered orders (normal status for this seller) = ${docs.length}");

              // Sort documents by publishedDate in descending order locally
              docs.sort((a, b) {
                final dateA =
                    (a.data() as Map<String, dynamic>)['publishedDate'] ?? '';
                final dateB =
                    (b.data() as Map<String, dynamic>)['publishedDate'] ?? '';
                return dateB.compareTo(dateA);
              });

              return docs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Orders Found"),
                          SizedBox(height: 16),
                          Text("Seller UID: $sellerUid"),
                          SizedBox(height: 8),
                          Text("Total orders in DB: ${allDocs.length}"),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (c, index) {
                        final orderData =
                            docs[index].data() as Map<String, dynamic>;
                        final productIds = orderData["productIds"] as List?;
                        final orderId = docs[index].id;

                        print(
                            "DEBUG: Order $index - ID=$orderId, ProductIds=$productIds");

                        if (productIds == null || productIds.isEmpty) {
                          return ListTile(
                            title: Text("Invalid Order - No Products"),
                          );
                        }

                        final separatedIds = separateOrderItemIds(productIds);
                        print(
                            "DEBUG: Separated IDs for order $orderId: $separatedIds");
                        print(
                            "DEBUG: Separated IDs length: ${separatedIds.length}");

                        // Filter out garbageValue
                        final validIds = separatedIds
                            .where((id) => id != 'garbageValue')
                            .toList();
                        print("DEBUG: Valid IDs after filtering: $validIds");

                        if (validIds.isEmpty) {
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text("Order ID: $orderId"),
                              subtitle: Text("No valid product IDs in order"),
                            ),
                          );
                        }

                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("items")
                              .where("itemId", whereIn: validIds)
                              .get()
                              .then((snap) {
                            print(
                                "DEBUG: Items query returned ${snap.docs.length} results for IDs: $validIds");
                            return snap;
                          }),
                          builder: (c, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return Card(
                                margin: EdgeInsets.all(8),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Order ID: $orderId"),
                                      SizedBox(height: 8),
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (snap.hasError) {
                              print(
                                  "DEBUG: Items query error for $orderId: ${snap.error}");
                              return Card(
                                margin: EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text("Order ID: $orderId"),
                                  subtitle: Text(
                                      "Error loading items: ${snap.error}"),
                                ),
                              );
                            }

                            if (snap.hasData && snap.data!.docs.isNotEmpty) {
                              print(
                                  "DEBUG: Found ${snap.data!.docs.length} items for order $orderId");
                              return OrderCard(
                                itemCount: snap.data?.docs.length,
                                data: snap.data?.docs,
                                orderId: orderId,
                                seperateQuantitiesList:
                                    separateOrderItemQuantities(productIds),
                              );
                            }

                            print(
                                "DEBUG: No items found in DB for order $orderId with IDs: $validIds");
                            return Card(
                              margin: EdgeInsets.all(8),
                              child: ListTile(
                                title: Text("Order ID: $orderId"),
                                subtitle: Text(
                                    "Items not found in database. IDs: ${validIds.join(', ')}"),
                              ),
                            );
                          },
                        );
                      },
                    );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
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
