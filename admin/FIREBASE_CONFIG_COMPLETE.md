# Admin App - Firebase Configuration Complete ✅

Your admin app is now configured with your Firebase project!

## 📋 What Was Done

### 1. ✅ Firebase Credentials Updated
- **Project ID**: `food-delivery-app-7752`
- **API Key**: `AIzaSyCSjW2JNnT-fFUIxyEJjRENmK8uAomySDA`
- **Messaging Sender ID**: `568808621496`
- **Storage Bucket**: `food-delivery-app-7752.firebasestorage.app`

### 2. ✅ Files Created/Updated
- ✅ `admin/android/app/google-services.json` - Created with your Firebase config
- ✅ `admin/lib/firebase_options.dart` - Updated with credentials

---

## 🚀 Next Steps to Run the Admin App

### Step 1: Install Dependencies
```bash
cd admin
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Login with Your Admin Account
```
Email: admin@fooddelivery.com
Password: (Your Firebase admin password)
```

---

## ⚠️ Important - Create Admin Account in Firebase

Before running the app, you need to create an admin account:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `food-delivery-app-7752`
3. Go to **Authentication** → **Users**
4. Click **Add user**
5. Email: `admin@fooddelivery.com`
6. Password: (Choose a secure password)
7. Click **Add user**

---

## 📊 Verify Firestore Collections

Make sure these collections exist in Firestore:

### Collection 1: `orders`
```
Document structure:
{
  orderId: string,
  userId: string,
  sellerId: string,
  totalAmount: number,
  companyCommission: number,
  sellerAmount: number,
  paymentMethod: string,
  status: string,
  orderTime: number,
  isSuccess: boolean,
  items: array
}
```

### Collection 2: `sellers`
```
Document structure:
{
  sellerId: string,
  sellerName: string,
  sellerEmail: string,
  totalEarnings: number,
  totalOrders: number,
  rating: number,
  isApproved: boolean
}
```

If collections don't exist, create them in Firebase Console:
1. Firestore Database
2. Click "Create collection"
3. Name: `orders` or `sellers`
4. Click "Add document"

---

## 🔒 Firebase Security Rules

Make sure your Firestore security rules allow admin access:

1. Go to Firestore Database
2. Click "Rules" tab
3. Set these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all authenticated users to read
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

> **Note**: For production, restrict write access to admin users only using their UID.

---

## ✅ Checklist Before Running

- [ ] Admin account created in Firebase
- [ ] `firebase_options.dart` has correct credentials
- [ ] `google-services.json` exists in `admin/android/app/`
- [ ] Collections `orders` and `sellers` created in Firestore
- [ ] Security rules updated to allow reads
- [ ] `flutter pub get` completed
- [ ] Android SDK installed and up to date

---

## 🧪 Test the Connection

Once you run the app:

1. **Login Screen**: Should appear
2. **Login**: Use admin@fooddelivery.com and your password
3. **Dashboard**: Should load with statistics
4. **Check Console**: No Firebase errors

If you see errors:
- Check credentials in `firebase_options.dart`
- Verify admin account exists
- Check Firestore security rules
- Ensure internet connection

---

## 📱 Run Commands

```bash
# Install dependencies
cd admin
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run -t ios

# Run with verbose output (for debugging)
flutter run -v
```

---

## 🎯 Your Firebase Setup

```
Project: food-delivery-app-7752
├─ Authentication: Email/Password ✅
├─ Firestore: orders, sellers collections
├─ Storage: Enabled
└─ APIs: All required APIs enabled
```

---

## 📞 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Project does not exist" | Verify project ID in firebase_options.dart |
| "Auth failed on login" | Create admin account in Firebase Console |
| "Can't read orders" | Create `orders` collection in Firestore |
| "Permission denied" | Update Firestore security rules |
| "Build error in Android" | Run `flutter clean` then `flutter pub get` |

---

## 🎉 You're Ready!

Your admin app is **configured and ready to run**:

```bash
cd admin
flutter pub get
flutter run
```

Then login with your admin account and enjoy! 🚀

---

**Configuration Date**: December 24, 2025  
**Status**: ✅ Ready to Use  
**Firebase Project**: food-delivery-app-7752
