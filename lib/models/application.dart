import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String jobId;
  final String jobTitle;
  final String applicantId;
  final String applicantName;
  final String employerId;
  final String message;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime createdAt;

  Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.applicantId,
    required this.applicantName,
    required this.employerId,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'employerId': employerId,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Application.fromMap(Map<String, dynamic> map, String documentId) {
    return Application(
      id: documentId,
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      applicantId: map['applicantId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      employerId: map['employerId'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
