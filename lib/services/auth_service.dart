import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Sign In
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up
  Future<UserCredential> signUp(String email, String password, String name, String role) async {
    // 1. Create Auth User
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Create User Document in Firestore
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role.toLowerCase(),
        'isVerified': false,
        'subSkills': [],
        'portfolioUrls': [],
        'completedJobs': 0,
        'rating': 0.0,
        'endorsements': [],
        'profileImageUrl': null,
        'reviews': 0,
        'hostingYears': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.get('role');
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }
    return null;
  }
}
