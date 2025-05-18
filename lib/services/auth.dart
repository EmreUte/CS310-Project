import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/welcome_page.dart';
import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyUser? _userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  Stream<MyUser?> get user {
    return _auth.authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }

  // Sign in email pass
  Future signInEmailPass(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await DatabaseService(uid: user.uid).setOnlineStatus(true);
      }
      return _userFromFirebaseUser(user);
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email pass
  Future registerEmailPass(String name, String email, String phone, String plateNumber, int cardCount, String password, String userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      await DatabaseService(uid: user!.uid).updateUserData(name, email, phone, plateNumber, userType, cardCount);
      return _userFromFirebaseUser(user);
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await DatabaseService(uid: user.uid).setOnlineStatus(false); 
      }
      return await _auth.signOut();
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Re-authenticate and delete account (user doc, emails, and auth) and navigate to welcome page
  Future<bool> reauthenticateAndDeleteAccount({
    required String uid,
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);

      // Delete Firestore user doc and emails
      await DatabaseService(uid: uid).deleteUserAndEmails();

      // Delete Firebase Auth user
      await user.delete();

      // Sign out (just in case)
      await signOut();
      
      // If context was provided, navigate to welcome page
      if (context != null) {
        // Add a short delay to ensure auth state changes are processed
        await Future.delayed(Duration(milliseconds: 200));
        
        // Use a post-frame callback to ensure navigation happens after any frame rebuilds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Navigate to the welcome page and clear the navigation stack
          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            'welcome',
            (route) => false,
          );
        });
      }
      
      return true;
    } catch (e) {
      print("Delete account error: $e");
      return false;
    }
  }
}
