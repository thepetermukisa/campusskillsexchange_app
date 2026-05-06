import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';
import 'skill_detail_screen.dart';

class SkillListScreen extends StatelessWidget {
  final String category;

  const SkillListScreen(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skills')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  const Text(
                    'No experts in this category yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to offer a skill!',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final skills = snapshot.data!.docs
              .map((doc) =>
                  Skill.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: skills.length,
            itemBuilder: (ctx, i) {
              final skill = skills[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Card(
                  color: const Color(0xFF1E1E1E),
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
                              style:
                                  const TextStyle(color: Color(0xFFFF6B6B)),
                            )
                          : null,
                    ),
                    title: Text(
                      skill.instructorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill.name,
                            style:
                                const TextStyle(color: Color(0xFFCCCCCC))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('${skill.rating} ★',
                                style: const TextStyle(
                                    color: Color(0xFFFF6B6B))),
                            const SizedBox(width: 8),
                            Text('${skill.reviews} reviews',
                                style:
                                    const TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      '\$${skill.pricePerLesson}/lesson',
                      style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkillDetailScreen(
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
                      );
                    },
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
