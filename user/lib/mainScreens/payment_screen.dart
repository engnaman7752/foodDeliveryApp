import 'package:flutter/material.dart';
import 'package:user_app/mainScreens/placed_order_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String? addressID;
  final double? totolAmmount;
  final String? sellerUID;

  const PaymentScreen({
    super.key,
    this.addressID,
    this.totolAmmount,
    this.sellerUID,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "Cash on Delivery";

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
          "Select Payment Method",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Cash on Delivery
              PaymentMethodCard(
                icon: Icons.local_shipping,
                title: "Cash on Delivery",
                description: "Pay when you receive your order",
                isSelected: selectedPaymentMethod == "Cash on Delivery",
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Cash on Delivery";
                  });
                },
              ),
              const SizedBox(height: 15),
              // Credit/Debit Card
              PaymentMethodCard(
                icon: Icons.credit_card,
                title: "Credit/Debit Card",
                description: "Visa, Mastercard, Rupay",
                isSelected: selectedPaymentMethod == "Credit/Debit Card",
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Credit/Debit Card";
                  });
                },
              ),
              const SizedBox(height: 15),
              // Digital Wallet
              PaymentMethodCard(
                icon: Icons.account_balance_wallet,
                title: "Digital Wallet",
                description: "Google Pay, PhonePe, Paytm",
                isSelected: selectedPaymentMethod == "Digital Wallet",
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Digital Wallet";
                  });
                },
              ),
              const SizedBox(height: 15),
              // Net Banking
              PaymentMethodCard(
                icon: Icons.security,
                title: "Net Banking",
                description: "Direct bank transfer",
                isSelected: selectedPaymentMethod == "Net Banking",
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Net Banking";
                  });
                },
              ),
              const SizedBox(height: 30),
              // Order Summary
              Container(
                padding: const EdgeInsets.all(15),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount:"),
                        Text(
                          "₹${widget.totolAmmount?.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Payment Method:"),
                        Text(
                          selectedPaymentMethod,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    print(
                        "DEBUG PaymentScreen: Navigating with totolAmmount = ${widget.totolAmmount}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacedOrderScreen(
                          addressID: widget.addressID,
                          totolAmmount: widget.totolAmmount,
                          sellerUID: widget.sellerUID,
                          paymentMethod: selectedPaymentMethod,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Place Order",
                    style: TextStyle(
                      fontSize: 18,
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
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.redAccent : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.redAccent,
                size: 28,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[400],
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
