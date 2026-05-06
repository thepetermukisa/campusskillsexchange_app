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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Picture
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.accent, width: 2),
                ),
                child: user.profileImageUrl != null
                    ? Image.network(user.profileImageUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      color: user.isVerified ? AppTheme.accent : AppTheme.border,
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: user.isVerified ? Colors.black : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: 'REVIEWS',
                value: user.reviews.toString().padLeft(2, '0'),
              ),
              _StatItem(
                label: 'RATING',
                value: user.rating.toStringAsFixed(1),
              ),
              _StatItem(
                label: 'EXP_LVL',
                value: '${user.hostingYears}Y',
              ),
            ],
          ),
          if (description != null) ...[
            const Divider(height: 48),
            Text(
              'BIO // STATUS',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.accent,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}
