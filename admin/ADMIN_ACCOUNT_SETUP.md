# Admin Account Setup - Required Steps

## Why Login is Failing

The admin app checks if a user is an admin by looking in the **"admins"** Firestore collection. If no admin document exists, the login fails with "User is not an admin".

---

## Step 1: Create Authentication User

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **food-delivery-app-7752**
3. Go to **Authentication** → **Users** tab
4. Click **"Add user"** button
5. Enter:
   - **Email**: `admin@fooddelivery.com`
   - **Password**: `Admin@12345` (or your choice)
6. Click **"Add user"**
7. **Copy the UID** from the user (you'll need it for step 2)

---

## Step 2: Create Admin Document in Firestore

1. Go to **Firestore Database**
2. Click **"Create collection"**
3. Name: `admins`
4. Click **"Next"**
5. Click **"Auto ID"** to auto-generate the document ID
6. Add these fields:

```json
{
  "uid": "PASTE_THE_UID_FROM_STEP_1",
  "email": "admin@fooddelivery.com",
  "name": "Admin Name",
  "role": "super_admin",
  "isActive": true,
  "createdAt": (current timestamp)
}
```

**Example with actual data:**
```json
{
  "uid": "xYzAbC123DEF456GHI789",
  "email": "admin@fooddelivery.com",
  "name": "Company Admin",
  "role": "super_admin",
  "isActive": true,
  "createdAt": 1703429400
}
```

7. Click **"Save"**

---

## Step 3: Login to Admin App

Now try logging in with:
- **Email**: `admin@fooddelivery.com`
- **Password**: `Admin@12345`

The app will:
1. Authenticate via Firebase Auth
2. Check if admin document exists in "admins" collection
3. If both match → Login successful ✅
4. If no admin document → Error "User is not an admin" ❌

---

## Quick Checklist

- [ ] Authentication user created with email: `admin@fooddelivery.com`
- [ ] Copied the UID from Firebase Auth
- [ ] Created "admins" collection
- [ ] Created admin document with matching UID
- [ ] All required fields added (uid, email, name, role, isActive)
- [ ] Try login again

---

## If Still Getting Error

**Error**: "User is not an admin"
**Cause**: Admin document doesn't exist or UID doesn't match
**Fix**: Verify the UID in the admin document matches the UID from Firebase Authentication

---

## Creating Additional Admins Later

Once you have one admin, you can create more by:

1. Creating the authentication user in Firebase Auth
2. Getting their UID
3. Creating a new document in the "admins" collection with that UID

You can have different roles:
- `super_admin` - Full access
- `manager` - Manage orders and sellers
- `staff` - View-only access

