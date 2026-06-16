class Skill {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> userIds; // IDs of users who offer this skill
  final String instructorId; // ID of the primary instructor
  final String instructorPhotoUrl;
  final String instructorName;
  final double rating;
  final int reviews;
  final String pricePerLesson;
  final String country;
  final String flag;
  final int lessons;
  final int experienceYears;
  final String bio;
  final List<String> tags;
  final String coverImageUrl;
  final String level;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.userIds,
    required this.instructorId,
    required this.instructorPhotoUrl,
    required this.instructorName,
    required this.rating,
    required this.reviews,
    required this.pricePerLesson,
    required this.country,
    required this.flag,
    required this.lessons,
    required this.experienceYears,
    required this.bio,
    required this.tags,
    required this.coverImageUrl,
    this.level = 'Beginner',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'userIds': userIds,
      'instructorId': instructorId,
      'instructorPhotoUrl': instructorPhotoUrl,
      'instructorName': instructorName,
      'rating': rating,
      'reviews': reviews,
      'pricePerLesson': pricePerLesson,
      'country': country,
      'flag': flag,
      'lessons': lessons,
      'experienceYears': experienceYears,
      'bio': bio,
      'tags': tags,
      'coverImageUrl': coverImageUrl,
      'level': level,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map, String documentId) {
    return Skill(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      userIds: List<String>.from(map['userIds'] ?? []),
      instructorId: map['instructorId'] ?? (List<String>.from(map['userIds'] ?? []).isNotEmpty ? map['userIds'][0] : ''),
      instructorPhotoUrl: map['instructorPhotoUrl'] ?? '',
      instructorName: map['instructorName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? 0,
      pricePerLesson: map['pricePerLesson'] ?? '',
      country: map['country'] ?? '',
      flag: map['flag'] ?? '',
      lessons: map['lessons'] ?? 0,
      experienceYears: map['experienceYears'] ?? 0,
      bio: map['bio'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      coverImageUrl: map['coverImageUrl'] ?? '',
      level: map['level'] ?? 'Beginner',
    );
  }
}
