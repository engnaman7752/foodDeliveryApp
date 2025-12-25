# Admin App - Quick Setup Guide

## Files Created

The admin app includes the following structure:

```
admin/
├── lib/
│   ├── authentication/
│   │   └── admin_auth_screen.dart      # Authentication wrapper
│   ├── screens/
│   │   ├── admin_login.dart            # Login screen
│   │   ├── admin_dashboard.dart        # Main dashboard
│   │   ├── orders_management_screen.dart
│   │   ├── sellers_management_screen.dart
│   │   └── commission_tracking_screen.dart
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── seller_model.dart
│   │   └── commission_report.dart
│   ├── global/
│   │   └── global.dart                 # SharedPreferences
│   ├── main.dart
│   └── firebase_options.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Step-by-Step Setup

### 1. Initialize Flutter Project
```bash
cd admin
flutter pub get
```

### 2. Configure Firebase

#### a) Get your Firebase credentials:
1. Go to Firebase Console (https://console.firebase.google.com)
2. Select your project
3. Go to Project Settings
4. Copy the credentials for Android/iOS

#### b) Update `lib/firebase_options.dart`:
Replace the placeholder values with your actual Firebase credentials.

### 3. Enable Firestore

In Firebase Console:
1. Go to Firestore Database
2. Click "Create Database"
3. Start in test mode (for development)
4. Choose your region
5. Click "Enable"

### 4. Enable Authentication

In Firebase Console:
1. Go to Authentication
2. Click "Get Started"
3. Enable "Email/Password"
4. Create an admin account:
   - Email: admin@fooddelivery.com
   - Password: (secure password)

### 5. Create Database Collections

Create these collections in Firestore:

**a) orders** - For all orders
```
Document: {orderId}
Fields:
  orderId: string
  userId: string
  sellerId: string
  sellerName: string
  totalAmount: number
  companyCommission: number
  sellerAmount: number
  paymentMethod: string
  status: string
  orderTime: number
  addressId: string
  isSuccess: boolean
  cashCollected: boolean
  items: array
```

**b) sellers** - For seller information
```
Document: {sellerId}
Fields:
  sellerId: string
  sellerName: string
  sellerEmail: string
  sellerAvtar: string
  restaurantName: string
  totalEarnings: number
  totalOrders: number
  rating: number
  isApproved: boolean
  joinDate: string
  phoneNumber: string
  address: string
```

### 6. Update Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read orders
    match /orders/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == "YOUR_ADMIN_UID";
    }
    
    // Allow authenticated users to read sellers
    match /sellers/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == "YOUR_ADMIN_UID";
    }
  }
}
```

Replace "YOUR_ADMIN_UID" with your admin user's UID from Firebase Authentication.

### 7. Run the App

```bash
flutter run
```

## Key Features

### Dashboard
- Real-time statistics
- Total orders, commission, sellers, pending orders
- Quick action buttons

### Orders Management
- Filter by status (pending, confirmed, preparing, ready, in_delivery, ended, cancelled)
- View commission breakdown (10% company, 90% seller)
- Update order status
- Track riders and payments

### Sellers Management
- View all sellers
- Filter by approval status
- Approve pending sellers
- Remove sellers
- View seller stats (earnings, orders, rating)

### Commission Tracking
- Real-time commission reports
- Filter by payment method (card, COD)
- Commission statistics
- Transaction history

## Important Notes

### Commission Structure
- **Company receives**: 10% of each order total
- **Seller receives**: 90% of each order total

This is **automatically calculated** in the system.

### Cash on Delivery (COD)
- Track cash collection
- Monitor COD orders separately
- Generate COD reports

### Order Status Flow
```
pending → confirmed → preparing → ready → in_delivery → ended
                                                       → cancelled
```

## Database Integration with Other Apps

### User App (Rider App)
When creating orders, include:
```dart
'companyCommission': totalAmount * 0.10,
'sellerAmount': totalAmount * 0.90,
'paymentMethod': 'card' or 'cash_on_delivery',
'status': 'pending',
```

### Seller App
Save orders to global collection:
```dart
await FirebaseFirestore.instance
    .collection('orders')
    .doc(orderId)
    .set(orderData);
```

### Rider App
Update order status in global collection:
```dart
await FirebaseFirestore.instance
    .collection('orders')
    .doc(orderId)
    .update({'status': 'in_delivery'});
```

## Testing

Test with sample data:

1. **Create test orders** in user app
2. **Login to admin** with admin account
3. **Verify dashboard** shows correct stats
4. **Check commission** calculation (should be 10%)
5. **Update statuses** and verify updates sync
6. **Test filters** on all screens

## Troubleshooting

### Issue: Firebase not initializing
**Solution**: Verify firebase_options.dart has correct credentials

### Issue: Orders not appearing
**Solution**: 
- Check Firestore has 'orders' collection
- Verify security rules allow reads
- Check network connection

### Issue: Commission showing 0
**Solution**:
- Ensure companyCommission field is set when creating orders
- Verify calculation: totalAmount * 0.10

### Issue: Admin login fails
**Solution**:
- Verify admin account exists in Firebase Authentication
- Check email format is correct
- Ensure password is correct

## Environment Setup

### Required SDK Versions
- Flutter: >= 3.0.0
- Dart: >= 3.0.0

### Dependencies
All dependencies are in pubspec.yaml:
- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage
- fluttertoast
- shared_preferences
- intl

## Next Steps

1. ✅ Set up Firebase project
2. ✅ Create Firestore collections
3. ✅ Create admin account
4. ✅ Update security rules
5. ✅ Configure firebase_options.dart
6. ✅ Run the app
7. ✅ Test with sample data
8. ✅ Integrate with user/seller/rider apps

## Additional Resources

- [Firebase Console](https://console.firebase.google.com)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firebase Guide](https://firebase.flutter.dev)

## Support

For detailed integration guide, see: `ADMIN_INTEGRATION_GUIDE.md`
For admin app documentation, see: `admin/README.md`

---

**Status**: ✅ Ready for Setup
**Last Updated**: December 2024
