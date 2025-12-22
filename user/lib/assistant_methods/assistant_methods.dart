import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:user_app/assistant_methods/cart_item_counter.dart';
import 'package:user_app/global/global.dart';

separateOrderItemIds(orderId) {
  List<String> separateItemIdsList = [], defaultItemList = [];
  int i = 0;

  defaultItemList = List<String>.from(orderId);

  for (i; i < defaultItemList.length; i++) {
    String item = defaultItemList[i].toString();
    var pos = item.lastIndexOf(":");
    String getItemId = (pos != -1) ? item.substring(0, pos) : item;

    separateItemIdsList.add(getItemId);
  }

  return separateItemIdsList;
}

separateItemIds() {
  List<String> separateItemIdsList = [], defaultItemList = [];
  int i = 1; // Skip the first "garbageValue" item

  List<String>? cartItems = sharedPreferences!.getStringList("userCart");

  if (cartItems == null || cartItems.isEmpty) {
    print("DEBUG: userCart is null or empty");
    return separateItemIdsList;
  }

  defaultItemList = cartItems;

  print("DEBUG: userCart = $defaultItemList");

  for (i; i < defaultItemList.length; i++) {
    String item = defaultItemList[i].toString();
    var pos = item.lastIndexOf(":");
    String getItemId = (pos != -1) ? item.substring(0, pos) : item;

    separateItemIdsList.add(getItemId);
  }

  print("DEBUG: separateItemIds = $separateItemIdsList");

  return separateItemIdsList;
}

addItemToCart(String? foodItemId, BuildContext context, int itemCounter) {
  List<String>? tempList = sharedPreferences!.getStringList("userCart");

  // Check if item already exists in cart and update quantity instead of adding duplicate
  String newItem = "${foodItemId!}:$itemCounter";
  bool itemExists = false;

  for (int i = 1; i < tempList!.length; i++) {
    String existingItem = tempList[i];
    String existingItemId = existingItem.split(":")[0];

    if (existingItemId == foodItemId) {
      tempList[i] = newItem;
      itemExists = true;
      break;
    }
  }

  if (!itemExists) {
    tempList.add(newItem);
  }

  print("DEBUG: Adding to cart. New cart = $tempList");

  FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseAuth.currentUser!.uid)
      .update({
    "userCart": tempList,
  }).then((value) {
    String message =
        itemExists ? "Quantity Updated!" : "Item Added Successfully.";
    Fluttertoast.showToast(msg: message);

    sharedPreferences!.setStringList("userCart", tempList);

    //update the page
    Provider.of<CartItemCounter>(context, listen: false)
        .displayCartListItemsNumber();
  }).catchError((error) {
    print("DEBUG: Error adding to cart: $error");
    Fluttertoast.showToast(msg: "Error adding item to cart: $error");
  });
}

separateOrderItemQuantities(orderId) {
  List<String> separateItemQuantityList = [];
  List<String> defaultItemList = [];

  defaultItemList = List<String>.from(orderId);

  for (int i = 1; i < defaultItemList.length; i++) {
    String item = defaultItemList[i].toString();

    List<String> listItemCharacters = item.split(":").toList();

    var quanNumber = int.parse(listItemCharacters[1].toString());

    separateItemQuantityList.add(quanNumber.toString());
  }

  return separateItemQuantityList;
}

separateItemQuantities() {
  List<int> separateItemQuantityList = [];
  List<String> defaultItemList = [];

  defaultItemList = sharedPreferences!.getStringList("userCart")!;

  for (int i = 1; i < defaultItemList.length; i++) {
    String item = defaultItemList[i].toString();

    List<String> listItemCharacters = item.split(":").toList();

    var quanNumber = int.parse(listItemCharacters[1].toString());

    separateItemQuantityList.add(quanNumber);
  }

  return separateItemQuantityList;
}

clearCartNow(context) {
  sharedPreferences!.setStringList("userCart", ['garbageValue']);

  List<String>? emptyList = sharedPreferences!.getStringList("userCart");

  FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseAuth.currentUser!.uid)
      .update({"userCart": emptyList}).then((value) {
    sharedPreferences!.setStringList("userCart", emptyList!);
    Provider.of<CartItemCounter>(context, listen: false)
        .displayCartListItemsNumber();
  });
}

// Sync cart from Firestore to SharedPreferences
syncCartFromFirestore() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      List<String>? firestoreCart = List<String>.from(
          (userDoc.data() as Map<String, dynamic>)["userCart"] ??
              ['garbageValue']);

      print("DEBUG: Syncing cart from Firestore: $firestoreCart");
      sharedPreferences!.setStringList("userCart", firestoreCart);
    }
  } catch (e) {
    print("DEBUG: Error syncing cart: $e");
  }
}
