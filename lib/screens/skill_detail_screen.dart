// screens/skill_detail_screen.dart
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'submit_review_screen.dart';

class SkillDetailScreen extends StatelessWidget {
  final String skillId;
  final String instructorId;
  final String skillName;
  final String category;
  final String instructorName;
  final String instructorPhotoUrl;
  final String instructorCountry;
  final String instructorFlag;
  final double rating;
  final int reviews;
  final int lessons;
  final int yearsExperience;
  final String pricePerLesson;
  final String bio;
  final List<String> tags;
  final String coverImageUrl;

  const SkillDetailScreen({
    super.key,
    required this.skillId,
    required this.instructorId,
    required this.skillName,
    required this.category,
    required this.instructorName,
    this.instructorPhotoUrl = '',
    required this.instructorCountry,
    required this.instructorFlag,
    required this.rating,
    required this.reviews,
    required this.lessons,
    required this.yearsExperience,
    required this.pricePerLesson,
    required this.bio,
    required this.tags,
    required this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(skillName),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // Implement favorite toggle
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Banner
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(coverImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Instructor Profile Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                    backgroundImage: instructorPhotoUrl.isNotEmpty
                        ? NetworkImage(instructorPhotoUrl)
                        : null,
                    child: instructorPhotoUrl.isEmpty
                        ? Text(
                            instructorName.isNotEmpty
                                ? instructorName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructorName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text('From $instructorCountry'),
                            SizedBox(width: 8),
                            Text(
                              instructorFlag,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    icon: Icons.check_circle,
                    label: 'verified',
                    value: '',
                  ),
                  _StatItem(
                    icon: Icons.star,
                    label: 'rating',
                    value: rating.toString(),
                  ),
                  _StatItem(
                    icon: Icons.payments_outlined,
                    label: 'per lesson',
                    value: 'UGX $pricePerLesson',
                  ),
                  _StatItem(
                    icon: Icons.rate_review,
                    label: 'reviews',
                    value: reviews.toString(),
                  ),
                  _StatItem(
                    icon: Icons.menu_book,
                    label: 'lessons',
                    value: lessons.toString(),
                  ),
                  _StatItem(
                    icon: Icons.school,
                    label: 'experience',
                    value: '$yearsExperience yrs',
                  ),
                ],
              ),
            ),

            Divider(height: 40, thickness: 1, color: Color(0xFF333333)),

            // Bio / Description Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perfect for speaking practice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        bio,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tags / Badges
            Padding(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: tag.contains('Professional')
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFFF6B6B),
                    labelStyle: TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Message Instructor button ──────────────────────────
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: instructorId,
                            receiverName: instructorName,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.chat_bubble_outline, size: 20),
                    label: Text(
                      'Message Instructor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // ── Buy lesson button ──────────────────────────────────
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking feature coming soon!'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B6B),
                      side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Buy trial lesson',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 12),
                  // ── Leave Review button ────────────────────────────────
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitReviewScreen(
                            targetId: instructorId,
                            targetName: instructorName,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.rate_review_outlined, color: Color(0xFFFF6B6B)),
                    label: Text(
                      'Leave a Review',
                      style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// Helper widget for stats
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6B6B), size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
