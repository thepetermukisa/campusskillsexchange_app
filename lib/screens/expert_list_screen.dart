import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';
import '../theme/app_theme.dart';
import 'skill_detail_screen.dart';

const _kCategories = [
  'All',
  'Programming',
  'IT',
  'Design',
  'Multimedia',
  'Security',
  'Academic',
  'Other'
];

/// Shows expert skill listings with search and filtering.
class ExpertListScreen extends StatefulWidget {
  final String categoryName;

  const ExpertListScreen({super.key, this.categoryName = 'All'});

  @override
  State<ExpertListScreen> createState() => _ExpertListScreenState();
}

class _ExpertListScreenState extends State<ExpertListScreen> {
  late String _selectedCategory;
  String _searchQuery = '';
  double _maxBudget = 500000; // default max budget

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryName;
    if (!_kCategories.contains(_selectedCategory)) {
      _selectedCategory = 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Skills'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Filter Section
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search experts or skills...',
                    prefixIcon: Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 12),
                
                // Categories (Horizontal Scroll)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _kCategories.length,
                    itemBuilder: (context, index) {
                      final category = _kCategories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                          selectedColor: AppTheme.accent.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.accent : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
                          side: BorderSide(
                            color: isSelected ? AppTheme.accent : theme.colorScheme.outline,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                
                // Budget Slider
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      'Max Budget: UGX ${_maxBudget.toInt()}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Slider(
                  value: _maxBudget,
                  min: 0,
                  max: 1000000,
                  divisions: 20,
                  activeColor: AppTheme.accent,
                  onChanged: (val) {
                    setState(() {
                      _maxBudget = val;
                    });
                  },
                ),
              ],
            ),
          ),
          
          Divider(height: 1),

          // List of Experts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('skills').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No experts found.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  );
                }
                
                // Map and Filter the skills
                final allSkills = snapshot.data!.docs
                    .map((d) => Skill.fromMap(d.data() as Map<String, dynamic>, d.id))
                    .toList();
                
                final filteredSkills = allSkills.where((skill) {
                  // Category Filter
                  if (_selectedCategory != 'All' && skill.category != _selectedCategory) {
                    return false;
                  }
                  
                  // Budget Filter
                  final price = double.tryParse(skill.pricePerLesson) ?? 0;
                  if (price > _maxBudget) {
                    return false;
                  }

                  // Search Query Filter
                  if (_searchQuery.isNotEmpty) {
                    final searchMatch = skill.name.toLowerCase().contains(_searchQuery) ||
                        skill.instructorName.toLowerCase().contains(_searchQuery);
                    if (!searchMatch) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filteredSkills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                        SizedBox(height: 16),
                        Text(
                          'No experts match your filters.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredSkills.length,
                  itemBuilder: (ctx, i) {
                    final skill = filteredSkills[i];
                    return Card(
                      color: isDark ? AppTheme.surface : AppTheme.lightSurface,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        side: BorderSide(color: theme.colorScheme.outline, width: 0.6),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accent.withValues(alpha: 0.25),
                          backgroundImage: skill.instructorPhotoUrl.isNotEmpty
                              ? NetworkImage(skill.instructorPhotoUrl)
                              : null,
                          child: skill.instructorPhotoUrl.isEmpty
                              ? Text(
                                  skill.instructorName.isNotEmpty
                                      ? skill.instructorName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                skill.instructorName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            _buildLevelBadge(skill.level),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(skill.name, style: theme.textTheme.bodyMedium),
                            SizedBox(height: 4),
                            Text(
                              'UGX ${skill.pricePerLesson}/lesson',
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SkillDetailScreen(
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    Color color = Colors.grey;
    if (level == 'Expert') {
      color = AppTheme.accent;
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
          color: color == Colors.grey ? Colors.grey[400] : color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
