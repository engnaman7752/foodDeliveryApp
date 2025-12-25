import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:user_app/assistant_methods/assistant_methods.dart';
import 'package:user_app/assistant_methods/cart_item_counter.dart';
import 'package:user_app/mainScreens/address_screen.dart';
import 'package:user_app/widgets/progress_bar.dart';
import 'package:user_app/global/global.dart';

import '../assistant_methods/total_ammount.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/text_widget_header.dart';

class CartScreen extends StatefulWidget {
  final String? sellerUID;
  const CartScreen({super.key, this.sellerUID});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<int>? separateItemQuantityList;

  num totolAmmount = 0;

  @override
  void initState() {
    super.initState();
    totolAmmount = 0;
    Provider.of<TotalAmmount>(context, listen: false).displayTotolAmmount(0);
    separateItemQuantityList = separateItemQuantities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.redAccent],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
            onPressed: () {
              clearCartNow(context);
            },
            icon: const Icon(Icons.clear_all)),
        title: const Text(
          "Fresh Dine",
          style: TextStyle(fontSize: 45, fontFamily: "Signatra"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                clearCartNow(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MySplashScreen()));
                Fluttertoast.showToast(msg: "cart has been cleared");
              },
              icon: const Icon(Icons.clear_all),
              label: const Text("Clear Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Get the total from provider instead of local variable
                double total = Provider.of<TotalAmmount>(context, listen: false)
                    .tAmmount
                    .toDouble();
                print("DEBUG CartScreen: Checkout with total = $total");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddressScreen(
                              totolAmmount: total,
                              sellerUID: widget.sellerUID,
                            )));
              },
              icon: const Icon(Icons.navigate_next),
              label: const Text("Check Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextWidgetHeader(title: "My Cart List"),
          ),
          SliverToBoxAdapter(
            child: Consumer2<TotalAmmount, CartItemCounter>(
              builder: (context, amountProvidr, cartProvider, c) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: cartProvider.count == 0
                        ? Container()
                        : Text(
                            "Total Price: ${amountProvidr.tAmmount.toString()}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCartItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList() {
    List<String>? cartItems = sharedPreferences!.getStringList("userCart");

    if (cartItems == null ||
        cartItems.isEmpty ||
        (cartItems.length == 1 && cartItems[0] == "garbageValue")) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No items in cart",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    List<String> itemIds = separateItemIds();
    List<int> quantities = separateItemQuantities();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchItemsWithPrices(itemIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: circularProgress());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Items not found",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        List<Map<String, dynamic>> itemsData = snapshot.data!;
        double totalPrice = 0;

        for (int i = 0; i < itemsData.length; i++) {
          double price = (itemsData[i]['price'] as num?)?.toDouble() ?? 0.0;
          totalPrice += price * quantities[i];
        }

        // Update total amount provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<TotalAmmount>(context, listen: false)
              .displayTotolAmmount(totalPrice);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsData.length,
          itemBuilder: (context, index) {
            double itemPrice =
                (itemsData[index]['price'] as num?)?.toDouble() ?? 0.0;
            double itemTotal = itemPrice * quantities[index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      // Fixed size image container
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                          color: Colors.grey[300],
                        ),
                        child: itemsData[index]['imageUrl'] != null
                            ? Image.network(
                                itemsData[index]['imageUrl'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(Icons.image,
                                    color: Colors.grey, size: 40),
                              ),
                      ),
                      // Product details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      itemsData[index]['title'] ??
                                          "Item ${itemIds[index]}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Qty: ${quantities[index]}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "₹${itemPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "Total: ₹${itemTotal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    onPressed: () {
                                      removeItemFromCart(
                                          itemIds[index], context);
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItemsWithPrices(
      List<String> itemIds) async {
    List<Map<String, dynamic>> items = [];

    try {
      // Get all sellers
      QuerySnapshot<Map<String, dynamic>> sellersSnapshot =
          await FirebaseFirestore.instance.collection("sellers").get();

      for (var seller in sellersSnapshot.docs) {
        String sellerId = seller.id;

        // Check each seller's menus
        QuerySnapshot<Map<String, dynamic>> menusSnapshot =
            await FirebaseFirestore.instance
                .collection("sellers")
                .doc(sellerId)
                .collection("menus")
                .get();

        for (var menu in menusSnapshot.docs) {
          // Check each menu's items
          QuerySnapshot<Map<String, dynamic>> itemsSnapshot =
              await FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(sellerId)
                  .collection("menus")
                  .doc(menu.id)
                  .collection("items")
                  .get();

          for (var item in itemsSnapshot.docs) {
            String itemId = item.get("itemId").toString();
            if (itemIds.contains(itemId)) {
              items.add({
                'itemId': itemId,
                'title': item.get('title') ?? 'Item',
                'price': item.get('price') ?? 0,
                'imageUrl': item.get('imageUrl'),
              });
            }
          }
        }
      }
    } catch (e) {
      print("DEBUG: Error fetching items: $e");
    }

    return items;
  }

  void removeItemFromCart(String itemId, BuildContext context) {
    List<String>? tempList = sharedPreferences!.getStringList("userCart");

    for (int i = 1; i < tempList!.length; i++) {
      String existingItemId = tempList[i].split(":")[0];
      if (existingItemId == itemId) {
        tempList.removeAt(i);
        break;
      }
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .update({"userCart": tempList}).then((value) {
      sharedPreferences!.setStringList("userCart", tempList);
      Provider.of<CartItemCounter>(context, listen: false)
          .displayCartListItemsNumber();
      setState(() {});
      Fluttertoast.showToast(msg: "Item removed from cart");
    });
  }
}
