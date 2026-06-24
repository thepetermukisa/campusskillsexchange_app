import 'role.dart';

class User {
  final String id;
  final String name;
  final String bio;
  final String email;
  final Role role; // typed Role enum
  final bool isVerified;
  final List<String> subSkills;
  final List<String> portfolioUrls;
  final int completedJobs;
  final double rating;
  final List<String> endorsements;
  final bool isBanned;
  final String? profileImageUrl;
  final int reviews;
  final int hostingYears;

  final double walletBalance;

  final String? studentIdUrl;

  User({
    required this.id,
    required this.name,
    this.bio = '',
    required this.email,
    required this.role,
    this.isVerified = false,
    this.subSkills = const [],
    this.portfolioUrls = const [],
    this.completedJobs = 0,
    this.rating = 0.0,
    this.endorsements = const [],
    this.isBanned = false,
    this.profileImageUrl,
    this.reviews = 0,
    this.hostingYears = 0,
    this.walletBalance = 0.0,
    this.studentIdUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'email': email,
      'role': RoleHelper.toStringValue(role),
      'isVerified': isVerified,
      'subSkills': subSkills,
      'portfolioUrls': portfolioUrls,
      'completedJobs': completedJobs,
      'rating': rating,
      'endorsements': endorsements,
      'isBanned': isBanned,
      'profileImageUrl': profileImageUrl,
      'reviews': reviews,
      'hostingYears': hostingYears,
      'walletBalance': walletBalance,
      'studentIdUrl': studentIdUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      email: map['email'] ?? '',
      role: RoleHelper.fromString(map['role']),
      isVerified: map['isVerified'] ?? false,
      subSkills: List<String>.from(map['subSkills'] ?? []),
      portfolioUrls: List<String>.from(map['portfolioUrls'] ?? []),
      completedJobs: map['completedJobs'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      endorsements: List<String>.from(map['endorsements'] ?? []),
      isBanned: map['isBanned'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      reviews: map['reviews'] ?? 0,
      hostingYears: map['hostingYears'] ?? 0,
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      studentIdUrl: map['studentIdUrl'],
    );
  }
}
