import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<DocumentSnapshot?> getUserData() async {
    if (currentUserId == null) return null;

    try {
      return await _firestore.collection('users').doc(currentUserId).get();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData({
    String? name,
    String? email,
    String? phone,
    String? plateNumber,
  }) async {
    if (currentUserId == null) return;

    Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (plateNumber != null) data['plateNumber'] = plateNumber;

    try {
      await _firestore.collection('users').doc(currentUserId).update(data);

      // Update email in Firebase Auth if it changed
      if (email != null && email != currentUser?.email) {
        await currentUser?.updateEmail(email);
      }
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    if (currentUser == null) return;

    try {
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Error updating password: $e');
      throw e;
    }
  }

  // Check if user is a driver
  Future<bool> isDriver() async {
    if (currentUserId == null) return false;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUserId).get();
      return doc.exists && doc.get('userType') == 'Driver';
    } catch (e) {
      print('Error checking user type: $e');
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('Logged out successfully');
    } catch (e) {
      print('Error logging out: $e');
      throw e;
    }
  }

  // Methods to add when implementing real authentication:

  // Create a new user in Firestore after signup
  Future<void> createUserDocument({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String userType,
    String? plateNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'userType': userType,
        'plateNumber': plateNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
      throw e;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
    String? plateNumber,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await createUserDocument(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        plateNumber: plateNumber,
      );

      return userCredential;
    } catch (e) {
      print('Error signing up: $e');
      throw e;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      throw e;
    }
  }
}
