import 'package:flutter/material.dart';
import '../models/skill_category.dart';
import '../screens/skill_list_screen.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final SkillCategory category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => SkillListScreen(category.name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(category.icon),
              size: 32,
              color: AppTheme.accent,
            ),
            const SizedBox(height: 16),
            Text(
              category.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${category.expertCount} UNITS',
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Courier', // Fallback for monospace
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
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
