import 'package:flutter/material.dart';
import '../models/skill_category.dart';
import '../screens/skill_list_screen.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final SkillCategory category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconData = _getIcon(category.icon);
    final iconColor = _getCategoryColor(category.icon);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => SkillListScreen(category.name)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isDark ? AppTheme.border : AppTheme.lightBorder,
            width: 0.6,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(iconData, size: 22, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${category.expertCount} ${category.expertCount == 1 ? 'expert' : 'experts'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'code':      return Icons.code_rounded;
      case 'computer':  return Icons.computer_rounded;
      case 'palette':   return Icons.palette_rounded;
      case 'movie':     return Icons.movie_rounded;
      case 'lock':      return Icons.shield_rounded;
      default:          return Icons.person_rounded;
    }
  }

  Color _getCategoryColor(String iconName) {
    switch (iconName) {
      case 'code':      return const Color(0xFF5CC1B5);
      case 'computer':  return const Color(0xFF6B8FFF);
      case 'palette':   return const Color(0xFFFF8C69);
      case 'movie':     return const Color(0xFFFF69B4);
      case 'lock':      return const Color(0xFFFFB347);
      default:          return AppTheme.accent;
    }
  }
}
