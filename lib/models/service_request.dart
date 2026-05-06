import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  final String id;
  final String title;
  final String description;
  final String category;
  final String requesterId;
  final String requesterName;
  final double budget;
  final DateTime deadline;
  final String status; // 'open', 'in_progress', 'completed', 'cancelled'
  final DateTime createdAt;
  final String? matchedExpertId;

  ServiceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.requesterId,
    required this.requesterName,
    required this.budget,
    required this.deadline,
    this.status = 'open',
    required this.createdAt,
    this.matchedExpertId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'budget': budget,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'matchedExpertId': matchedExpertId,
    };
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceRequest(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      status: map['status'] ?? 'open',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      matchedExpertId: map['matchedExpertId'],
    );
  }
}
