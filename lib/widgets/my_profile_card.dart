import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class MyProfileCard extends StatelessWidget {
  final User user;
  final String? description;
  final List<User>? coHosts;

  const MyProfileCard({
    super.key,
    required this.user,
    this.description,
    this.coHosts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: isDark ? AppTheme.border : AppTheme.lightBorder,
          width: 0.6,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.accentGradient,
                  boxShadow: AppTheme.shadowAccent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark ? AppTheme.surfaceElevated : const Color(0xFFEFF6F5),
                    backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: user.isVerified
                                ? AppTheme.accent.withValues(alpha: 0.15)
                                : (isDark ? AppTheme.surfaceElevated : const Color(0xFFF0F4F8)),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: user.isVerified ? AppTheme.accent : (isDark ? AppTheme.border : AppTheme.lightBorder),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.isVerified) ...[
                                const Icon(Icons.verified_rounded, size: 10, color: AppTheme.accent),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                user.role.name[0].toUpperCase() + user.role.name.substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: user.isVerified ? AppTheme.accent : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          // Stats row
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Reviews', value: user.reviews.toString()),
                VerticalDivider(width: 1, color: isDark ? AppTheme.border : AppTheme.lightBorder),
                _StatItem(label: 'Rating', value: user.rating.toStringAsFixed(1)),
                VerticalDivider(width: 1, color: isDark ? AppTheme.border : AppTheme.lightBorder),
                _StatItem(label: 'Experience', value: '${user.hostingYears}y'),
              ],
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text('About', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(description!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
