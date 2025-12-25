# Admin App Integration Guide

## Overview
This document explains how to integrate the admin application with your existing rider, seller, and user apps, and how to implement the commission tracking system.

## Database Schema Updates

### 1. Update Orders Collection

When orders are created in the user app or processed by the seller/rider apps, ensure they include:

```dart
// Example order creation in user app
Map<String, dynamic> orderData = {
  'orderId': orderId,
  'userId': userId,
  'sellerId': selectedSellerId,
  'sellerName': sellerNameFromDB,
  'totalAmount': double.parse(totalAmount),
  
  // Calculate commission automatically
  'companyCommission': double.parse(totalAmount) * 0.10,  // 10%
  'sellerAmount': double.parse(totalAmount) * 0.90,       // 90%
  
  'paymentMethod': paymentMethod, // "card" or "cash_on_delivery"
  'status': 'pending',
  'orderTime': DateTime.now().millisecondsSinceEpoch.toString(),
  'addressId': addressId,
  'isSuccess': false,
  'cashCollected': false, // For COD orders
  'items': orderItems,
};

// Save to Firestore
await FirebaseFirestore.instance
    .collection('orders')
    .doc(orderId)
    .set(orderData);

// Also save to user's order history
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('orders')
    .doc(orderId)
    .set(orderData);
```

### 2. Update Sellers Collection

Add these fields to your existing sellers collection:

```dart
// When creating/updating seller profile
Map<String, dynamic> sellerData = {
  'sellerId': sellerId,
  'sellerName': sellerName,
  'sellerEmail': sellerEmail,
  'sellerAvtar': avatarUrl,
  'restaurantName': restaurantName,
  
  // Add these new fields
  'totalEarnings': 0.0,        // Updated when orders complete
  'totalOrders': 0,             // Updated with each order
  'rating': 5.0,                // From ratings system
  'isApproved': false,          // Admin approval status
  'joinDate': DateTime.now().toString(),
  'phoneNumber': phoneNumber,
  'address': address,
};
```

## Implementation in Existing Apps

### User App (rider app) - Order Creation

Update your order creation logic in the user app:

```dart
// Add this to your order creation method
Future<void> createOrder(
  String userId,
  String sellerId,
  String sellerName,
  List<dynamic> items,
  double totalAmount,
  String paymentMethod,
  String addressId,
) async {
  try {
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Calculate commission
    double companyCommission = totalAmount * 0.10;
    double sellerAmount = totalAmount * 0.90;
    
    Map<String, dynamic> orderData = {
      'orderId': orderId,
      'userId': userId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'totalAmount': totalAmount,
      'companyCommission': companyCommission,
      'sellerAmount': sellerAmount,
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'orderTime': DateTime.now().millisecondsSinceEpoch.toString(),
      'addressId': addressId,
      'isSuccess': false,
      'cashCollected': false,
      'items': items,
    };
    
    // Save to global orders collection (for admin)
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .set(orderData);
    
    // Also save to user's order history
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .set(orderData);
    
    // Update seller's order count and earnings
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .update({
      'totalOrders': FieldValue.increment(1),
      'totalEarnings': FieldValue.increment(sellerAmount),
    });
    
  } catch (e) {
    print('Error creating order: $e');
  }
}
```

### Seller App - Order Status Updates

Update your seller app to sync with the global orders collection:

```dart
// When seller updates order status
Future<void> updateOrderStatus(
  String orderId,
  String newStatus,
) async {
  try {
    // Update in global orders collection
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'status': newStatus,
    });
    
    // Also update in seller's collection if you maintain one
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .doc(orderId)
        .update({
      'status': newStatus,
    });
  } catch (e) {
    print('Error updating order status: $e');
  }
}
```

### Rider App - Rider Assignment

When a rider is assigned to an order:

```dart
// When assigning rider to order
Future<void> assignRiderToOrder(
  String orderId,
  String riderId,
  String riderName,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'riderAssigned': riderId,
      'riderName': riderName,
      'status': 'in_delivery',
    });
  } catch (e) {
    print('Error assigning rider: $e');
  }
}
```

### Cash on Delivery (COD) Handling

When order is delivered via COD:

```dart
// When rider collects cash
Future<void> markCODCollected(String orderId) async {
  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'cashCollected': true,
      'status': 'ended',
      'deliveryTime': DateTime.now().millisecondsSinceEpoch.toString(),
      'isSuccess': true,
    });
  } catch (e) {
    print('Error marking COD collected: $e');
  }
}
```

## Admin App Deployment

### Setup Steps

1. **Create Admin Account**
   ```
   Firebase Console → Authentication → Create new user
   Email: admin@fooddelivery.com
   Password: (secure password)
   ```

2. **Update Security Rules**
   Add this to your Firestore security rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /orders/{document=**} {
         allow read, write: if request.auth.uid == "ADMIN_UID";
       }
       
       match /sellers/{document=**} {
         allow read, write: if request.auth.uid == "ADMIN_UID";
       }
     }
   }
   ```

3. **Update Firebase Options**
   In `admin/lib/firebase_options.dart`, add your Firebase credentials

4. **Build and Run**
   ```bash
   cd admin
   flutter pub get
   flutter run
   ```

## API References

### Commission Calculation

```dart
double calculateCompanyCommission(double orderAmount) {
  return orderAmount * 0.10; // 10% commission
}

double calculateSellerAmount(double orderAmount) {
  return orderAmount * 0.90; // 90% to seller
}
```

### Order Status Flow

```
pending → confirmed → preparing → ready → in_delivery → ended
                                                       ↘ cancelled
```

## Reporting Features

### Generate Commission Report

```dart
Future<Map<String, double>> getMonthlyReport(int month, int year) async {
  final startDate = DateTime(year, month, 1);
  final endDate = DateTime(year, month + 1, 0);
  
  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('orderTime', 
          isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch.toString(),
          isLessThanOrEqualTo: endDate.millisecondsSinceEpoch.toString())
      .get();
  
  double totalOrders = snapshot.docs.length.toDouble();
  double totalCommission = 0;
  double totalRevenue = 0;
  
  for (var doc in snapshot.docs) {
    totalRevenue += double.parse(doc['totalAmount']?.toString() ?? '0');
    totalCommission += double.parse(doc['companyCommission']?.toString() ?? '0');
  }
  
  return {
    'totalOrders': totalOrders,
    'totalCommission': totalCommission,
    'totalRevenue': totalRevenue,
  };
}
```

## Seller Approval Workflow

1. **Seller Registration** → isApproved: false
2. **Admin Reviews** → Dashboard shows pending sellers
3. **Admin Approves** → isApproved: true
4. **Seller Can Now Accept Orders**

```dart
// Check approval before allowing orders
Future<bool> isSellerApproved(String sellerId) async {
  final doc = await FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .get();
  
  return doc['isApproved'] ?? false;
}
```

## Testing Checklist

- [ ] Admin login/logout works
- [ ] Dashboard displays correct statistics
- [ ] Orders appear in real-time
- [ ] Commission calculations are accurate (10%/90% split)
- [ ] Seller approval workflow functions
- [ ] Order status updates sync across apps
- [ ] COD tracking works
- [ ] Filters work on all screens
- [ ] Real-time updates work
- [ ] Navigation between screens is smooth

## Troubleshooting

### Orders not appearing in admin app
- Check Firebase credentials in firebase_options.dart
- Verify Firestore rules allow read access
- Ensure orders are being saved to global 'orders' collection

### Commission calculations wrong
- Verify the 10% calculation: totalAmount * 0.10
- Check that companyCommission and sellerAmount are stored correctly
- Ensure totalAmount is a number, not a string

### Admin can't login
- Verify admin account exists in Firebase Authentication
- Check Firebase credentials are correct
- Ensure internet connection is stable

### Real-time updates not working
- Check Firestore rules
- Verify network connection
- Restart the app

## Security Considerations

1. **Restrict Admin Access**: Only admin accounts should access the admin app
2. **Validate Data**: Ensure all data is validated before saving
3. **Rate Limiting**: Implement rate limiting for API calls
4. **Audit Logs**: Log all admin actions
5. **Secure Credentials**: Never hardcode sensitive information

## Support & Maintenance

For issues:
1. Check Firebase Console logs
2. Verify Firestore structure
3. Review security rules
4. Check app logs for errors

---

**Last Updated**: December 2024
**Version**: 1.0.0
