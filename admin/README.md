# Admin Portal - Food Delivery Company Management

A comprehensive Flutter admin application for managing food delivery orders, sellers, and commissions.

## Features

### 1. **Dashboard**
- Real-time overview of key metrics
- Total orders count
- Total commission earned (10% from each order)
- Active sellers count
- Pending orders count
- Quick action buttons for easy navigation

### 2. **Orders Management**
- View all orders with filtering by status
- Order statuses: pending, confirmed, preparing, ready, in_delivery, ended, cancelled
- Display commission breakdown for each order:
  - Total order amount
  - Company commission (10%)
  - Seller amount (90%)
- Update order status in real-time
- View detailed order information
- Track payment method (Card or Cash on Delivery)
- Assign and track riders

### 3. **Sellers Management**
- View all sellers with approval status
- Filter sellers by: all, approved, pending
- Seller statistics:
  - Total orders served
  - Total earnings
  - Rating
- Approve pending sellers
- Remove sellers from the platform
- View complete seller details

### 4. **Commission Tracking**
- Real-time commission statistics
- Filter by payment method:
  - All Orders
  - Card Payments
  - Cash on Delivery
- Commission breakdown showing:
  - Total commission earned
  - Card payment commission
  - Cash on Delivery commission
- Detailed transaction history
- Commission per order display

## Commission Structure

The system automatically calculates commissions:
- **Company Commission**: 10% of order amount
- **Seller Amount**: 90% of order amount

### Cash on Delivery (COD) Support
- Track cash collection status
- Monitor COD orders separately
- Generate COD-specific reports

## Firebase Database Structure

### Orders Collection
```
orders/{orderId}
├── orderId: string
├── userId: string
├── sellerId: string
├── sellerName: string
├── riderAssigned: string
├── riderName: string
├── totalAmount: number
├── companyCommission: number (10% of total)
├── sellerAmount: number (90% of total)
├── paymentMethod: string ("card" or "cash_on_delivery")
├── status: string (order status)
├── orderTime: number (timestamp)
├── deliveryTime: number (timestamp)
├── addressId: string
├── isSuccess: boolean
├── cashCollected: boolean (for COD orders)
└── items: array (order items)
```

### Sellers Collection
```
sellers/{sellerId}
├── sellerId: string
├── sellerName: string
├── sellerEmail: string
├── sellerAvtar: string
├── restaurantName: string
├── totalEarnings: number
├── totalOrders: number
├── rating: number
├── isApproved: boolean
├── joinDate: string
├── phoneNumber: string
└── address: string
```

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Firebase project setup
- Dart SDK

### Installation

1. **Navigate to the admin app directory**
```bash
cd admin
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Update `lib/firebase_options.dart` with your Firebase credentials
- Ensure Firestore and Authentication are enabled in Firebase Console

4. **Run the application**
```bash
flutter run
```

## Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Firestore Database
3. Enable Firebase Authentication (Email/Password)
4. Create an admin account for login
5. Copy your Firebase config to `firebase_options.dart`

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin access to orders
    match /orders/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == "ADMIN_UID"; // Set your admin UID
    }
    
    // Admin access to sellers
    match /sellers/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == "ADMIN_UID";
    }
  }
}
```

## User Interface

### Color Scheme
- Primary: `#6200EA` (Purple)
- Secondary: `#03DAC6` (Teal)
- Accent: `#FF6D00` (Orange)
- Error: `#FD1D1D` (Red)

### Navigation
- **Bottom Navigation Bar** with 4 main sections:
  1. Dashboard
  2. Orders Management
  3. Sellers Management
  4. Commission Tracking

## Key Functionalities

### Admin Login
- Email and password authentication
- Secure Firebase Authentication
- Session management

### Order Management
- Real-time order updates
- Status tracking
- Commission calculation
- Payment method tracking
- COD cash collection status

### Seller Management
- Approval workflow
- Performance metrics
- Contact information
- Earnings tracking

### Commission Reports
- Comprehensive reports
- Filter by payment method
- Export capabilities (can be extended)
- Real-time calculations

## Models

### OrderModel
- Complete order information
- Commission calculations
- Helper methods for data conversion

### SellerModel
- Seller profile information
- Performance metrics
- Account status

### CommissionReport
- Commission tracking
- Transaction details
- Status tracking

## Future Enhancements

1. **Export Reports**
   - PDF exports
   - CSV downloads
   - Monthly reports

2. **Analytics**
   - Revenue trends
   - Seller performance charts
   - Order analytics

3. **Notifications**
   - Real-time alerts for new orders
   - Seller approval notifications
   - Commission alerts

4. **Advanced Filtering**
   - Date range filters
   - Amount range filters
   - Seller-specific reports

5. **Payment Management**
   - Seller payout scheduling
   - Payment history
   - Transaction disputes

## Testing

To test the admin portal:

1. Create a test Firebase account with admin privileges
2. Use test orders and sellers
3. Monitor real-time updates
4. Test filtering and sorting features

## Support

For issues or questions:
1. Check Firebase Console for errors
2. Review Firestore Security Rules
3. Verify Firebase credentials
4. Check network connectivity

## License

This project is part of the Food Delivery Application Suite.

## Project Structure

```
admin/
├── lib/
│   ├── authentication/
│   │   └── admin_auth_screen.dart
│   ├── screens/
│   │   ├── admin_login.dart
│   │   ├── admin_dashboard.dart
│   │   ├── orders_management_screen.dart
│   │   ├── sellers_management_screen.dart
│   │   └── commission_tracking_screen.dart
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── seller_model.dart
│   │   └── commission_report.dart
│   ├── global/
│   │   └── global.dart
│   ├── main.dart
│   └── firebase_options.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

**Note**: Update Firebase configuration and admin credentials before deploying to production.
