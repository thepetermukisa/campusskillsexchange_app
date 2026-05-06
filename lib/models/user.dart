class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'student', 'company', 'administrator'
  final bool isVerified;
  final List<String> subSkills;
  final List<String> portfolioUrls;
  final int completedJobs;
  final double rating;
  final List<String> endorsements;
  final String? profileImageUrl;
  final int reviews;
  final int hostingYears;

  final double walletBalance;

  final String? studentIdUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isVerified = false,
    this.subSkills = const [],
    this.portfolioUrls = const [],
    this.completedJobs = 0,
    this.rating = 0.0,
    this.endorsements = const [],
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
      'email': email,
      'role': role.toLowerCase(),
      'isVerified': isVerified,
      'subSkills': subSkills,
      'portfolioUrls': portfolioUrls,
      'completedJobs': completedJobs,
      'rating': rating,
      'endorsements': endorsements,
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
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      isVerified: map['isVerified'] ?? false,
      subSkills: List<String>.from(map['subSkills'] ?? []),
      portfolioUrls: List<String>.from(map['portfolioUrls'] ?? []),
      completedJobs: map['completedJobs'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      endorsements: List<String>.from(map['endorsements'] ?? []),
      profileImageUrl: map['profileImageUrl'],
      reviews: map['reviews'] ?? 0,
      hostingYears: map['hostingYears'] ?? 0,
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      studentIdUrl: map['studentIdUrl'],
    );
  }
}
