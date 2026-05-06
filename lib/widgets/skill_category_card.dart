import 'package:flutter/material.dart';
import '../models/skill_category.dart';

class SkillCategoryCard extends StatelessWidget {
  final SkillCategory category;

  const SkillCategoryCard(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to skill detail screen
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForCategory(category.icon),
              color: const Color(0xFFFF6B6B),
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String icon) {
    switch (icon) {
      case 'code':
        return Icons.code;
      case 'computer':
        return Icons.computer;
      case 'palette':
        return Icons.palette;
      case 'movie':
        return Icons.movie;
      case 'lock':
        return Icons.lock;
      default:
        return Icons.person;
    }
  }
}
