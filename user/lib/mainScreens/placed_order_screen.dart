import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user_app/assistant_methods/assistant_methods.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/mainScreens/home_screen.dart';

import 'package:user_app/widgets/progress_bar.dart';

class PlacedOrderScreen extends StatefulWidget {
  String? addressID;
  double? totolAmmount;
  String? sellerUID;
  String? paymentMethod;

  PlacedOrderScreen(
      {super.key,
      this.addressID,
      this.totolAmmount,
      this.sellerUID,
      this.paymentMethod = "Cash on Delivery"});

  @override
  State<PlacedOrderScreen> createState() => _PlacedOrderScreenState();
}

class _PlacedOrderScreenState extends State<PlacedOrderScreen> {
  String orderId = DateTime.now().microsecondsSinceEpoch.toString();
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    print("DEBUG PlacedOrderScreen: totolAmmount = ${widget.totolAmmount}");
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Payment Successful!");
    addOrderDetails();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  void _processPayment() {
    if (widget.paymentMethod == "Cash on Delivery") {
      addOrderDetails();
    } else {
      _startRazorpayPayment();
    }
  }

  void _startRazorpayPayment() {
    var options = {
      'key': 'rzp_test_Rue7Nc7QeqKlst', // Your Razorpay Key ID
      'amount': (widget.totolAmmount! * 100).toInt(), // Amount in paise
      'name': 'Fresh Dine',
      'description': 'Order Payment',
      'prefill': {'contact': '9876543210', 'email': 'test@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addOrderDetails() {
    // Calculate commission (10% for company, 90% for seller)
    double totalAmount = widget.totolAmmount ?? 0;
    double companyCommission = totalAmount * 0.10; // 10%
    double sellerAmount = totalAmount * 0.90; // 90%

    writeOrderDetailsForUser({
      "addressId": widget.addressID,
      "totolAmmount": widget.totolAmmount,
      "companyCommission": companyCommission,
      "sellerAmount": sellerAmount,
      "orderedBy": sharedPreferences!.getString("uid"),
      "productIds": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": widget.paymentMethod ?? "Cash on Delivery",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    });

    writeOrderDetailsForSeller({
      "addressId": widget.addressID,
      "totolAmmount": widget.totolAmmount,
      "companyCommission": companyCommission,
      "sellerAmount": sellerAmount,
      "orderedBy": sharedPreferences!.getString("uid"),
      "productIds": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": widget.paymentMethod ?? "Cash on Delivery",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    }).whenComplete(() {
      clearCartNow(context);
      setState(() {
        orderId = "";

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        Fluttertoast.showToast(
            msg: "Congratulations, Order has been placed Successfully");
      });
    });
  }

  Future writeOrderDetailsForUser(
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  Future writeOrderDetailsForSeller(
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(data);
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
        title: const Text(
          "Order Summary",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Order Summary with item count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Items in cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Items in Cart:"),
                        Text(
                          "${separateItemIds().length}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount:"),
                        Text(
                          "₹${widget.totolAmmount?.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Payment Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Payment Method:"),
                        Text(
                          widget.paymentMethod ?? "Cash on Delivery",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.paymentMethod == "Cash on Delivery"
                              ? 'Place Order'
                              : 'Pay ₹${widget.totolAmmount?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
