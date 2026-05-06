import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/review.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String targetId;
  final String targetName;

  const SubmitReviewScreen({
    super.key,
    required this.targetId,
    required this.targetName,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      final review = Review(
        id: '',
        reviewerId: user.uid,
        reviewerName: userName,
        targetId: widget.targetId,
        rating: _rating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseService().submitReview(review.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rate your experience with ${widget.targetName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFF6B6B),
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1.0),
                );
              }),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _commentController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 48),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
