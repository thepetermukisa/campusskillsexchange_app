import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetId; // Skill ID or User ID being reviewed
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, String documentId) {
    return Review(
      id: documentId,
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      targetId: map['targetId'] ?? '',
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
