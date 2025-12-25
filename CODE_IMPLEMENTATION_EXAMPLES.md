# Implementation Examples for Rider, Seller, and User Apps

This document provides code examples for integrating the admin commission system into your existing apps.

## 1. User App (Rider App) - Order Creation

### Location: `user/lib/mainScreens/checkout_screen.dart` (or similar)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> placeOrder({
  required String userId,
  required String sellerId,
  required String sellerName,
  required List<Map<String, dynamic>> cartItems,
  required double totalAmount,
  required String paymentMethod, // "card" or "cash_on_delivery"
  required String addressId,
}) async {
  try {
    // Generate unique order ID
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Calculate commission
    double companyCommission = totalAmount * 0.10;  // 10% to company
    double sellerAmount = totalAmount * 0.90;        // 90% to seller
    
    // Prepare order data
    Map<String, dynamic> orderData = {
      'orderId': orderId,
      'userId': userId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'riderAssigned': null,
      'riderName': null,
      'totalAmount': totalAmount,
      'companyCommission': companyCommission,
      'sellerAmount': sellerAmount,
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'orderTime': DateTime.now().millisecondsSinceEpoch.toString(),
      'deliveryTime': null,
      'addressId': addressId,
      'isSuccess': false,
      'cashCollected': false,
      'items': cartItems,
    };
    
    // Save to global orders collection (for admin dashboard)
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .set(orderData);
    
    // Also save to user's personal order history
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .set(orderData);
    
    // Update seller stats
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .update({
      'totalOrders': FieldValue.increment(1),
      'totalEarnings': FieldValue.increment(sellerAmount),
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
    );
    
    // Navigate to order tracking screen
    Navigator.of(context).pushReplacementNamed(
      '/order-tracking',
      arguments: orderId,
    );
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error placing order: $e')),
    );
  }
}
```

## 2. Seller App - Order Management

### Location: `seller/lib/mainScreens/orders_screen.dart` (or similar)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerOrdersScreen extends StatefulWidget {
  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final String sellerId = 'SELLER_ID'; // Get from authenticated user
  
  // Get seller's orders from global orders collection
  Stream<QuerySnapshot> _getSellerOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('orderTime', descending: true)
        .snapshots();
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
      });
      
      // Also save to seller's local collection if you maintain one
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to: $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSellerOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var orderDoc = snapshot.data!.docs[index];
              var order = orderDoc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order['orderId'].toString().substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['status'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Commission Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                '₹${order['totalAmount']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Earnings (90%)',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                '₹${order['sellerAmount']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Company Commission (10%)',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                '₹${order['companyCommission']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Status Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showStatusUpdateDialog(order['orderId']);
                          },
                          child: const Text('Update Status'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  void _showStatusUpdateDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusButton('confirmed', 'Confirmed'),
            _buildStatusButton('preparing', 'Preparing'),
            _buildStatusButton('ready', 'Ready for Pickup'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusButton(String status, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          updateOrderStatus(widget.orderId, status);
          Navigator.pop(context);
        },
        child: Text(label),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.deepOrange;
      case 'ready':
        return Colors.teal;
      case 'in_delivery':
        return Colors.indigo;
      case 'ended':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
```

## 3. Rider App - Order Assignment and Delivery

### Location: `rider/lib/mainScreens/available_orders_screen.dart` (or similar)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RiderAvailableOrdersScreen extends StatefulWidget {
  @override
  State<RiderAvailableOrdersScreen> createState() =>
      _RiderAvailableOrdersScreenState();
}

class _RiderAvailableOrdersScreenState extends State<RiderAvailableOrdersScreen> {
  final String riderId = 'RIDER_ID'; // Get from authenticated user
  final String riderName = 'RIDER_NAME'; // Get from user profile
  
  // Get unassigned orders
  Stream<QuerySnapshot> _getUnassignedOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .where('riderAssigned', isEqualTo: null)
        .orderBy('orderTime', descending: true)
        .snapshots();
  }
  
  // Assign rider to order
  Future<void> acceptOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'riderAssigned': riderId,
        'riderName': riderName,
        'status': 'in_delivery',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted! Start delivery.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting order: $e')),
      );
    }
  }
  
  // Mark delivery complete (and collect cash if COD)
  Future<void> completeDelivery(String orderId, bool isCOD) async {
    try {
      Map<String, dynamic> updateData = {
        'status': 'ended',
        'isSuccess': true,
        'deliveryTime': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      
      // If Cash on Delivery, mark as collected
      if (isCOD) {
        updateData['cashCollected'] = true;
      }
      
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update(updateData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery completed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing delivery: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUnassignedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders available'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var orderDoc = snapshot.data!.docs[index];
              var order = orderDoc.data() as Map<String, dynamic>;
              
              bool isCOD = order['paymentMethod'] == 'cash_on_delivery';
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order['orderId'].toString().substring(0, 8)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'From: ${order['sellerName']}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          if (isCOD)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'COD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Order Amount
                      Text(
                        'Amount: ₹${order['totalAmount']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      if (isCOD)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Cash to collect: ₹${order['totalAmount']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                acceptOrder(order['orderId']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Decline order
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 4. Firestore Field Value Usage

Import Firestore FieldValue for increments:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Usage in seller update:
await FirebaseFirestore.instance
    .collection('sellers')
    .doc(sellerId)
    .update({
  'totalOrders': FieldValue.increment(1),
  'totalEarnings': FieldValue.increment(sellerAmount),
});
```

## 5. Commission Calculation Helper

Create a utility file: `lib/utils/commission_calculator.dart`

```dart
class CommissionCalculator {
  static const double COMPANY_COMMISSION_PERCENTAGE = 0.10; // 10%
  static const double SELLER_PERCENTAGE = 0.90;             // 90%
  
  static double calculateCompanyCommission(double totalAmount) {
    return totalAmount * COMPANY_COMMISSION_PERCENTAGE;
  }
  
  static double calculateSellerAmount(double totalAmount) {
    return totalAmount * SELLER_PERCENTAGE;
  }
  
  static Map<String, double> calculateCommission(double totalAmount) {
    return {
      'totalAmount': totalAmount,
      'companyCommission': calculateCompanyCommission(totalAmount),
      'sellerAmount': calculateSellerAmount(totalAmount),
    };
  }
}
```

Usage:
```dart
import 'package:user_app/utils/commission_calculator.dart';

var commission = CommissionCalculator.calculateCommission(500.0);
print('Company Commission: ${commission['companyCommission']}'); // 50
print('Seller Amount: ${commission['sellerAmount']}');           // 450
```

---

**Note**: Replace `'SELLER_ID'`, `'RIDER_ID'`, etc. with actual user IDs from authentication.
