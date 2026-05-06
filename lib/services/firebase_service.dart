import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload Image to Firebase Storage
  Future<String?> uploadImage(XFile image, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      
      if (kIsWeb) {
        // For web, use putData
        final bytes = await image.readAsBytes();
        await ref.putData(bytes);
      } else {
        // For mobile, use putFile
        await ref.putFile(File(image.path));
      }
      
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Update User Verification Status
  Future<void> updateUserVerificationStatus(String uid, String idImageUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'idImageUrl': idImageUrl,
      'verificationStatus': 'pending', // pending, verified, rejected
    });
  }

  // Get Service Requests
  Stream<List<Map<String, dynamic>>> getServiceRequests() {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // Post Service Request
  Future<void> postServiceRequest(Map<String, dynamic> requestData) async {
    await _firestore.collection('requests').add({
      ...requestData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update User
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Add Skill
  Future<void> addSkill(Map<String, dynamic> skillData) async {
    await _firestore.collection('skills').add({
      ...skillData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Reviews ---
  Future<void> submitReview(Map<String, dynamic> reviewData) async {
    await _firestore.collection('reviews').add({
      ...reviewData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Rating aggregation logic
    final targetId = reviewData['targetId'];
    if (targetId != null) {
      final reviewsSnap = await _firestore
          .collection('reviews')
          .where('targetId', isEqualTo: targetId)
          .get();
      
      if (reviewsSnap.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnap.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        double avgRating = totalRating / reviewsSnap.docs.length;
        
        await _firestore.collection('users').doc(targetId).update({
          'rating': avgRating,
          'reviewCount': reviewsSnap.docs.length,
        });
      }
    }
  }

  // --- Service Requests ---
  Future<void> deleteServiceRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).delete();
  }

  Future<void> updateServiceRequest(String requestId, Map<String, dynamic> data) async {
    await _firestore.collection('requests').doc(requestId).update(data);
  }

  Stream<List<Map<String, dynamic>>> getReviews(String targetId) {
    return _firestore
        .collection('reviews')
        .where('targetId', isEqualTo: targetId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
