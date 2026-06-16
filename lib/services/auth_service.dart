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
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await ensureUserDocument(user);
    }

    return userCredential;
  }

  // Sign Up
  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    // 1. Create Auth User
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Create User Document in Firestore
    if (userCredential.user != null) {
      await userCredential.user!.updateDisplayName(name);
      await ensureUserDocument(userCredential.user!, name: name, role: role);
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
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('role').toString().toLowerCase();
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }
    return null;
  }

  Future<String> ensureUserDocument(
    User user, {
    String? name,
    String? role,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final normalizedRole =
        (role == null || role.trim().isEmpty ? 'student' : role)
            .trim()
            .toLowerCase();

    if (snapshot.exists) {
      final data = snapshot.data() ?? {};
      final existingRole = data['role']?.toString().toLowerCase();

      final updates = <String, dynamic>{};
      if (data['id'] == null) updates['id'] = user.uid;
      if ((data['email'] as String?)?.isEmpty ?? true) {
        updates['email'] = user.email ?? '';
      }
      if ((data['name'] as String?)?.isEmpty ?? true) {
        updates['name'] = name ?? user.displayName ?? user.email ?? 'User';
      }
      if (existingRole == null || existingRole.isEmpty) {
        updates['role'] = normalizedRole;
      }

      if (updates.isNotEmpty) {
        await userRef.set(updates, SetOptions(merge: true));
      }

      return existingRole ?? normalizedRole;
    }

    await userRef.set(_defaultUserData(user, name: name, role: normalizedRole));
    return normalizedRole;
  }

  Map<String, dynamic> _defaultUserData(
    User user, {
    String? name,
    required String role,
  }) {
    return {
      'id': user.uid,
      'name': name ?? user.displayName ?? user.email ?? 'User',
      'email': user.email ?? '',
      'role': role,
      'isVerified': false,
      'subSkills': <String>[],
      'portfolioUrls': <String>[],
      'completedJobs': 0,
      'rating': 0.0,
      'endorsements': <String>[],
      'profileImageUrl': null,
      'reviews': 0,
      'hostingYears': 0,
      'walletBalance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
