import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class ExpertCard extends StatelessWidget {
  final User expert;

  const ExpertCard(this.expert, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to expert profile or request form
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Center(
                      child: Text(
                        expert.name[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expert.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                        ),
                        if (expert.isVerified)
                          Text(
                            'VERIFIED_OPERATOR',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontSize: 8,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: expert.subSkills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      skill.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(label: 'JOBS', value: expert.completedJobs.toString().padLeft(2, '0')),
                  _Stat(label: 'RATING', value: expert.rating.toStringAsFixed(1)),
                  _Stat(label: 'ENDORSE', value: expert.endorsements.length.toString().padLeft(2, '0')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.accent,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}

class _CategoryStep extends StatelessWidget {
  final List<String> categories;
  final Function(String) onSelect;
  final String? selected;

  const _CategoryStep({
    required this.categories,
    required this.onSelect,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What’s your main area of expertise?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((cat) {
              final isSelected = selected == cat;
              return GestureDetector(
                onTap: () => onSelect(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFCCCCCC),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  const _SubSkillsStep({
    required this.options,
    required this.selectedSkills,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your specific skills',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
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
                selectedColor: const Color(0xFFFF6B6B),
                backgroundColor: const Color(0xFF1E1E1E),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFCCCCCC),
                ),
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

  const _PortfolioStep({
    required this.onAddPortfolio,
    required this.portfolioUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add portfolio samples',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload screenshots, videos, or links to your work',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: portfolioUrls.length + 1,
            itemBuilder: (ctx, i) {
              if (i == portfolioUrls.length) {
                return GestureDetector(
                  onTap: () {
                    // Simulate upload
                    onAddPortfolio(''); // Remove placeholder
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFFFF6B6B)),
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verify your student status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload a clear photo of your student ID',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () => onUploadId(''), // Remove placeholder
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: idUrl != null
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF333333),
                ),
              ),
              child: idUrl != null
                  ? Image.network(idUrl!, fit: BoxFit.cover)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            color: Color(0xFFFF6B6B),
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to upload ID',
                            style: TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                        ],
                      ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review your application',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 20),
          _ReviewItem(title: 'Category', value: category),
          _ReviewItem(title: 'Skills', value: subSkills.join(', ')),
          _ReviewItem(title: 'Portfolio', value: '$portfolioCount items'),
          _ReviewItem(
            title: 'Student ID',
            value: hasId ? 'Uploaded' : 'Missing',
          ),
          const SizedBox(height: 30),
          Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'After submission:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Your profile will be reviewed within 24–48 hours'),
                  Text('• Verified experts appear in search results'),
                  Text('• You’ll receive a notification when approved'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: hasId ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Submit for Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFAAAAAA)),
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 60,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Verification in Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCCCCCC),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your application is being reviewed. You’ll get a notification once approved.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFAAAAAA),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF6B6B)),
                  foregroundColor: const Color(0xFFFF6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
