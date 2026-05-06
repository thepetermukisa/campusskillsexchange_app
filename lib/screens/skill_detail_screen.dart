// screens/skill_detail_screen.dart
import 'package:flutter/material.dart';
import 'skill_test_screen.dart';
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
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
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
              padding: const EdgeInsets.all(16),
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
                            style: const TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructorName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text('From $instructorCountry'),
                            const SizedBox(width: 8),
                            Text(
                              instructorFlag,
                              style: const TextStyle(fontSize: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    icon: Icons.attach_money,
                    label: 'per lesson',
                    value: pricePerLesson,
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

            const Divider(height: 40, thickness: 1, color: Color(0xFF333333)),

            // Bio / Description Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perfect for speaking practice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        style: const TextStyle(color: Color(0xFFCCCCCC)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tags / Badges
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: tag.contains('Professional')
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFFF6B6B),
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── AI Quiz button ─────────────────────────────────────
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<double>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkillTestScreen(
                            skillId: skillId,
                            skillName: skillName,
                            category: category,
                          ),
                        ),
                      );
                      if (result != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Quiz complete! Score: ${result.toStringAsFixed(1)}%',
                            ),
                            backgroundColor: result >= 60
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: const Text(
                      'Take AI Quiz',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text(
                      'Message Instructor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Buy trial lesson',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    icon: const Icon(Icons.rate_review_outlined, color: Color(0xFFFF6B6B)),
                    label: const Text(
                      'Leave a Review',
                      style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // Bottom padding
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
        ),
      ],
    );
  }
}
