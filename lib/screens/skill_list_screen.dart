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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skills')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'No experts in this category yet.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54)),
                  ),
                  SizedBox(height: 8),
                  Text(
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                      backgroundImage: skill.instructorPhotoUrl.isNotEmpty
                          ? NetworkImage(skill.instructorPhotoUrl)
                          : null,
                      child: skill.instructorPhotoUrl.isEmpty
                          ? Text(
                              skill.instructorName.isNotEmpty
                                  ? skill.instructorName[0].toUpperCase()
                                  : '?',
                              style:
                                  TextStyle(color: Color(0xFFFF6B6B)),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          skill.instructorName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        _buildLevelBadge(skill.level),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill.name,
                            style:
                                TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7))),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text('${skill.rating} ★',
                                style: TextStyle(
                                    color: Color(0xFFFF6B6B))),
                            SizedBox(width: 8),
                            Text('${skill.reviews} reviews',
                                style:
                                    TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54))),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      'UGX ${skill.pricePerLesson}/lesson',
                      style: TextStyle(
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

  Widget _buildLevelBadge(String level) {
    Color color = Colors.grey;
    if (level == 'Expert') {
      color = Colors.green;
    } else if (level == 'Intermediate') {
      color = Colors.amber;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: color == Colors.grey ? Colors.grey[300] : color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
