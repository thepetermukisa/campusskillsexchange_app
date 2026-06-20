import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/role.dart';

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
  Future<Role?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final roleRaw = doc.get('role')?.toString();
        return RoleHelper.fromString(roleRaw);
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }
    return null;
  }

  Future<Role> ensureUserDocument(
    User user, {
    String? name,
    String? role,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final normalizedRole = RoleHelper.fromString(role);

    if (snapshot.exists) {
      final data = snapshot.data() ?? {};
      final existingRoleRaw = data['role']?.toString();
      final existingRole = (existingRoleRaw == null || existingRoleRaw.toString().trim().isEmpty)
          ? null
          : RoleHelper.fromString(existingRoleRaw);

      final updates = <String, dynamic>{};
      if (data['id'] == null) updates['id'] = user.uid;
      if ((data['email'] as String?)?.isEmpty ?? true) {
        updates['email'] = user.email ?? '';
      }
      if ((data['name'] as String?)?.isEmpty ?? true) {
        updates['name'] = name ?? user.displayName ?? user.email ?? 'User';
      }
      if (existingRole == null) {
        updates['role'] = RoleHelper.toStringValue(normalizedRole);
      }

      if (updates.isNotEmpty) {
        await userRef.set(updates, SetOptions(merge: true));
      }

      return existingRole ?? normalizedRole;
    }

    await userRef.set(_defaultUserData(user, name: name, role: RoleHelper.toStringValue(normalizedRole)));
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
