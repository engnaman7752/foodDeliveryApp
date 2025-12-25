import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if user is admin
  static Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get admin user details
  static Future<Map<String, dynamic>?> getAdminDetails(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Admin login with role verification
  static Future<String?> loginAdmin(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Check if user is admin
      bool adminStatus = await isAdmin(userCredential.user!.uid);

      if (!adminStatus) {
        // User is not an admin, sign them out
        await _auth.signOut();
        return 'error: User is not an admin';
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return 'error: ${e.message}';
    } catch (e) {
      return 'error: An error occurred';
    }
  }

  /// Create admin account (only by existing admin)
  static Future<String?> createAdminAccount({
    required String email,
    required String password,
    required String adminName,
    required String adminRole,
  }) async {
    try {
      // Create auth account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create admin document in Firestore
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'name': adminName,
        'role': adminRole, // e.g., 'super_admin', 'manager', 'staff'
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return 'error: ${e.message}';
    } catch (e) {
      return 'error: An error occurred';
    }
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;
    return await isAdmin(user.uid);
  }

  /// Get current user admin details
  static Future<Map<String, dynamic>?> getCurrentAdminDetails() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    return await getAdminDetails(user.uid);
  }

  /// Logout admin
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Update admin profile
  static Future<String?> updateAdminProfile({
    required String uid,
    required String name,
    required String role,
  }) async {
    try {
      await _firestore.collection('admins').doc(uid).update({
        'name': name,
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'error: ${e.toString()}';
    }
  }

  /// Get all admins (for management)
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Deactivate admin account
  static Future<String?> deactivateAdmin(String uid) async {
    try {
      await _firestore.collection('admins').doc(uid).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'error: ${e.toString()}';
    }
  }
}
