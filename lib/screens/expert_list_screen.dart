import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';
import 'skill_detail_screen.dart';

/// Shows all expert skill listings for a given category, loaded from Firestore.
class ExpertListScreen extends StatelessWidget {
  final String categoryName;

  const ExpertListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skills')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No experts in this category yet.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          final skills = snapshot.data!.docs
              .map((d) => Skill.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skills.length,
            itemBuilder: (ctx, i) {
              final skill = skills[i];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
                    backgroundImage: skill.instructorPhotoUrl.isNotEmpty
                        ? NetworkImage(skill.instructorPhotoUrl)
                        : null,
                    child: skill.instructorPhotoUrl.isEmpty
                        ? Text(
                            skill.instructorName.isNotEmpty
                                ? skill.instructorName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Color(0xFFFF6B6B)),
                          )
                        : null,
                  ),
                  title: Text(skill.instructorName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(skill.name,
                      style: const TextStyle(color: Color(0xFFCCCCCC))),
                  trailing: Text(
                    '\$${skill.pricePerLesson}/lesson',
                    style: const TextStyle(
                        color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (_) => SkillDetailScreen(
                      skillId: skill.id,
                      instructorId: skill.instructorId,
                      skillName: skill.name,
                      category: skill.category,
                      instructorName: skill.instructorName,
                      instructorPhotoUrl: skill.instructorPhotoUrl,
                      instructorCountry: skill.country,
                      instructorFlag: skill.flag,
                      rating: skill.rating,
                      reviews: skill.reviews,
                      lessons: skill.lessons,
                      yearsExperience: skill.experienceYears,
                      pricePerLesson: skill.pricePerLesson,
                      bio: skill.bio,
                      tags: skill.tags,
                      coverImageUrl: skill.coverImageUrl,
                    ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
