# Fresh Dine Food Delivery Platform 🚀🍕🍔🍰

A **complete food delivery ecosystem** built with Flutter, featuring a user app, seller app, admin dashboard, and rider app. Multi-platform support with Firebase backend and Razorpay payment integration.

## 🎯 Overview

Fresh Dine is a comprehensive food delivery platform where:
- **Users** can browse restaurants, order food, and track deliveries
- **Sellers** can manage menu items, fulfill orders, and track earnings
- **Admins** can manage sellers, users, and monitor platform activities
- **Riders** can accept deliveries and update order status

## 📂 Project Structure

```
foodDeliveryApp/
│
├── user/                 # 👥 User Mobile App (Flutter)
│   ├── lib/
│   │   ├── authentication/       # Login & Signup
│   │   ├── mainScreens/          # Core screens (Cart, Orders, etc.)
│   │   ├── assistant_methods/    # Business logic
│   │   ├── models/               # Data models
│   │   ├── widgets/              # UI components
│   │   └── global/               # Global config & Firebase
│   ├── android/                  # Android native code
│   ├── ios/                      # iOS native code
│   ├── pubspec.yaml              # Dependencies
│   └── README.md                 # User app documentation
│
├── seller/               # 🏪 Seller Mobile App (Flutter) [In Progress]
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
│
├── admin/                # 👨‍💼 Admin Web Dashboard [In Progress]
│   ├── src/
│   ├── package.json
│   └── README.md
│
└── rider/                # 🚴 Rider Mobile App [In Progress]
    ├── lib/
    ├── pubspec.yaml
    └── README.md
```

## 🚀 Apps & Modules

### 1️⃣ User App ✅ (Complete)
**Status**: Production Ready

Browse restaurants, add items to cart, checkout, and track orders.

**Key Features**:
- 🛍️ Browse items by categories
- 🛒 Shopping cart with real-time sync
- 🏠 Address management with geolocation
- 💳 Razorpay payment integration (4 methods)
- 📦 Order tracking & history
- 🔐 Firebase authentication

**Tech Stack**:
- Flutter 3.0+, Dart
- Firebase (Firestore, Auth, Storage)
- Razorpay API
- Provider (State Management)

**Quick Start**:
```bash
cd user
flutter pub get
flutter run
```

👉 [User App README](./user/README.md)

### 2️⃣ Seller App 🔄 (In Development)
**Status**: In Progress

Sellers can add menu items, manage inventory, and fulfill orders.

**Planned Features**:
- ✅ Add/edit menu items
- ✅ Manage inventory & prices
- ✅ View incoming orders
- ✅ Order fulfillment tracking
- ✅ Earnings dashboard
- ✅ Performance analytics

### 3️⃣ Admin Dashboard 🔄 (In Development)
**Status**: In Progress

Admins manage the platform with comprehensive controls.

**Planned Features**:
- ✅ Seller verification & management
- ✅ User management
- ✅ Order monitoring
- ✅ Revenue analytics
- ✅ Support tickets
- ✅ Platform settings

### 4️⃣ Rider App 🔄 (In Development)
**Status**: In Progress

Riders accept deliveries and manage their routes.

**Planned Features**:
- ✅ Accept delivery orders
- ✅ Real-time GPS tracking
- ✅ Navigation to delivery location
- ✅ Order status updates
- ✅ Earnings tracking
- ✅ Performance ratings

## 🛠️ Technology Stack

### Frontend
| Layer | Technology |
|-------|-----------|
| **Mobile App** | Flutter 3.0+, Dart |
| **Web Dashboard** | React/Vue.js (TBD) |
| **State Management** | Provider, GetX |
| **Local Storage** | SharedPreferences, Hive |
| **Maps** | Google Maps API |
| **UI/UX** | Material Design |

### Backend
| Service | Technology |
|---------|-----------|
| **Database** | Firebase Firestore |
| **Authentication** | Firebase Auth |
| **Storage** | Firebase Cloud Storage |
| **Hosting** | Firebase Hosting |
| **Payments** | Razorpay API |
| **Real-time** | Firestore Streams |

### DevOps
- Version Control: Git & GitHub
- CI/CD: GitHub Actions
- Deployment: Firebase, Google Play, App Store

## 📊 Database Schema

### Firestore Collections

```
/users/{uid}
├── addresses/{addressId}
├── orders/{orderId}
└── cart/

/sellers/{sellerId}
├── menus/{menuId}
│   └── items/{itemId}
├── orders/{orderId}
└── earnings/{docId}

/items/{itemId}

/orders/{orderId}

/admins/{adminId}

/riders/{riderId}
├── earnings/{docId}
└── deliveries/{deliveryId}
```

## 🔐 Security

### Firebase Rules
Role-based access control:
- **Users**: Read/write own data
- **Sellers**: Manage own menu & orders
- **Admins**: Full platform access
- **Riders**: Accept & update deliveries

See `firebase-rules.txt` for complete rules.

## 💳 Payment Integration

### Razorpay Setup
1. Create Razorpay account
2. Get API Key from dashboard
3. Add to each app's payment screen
4. Test with test credentials

**Supported Methods**:
- ✅ Cash on Delivery
- ✅ Credit/Debit Card
- ✅ Digital Wallets (Google Pay, PhonePe, PayTM)
- ✅ Net Banking

## 📈 Order Flow

```
User Orders Item
    ↓
Cart → Checkout → Payment
    ↓
Order Created in Firestore
    ↓
Seller Receives Order
    ↓
Rider Assigned
    ↓
Delivery in Progress
    ↓
Order Delivered
    ↓
Order Complete (History)
```

## 🚦 Status Board

| Component | Status | Progress | Last Updated |
|-----------|--------|----------|--------------|
| **User App** | ✅ Complete | 100% | Dec 22, 2025 |
| **Seller App** | 🔄 In Dev | 30% | - |
| **Admin Dashboard** | 🔄 In Dev | 10% | - |
| **Rider App** | 🔄 In Dev | 20% | - |
| **Payment Integration** | ✅ Complete | 100% | Dec 22, 2025 |
| **Firebase Setup** | ✅ Complete | 100% | Dec 22, 2025 |
| **Testing** | 🔄 In Progress | 60% | Dec 22, 2025 |

## 📋 Recent Commits

- ✅ User App: Complete cart, checkout, payment, orders, and history
- ✅ Fixed cart display with price calculation
- ✅ Razorpay payment integration (4 methods)
- ✅ Order management screens
- ✅ Firebase setup & security rules

## 🎓 Key Learnings & Architecture Decisions

### Cart System
- **Local-first**: Uses SharedPreferences for fast access
- **Sync to Firestore**: Updates persist to user document
- **Format**: `["garbageValue", "itemId:quantity", ...]`

### Order System
- **Dual collection**: Orders stored in user subcollection + main orders collection
- **Status tracking**: Track order progress through different statuses
- **Real-time updates**: Firestore streams for live status

### Payment Architecture
- **Client-side**: Razorpay SDK handles sensitive transactions
- **Server-side**: Order created after successful payment
- **Fallback**: COD option for offline payments

## 🔧 Setup Instructions

### Prerequisites
- Flutter 3.0+ installed
- Firebase account
- Razorpay account
- Android Studio / Xcode

### Firebase Setup
1. Create Firebase project
2. Enable Firestore Database
3. Enable Firebase Auth (Email/Password)
4. Download configuration files
5. Add to respective apps

### Run User App
```bash
cd user
flutter pub get
flutter run
```

### Environment Variables
Create `.env` file in each app:
```
FIREBASE_API_KEY=your_key
RAZORPAY_KEY=your_key
GOOGLE_MAPS_API_KEY=your_key
```

## 🐛 Known Issues

| Issue | Status | Notes |
|-------|--------|-------|
| Items collection architecture | ✅ Identified | Items in seller subcollections, not root |
| Firestore composite indexes | ✅ Fixed | Removed filters requiring indexes |
| Cart display | ✅ Fixed | Now fetches from all seller menus |
| Order price calculation | ✅ Fixed | Uses provider pattern |

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- 🔄 Web (In Progress)
- 🔄 macOS (In Progress)

## 🤝 Contributing

Want to contribute? Follow these steps:

1. **Fork** the repository
2. **Create** feature branch: `git checkout -b feature/YourFeature`
3. **Commit** changes: `git commit -m 'Add YourFeature'`
4. **Push** to branch: `git push origin feature/YourFeature`
5. **Open** Pull Request

### Contribution Areas
- Bug fixes & optimization
- New features for seller/admin/rider
- Documentation improvements
- UI/UX enhancements
- Localization (multiple languages)

## 📚 Documentation

- [User App Guide](./user/README.md)
- [Seller App Guide](./seller/README.md) - Coming Soon
- [Admin Dashboard Guide](./admin/README.md) - Coming Soon
- [Rider App Guide](./rider/README.md) - Coming Soon
- [API Documentation](./API.md) - Coming Soon

## 📞 Contact & Support

- **Email**: nj260106@gmail.com
- **GitHub Issues**: [Report Bug](https://github.com/engnaman7752/foodDeliveryApp/issues)
- **GitHub Discussions**: [Ask Questions](https://github.com/engnaman7752/foodDeliveryApp/discussions)

## 📜 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Firebase** for excellent backend infrastructure
- **Razorpay** for payment gateway integration
- **Flutter & Dart** community for awesome packages
- All contributors and testers

## 📈 Future Roadmap

### Q1 2025
- [ ] Complete Seller App
- [ ] Implement order real-time tracking
- [ ] Add push notifications

### Q2 2025
- [ ] Launch Admin Dashboard
- [ ] Implement Rider App
- [ ] Add analytics & reporting

### Q3 2025
- [ ] Multi-language support
- [ ] Advanced search & filters
- [ ] User ratings & reviews

### Q4 2025
- [ ] Web platform launch
- [ ] Loyalty program
- [ ] Promotional system

## 🎯 Key Metrics

| Metric | Value |
|--------|-------|
| **Lines of Code** | 10,000+ |
| **Flutter Files** | 50+ |
| **Firebase Collections** | 8+ |
| **API Integrations** | 2 (Firebase, Razorpay) |
| **Screens** | 20+ |
| **Widgets** | 40+ |

---

**Created By**: Naman  
**Email**: nj260106@gmail.com  
**GitHub**: [engnaman7752](https://github.com/engnaman7752)  
**Last Updated**: December 22, 2025  
**Version**: 1.0.0  

**Status**: ✅ User App Production Ready | 🔄 Other Apps In Development

---

### Quick Links
- 🌟 [Star the Repository](https://github.com/engnaman7752/foodDeliveryApp)
- 🔀 [Fork the Repository](https://github.com/engnaman7752/foodDeliveryApp/fork)
- 📧 [Get In Touch](mailto:engnaman7752@gmail.com)
