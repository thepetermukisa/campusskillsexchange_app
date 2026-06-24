import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class ExpertCard extends StatelessWidget {
  final User expert;

  const ExpertCard(this.expert, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: isDark ? AppTheme.border : AppTheme.lightBorder,
          width: 0.6,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.accent.withOpacity(0.12),
                    backgroundImage: (expert.profileImageUrl != null && expert.profileImageUrl!.isNotEmpty)
                        ? NetworkImage(expert.profileImageUrl!)
                        : null,
                    child: (expert.profileImageUrl == null || expert.profileImageUrl!.isEmpty)
                        ? Text(
                            expert.name.isNotEmpty ? expert.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expert.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (expert.isVerified) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: AppTheme.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Verified Expert',
                                style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.accent),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                ],
              ),
              if (expert.subSkills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: expert.subSkills.take(4).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.surfaceElevated
                            : const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: isDark ? AppTheme.border : AppTheme.lightBorder,
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'Jobs', value: expert.completedJobs.toString()),
                  _Stat(label: 'Rating', value: expert.rating.toStringAsFixed(1)),
                  _Stat(label: 'Endorsements', value: expert.endorsements.length.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.accent)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _CategoryStep extends StatelessWidget {
  final List<String> categories;
  final Function(String) onSelect;
  final String? selected;

  const _CategoryStep({required this.categories, required this.onSelect, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your main area of expertise?', style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((cat) {
              final isSelected = selected == cat;
              return GestureDetector(
                onTap: () => onSelect(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: isSelected ? AppTheme.accent : AppTheme.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SubSkillsStep extends StatelessWidget {
  final List<String> options;
  final List<String> selectedSkills;
  final Function(String) onToggle;

  const _SubSkillsStep({required this.options, required this.selectedSkills, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select your specific skills', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) => onToggle(skill),
                selectedColor: AppTheme.accent.withOpacity(0.15),
                checkmarkColor: AppTheme.accent,
                side: BorderSide(color: isSelected ? AppTheme.accent : AppTheme.border, width: isSelected ? 1.5 : 1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PortfolioStep extends StatelessWidget {
  final Function(String) onAddPortfolio;
  final List<String> portfolioUrls;

  const _PortfolioStep({required this.onAddPortfolio, required this.portfolioUrls});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add portfolio samples', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Upload screenshots, videos, or links to your work', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemCount: portfolioUrls.length + 1,
            itemBuilder: (ctx, i) {
              if (i == portfolioUrls.length) {
                return GestureDetector(
                  onTap: () => onAddPortfolio(''),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppTheme.accent),
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Image.network(portfolioUrls[i], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final Function(String) onUploadId;
  final String? idUrl;

  const _VerificationStep({required this.onUploadId, required this.idUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verify your student status', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Upload a clear photo of your student ID', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => onUploadId(''),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: idUrl != null ? AppTheme.accent : AppTheme.border),
              ),
              child: idUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      child: Image.network(idUrl!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_rounded, color: AppTheme.accent, size: 36),
                        const SizedBox(height: 8),
                        Text('Tap to upload ID', style: theme.textTheme.bodyMedium),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String category;
  final List<String> subSkills;
  final int portfolioCount;
  final bool hasId;
  final VoidCallback onSubmit;

  const _ReviewStep({
    required this.category,
    required this.subSkills,
    required this.portfolioCount,
    required this.hasId,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review your application', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          _ReviewItem(title: 'Category', value: category),
          _ReviewItem(title: 'Skills', value: subSkills.join(', ')),
          _ReviewItem(title: 'Portfolio', value: '$portfolioCount items'),
          _ReviewItem(title: 'Student ID', value: hasId ? 'Uploaded ?' : 'Missing'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What happens next?', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('• Your profile will be reviewed within 24–48 hours', style: theme.textTheme.bodySmall),
                Text('• Verified experts appear in search results', style: theme.textTheme.bodySmall),
                Text('• You will receive a notification once approved', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasId ? onSubmit : null,
              child: const Text('Submit for Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String title;
  final String value;

  const _ReviewItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: theme.textTheme.titleSmall),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.1),
                ),
                child: const Icon(Icons.hourglass_empty_rounded, size: 56, color: AppTheme.accent),
              ),
              const SizedBox(height: 28),
              Text('Verification in Progress', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Your application is being reviewed. You will get a notification once approved.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
