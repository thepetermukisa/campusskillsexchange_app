import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload Image to ImgBB
  Future<String?> uploadImage(XFile image, String path) async {
    try {
      final apiKey = dotenv.env['IMGBB_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("ImgBB API key not found in .env file.");
      }

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://api.imgbb.com/1/upload');
      final response = await http.post(url, body: {
        'key': apiKey,
        'image': base64Image,
      }).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception("Image upload timed out. Please check your connection.");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        debugPrint('ImgBB Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Update User Verification Status
  Future<void> updateUserVerificationStatus(String uid, String studentIdUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'studentIdUrl': studentIdUrl,
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
    // Log activity
    await logActivity(
      type: 'request',
      message: '${requestData['requesterName'] ?? 'Someone'} posted a new request: "${requestData['title'] ?? ''}"',
    );
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

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({'status': status});
  }

  Stream<List<Map<String, dynamic>>> getReviews(String targetId) {
    return _firestore
        .collection('reviews')
        .where('targetId', isEqualTo: targetId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Activity Log ---
  Future<void> logActivity({
    required String type,
    required String message,
  }) async {
    try {
      await _firestore.collection('activity').add({
        'type': type,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to log activity: $e');
    }
  }

  // --- Applications ---
  Future<void> submitApplication(Map<String, dynamic> applicationData) async {
    await _firestore.collection('applications').add({
      ...applicationData,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getApplicationsForJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> getMyApplications(String applicantId) {
    return _firestore
        .collection('applications')
        .where('applicantId', isEqualTo: applicantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': status,
    });
  }

  /// Returns true if [applicantId] has already applied to [jobId].
  Future<bool> hasApplied(String jobId, String applicantId) async {
    final snap = await _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .where('applicantId', isEqualTo: applicantId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
