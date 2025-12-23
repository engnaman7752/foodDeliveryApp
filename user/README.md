# Fresh Dine - Customer App 🍔🍕🍰

A complete **Flutter Food Delivery Application** where users can browse restaurants, add items to cart, checkout with multiple payment methods, and track orders in real-time.

## 📋 Features

### 🛍️ Shopping
- ✅ Browse food items by categories (Burger, Pizza, Cake, Veg, Non-Veg, Dining)
- ✅ Search and filter items
- ✅ View detailed item information
- ✅ Add items to cart with quantity control
- ✅ Update quantities easily

### 🛒 Cart Management
- ✅ Display cart items with prices
- ✅ Calculate total amount automatically
- ✅ Remove items from cart
- ✅ Real-time cart synchronization

### 🏠 Address Management
- ✅ Save multiple delivery addresses
- ✅ Geolocation support (auto-detect location)
- ✅ Edit and delete addresses
- ✅ Select address at checkout
- ✅ View address on map

### 💳 Payment Integration
- ✅ **Razorpay Payment Gateway** with 4 methods:
  - Cash on Delivery (COD)
  - Credit/Debit Card
  - Digital Wallets (Google Pay, PhonePe, PayTM)
  - Net Banking
- ✅ Secure payment processing
- ✅ Payment confirmation

### 📦 Order Management
- ✅ View current orders (My Orders)
- ✅ View order history
- ✅ Track order status
- ✅ Order details with total amount and items

### 👤 User Authentication
- ✅ Email/Password signup & login
- ✅ Firebase Authentication
- ✅ Persistent login sessions

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences

### Backend
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **Hosting**: Firebase Cloud Storage
- **Payment**: Razorpay API

### Libraries
```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^5.5.2
  firebase_auth: ^4.10.0
  firebase_core: ^2.20.0
  provider: ^6.1.2
  razorpay_flutter: ^1.3.7
  shared_preferences: ^2.3.3
  geolocator: ^11.0.0
  geocoding: ^3.0.2
  image_picker: ^1.0.0
  fluttertoast: ^8.2.2
```

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point
├── assistant_methods/
│   ├── assistant_methods.dart          # Cart & order utilities
│   ├── cart_item_counter.dart          # Cart counter provider
│   ├── address_changer.dart            # Address selection provider
│   └── total_ammount.dart              # Total amount provider
├── authentication/
│   ├── login_screen.dart               # User login
│   └── signup_screen.dart              # User registration
├── mainScreens/
│   ├── home_screen.dart                # Home page
│   ├── cart_screen.dart                # Shopping cart
│   ├── address_screen.dart             # Address selection
│   ├── save_address_screen.dart        # Add/edit address
│   ├── payment_screen.dart             # Payment method selection
│   ├── placed_order_screen.dart        # Order summary & payment
│   ├── my_orders_screen.dart           # Current orders
│   ├── history_screen.dart             # Order history
│   ├── order_details_screen.dart       # Order details
│   └── item_detail_screen.dart         # Item details
├── models/
│   ├── items.dart                      # Item model
│   ├── address.dart                    # Address model
│   └── order.dart                      # Order model
├── widgets/
│   ├── cart_item_design.dart           # Cart item UI
│   ├── address_design.dart             # Address card UI
│   ├── order_card.dart                 # Order card UI
│   └── progress_bar.dart               # Loading indicator
├── global/
│   └── global.dart                     # Global variables & Firebase instances
└── splashScreen/
    └── splash_screen.dart              # App startup screen
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+ installed
- Firebase project setup
- Razorpay account (for payments)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/engnaman7752/foodDeliveryApp.git
   cd foodDeliveryApp/user
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Download `google-services.json` from Firebase Console
   - Place in `android/app/`
   - Update `android/build.gradle` and `android/app/build.gradle`

4. **Set Razorpay Key**
   - Open `lib/mainScreens/placed_order_screen.dart`
   - Replace `rzp_test_Rue7Nc7QeqKlst` with your Razorpay Key ID

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Key Screens
- **Home Screen**: Browse items by categories
- **Cart Screen**: View items with prices and totals
- **Address Screen**: Select or add delivery address
- **Payment Screen**: Choose payment method
- **Order Screen**: Confirm order and pay
- **My Orders**: Track active orders
- **History**: View past orders

## 🔐 Firebase Setup

### Firestore Collections Structure
```
users/
├── {uid}/
│   ├── addresses/
│   │   └── {addressId}
│   └── orders/
│       └── {orderId}
│
items/
├── {itemId}
│
orders/
└── {orderId}
```

### Security Rules
See `firebase-rules.txt` for complete security rules with role-based access (users, sellers, admins).

## 💰 Payment Integration

### Razorpay Setup
1. Get API Key from Razorpay Dashboard
2. Update in `placed_order_screen.dart`
3. Amount is automatically converted to paise (₹ × 100)

### Supported Payment Methods
- Cash on Delivery (No transaction needed)
- Online Payments via Razorpay

## 🐛 Known Issues & Fixes

| Issue | Status | Solution |
|-------|--------|----------|
| Cart items not displaying | ✅ Fixed | Fetch prices from seller subcollections |
| Order price showing 0 | ✅ Fixed | Use TotalAmmount provider instead of local variable |
| Firestore index errors | ✅ Fixed | Removed composite index requirements |
| Empty cart handling | ✅ Fixed | Added null safety checks |

## 📊 Order Flow

```
Home Screen
    ↓
Item Detail (Add to Cart)
    ↓
Cart Screen (View & Checkout)
    ↓
Address Screen (Select Address)
    ↓
Payment Screen (Choose Method)
    ↓
Placed Order Screen (Review & Pay)
    ↓
Order Confirmation
    ↓
My Orders / History
```

## 🔄 Data Flow

```
Cart (SharedPreferences)
    ↓ (on checkout)
Firestore (users/{uid}/orders)
    ↓ (fetch)
My Orders / History Screens
```

## 📝 Recent Updates (v1.0)

- ✅ Complete cart system with price calculation
- ✅ Razorpay payment integration
- ✅ Order placement & tracking
- ✅ Address management with geolocation
- ✅ My Orders & History screens
- ✅ Bug fixes for empty cart & price calculations

## 🚧 Future Enhancements

- [ ] Order tracking with real-time updates
- [ ] Rider location tracking
- [ ] Push notifications for order status
- [ ] Rating & review system
- [ ] Wishlist feature
- [ ] Referral program
- [ ] In-app chat with sellers

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 📞 Support

For issues or questions:
- Email: nj260106@gmail.com
- GitHub Issues: [Report Bug](https://github.com/engnaman7752/foodDeliveryApp/issues)

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- Razorpay for payment gateway
- Flutter & Dart community
- All contributors

---

**Last Updated**: December 22, 2025
**Version**: 1.0.0
**Status**: ✅ Production Ready

