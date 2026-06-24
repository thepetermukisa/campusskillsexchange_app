import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_request.dart';
import '../models/skill.dart';
import '../services/ai_matchmaking_service.dart';
import '../theme/app_theme.dart';
import 'job_details_screen.dart';
import 'profile_screen.dart';
import 'post_request_screen.dart';

const _kCategories = ['All', 'Programming', 'IT', 'Design', 'Multimedia', 'Security'];

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  String _selectedCategory = 'All';

  Future<List<Skill>> _fetchAIRecommendations(String uid) async {
    final reqSnap = await FirebaseFirestore.instance
        .collection('requests')
        .where('requesterId', isEqualTo: uid)
        .get();

    if (reqSnap.docs.isEmpty) return [];

    final userRequests = reqSnap.docs.toList();
    userRequests.sort((a, b) {
      final aTime = (a.data())['createdAt'] as Timestamp?;
      final bTime = (b.data())['createdAt'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    final latestRequest = ServiceRequest.fromMap(userRequests.first.data(), userRequests.first.id);

    final skillsSnap = await FirebaseFirestore.instance.collection('skills').get();
    final allSkills = skillsSnap.docs.map((d) => Skill.fromMap(d.data(), d.id)).toList();

    if (allSkills.isEmpty) return [];

    final matchedIds = await AIMatchmakingService.getMatches(
      request: latestRequest,
      availableSkills: allSkills,
    );

    return matchedIds
        .map((id) {
          try { return allSkills.firstWhere((s) => s.id == id); } catch (_) { return null; }
        })
        .whereType<Skill>()
        .toList();
  }

  Widget _buildRecommendedSkills(String uid) {
    return FutureBuilder<List<Skill>>(
      future: _fetchAIRecommendations(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          );
        }

        final matchedSkills = snapshot.data ?? [];

        if (matchedSkills.isEmpty) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.textSecondary, size: 32),
                SizedBox(height: 12),
                Text(
                  'No matches yet',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  'Post a request to get AI-powered skill matches',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostRequestScreen())),
                  icon: Icon(Icons.add_rounded, size: 16),
                  label: Text('Post a Request'),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matchedSkills.length,
            itemBuilder: (context, index) => _buildMatchCard(matchedSkills[index]),
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(Skill skill) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 14),
              ),
              SizedBox(width: 8),
              Text('AI Match', style: theme.textTheme.labelLarge),
            ],
          ),
          SizedBox(height: 10),
          Text(
            skill.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            skill.instructorName,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(userId: skill.instructorId)),
              ),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8)),
              child: Text('View Profile', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Jobs'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Recommendations Section
          if (uid != null) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('AI Recommendations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildRecommendedSkills(uid),
            ),
            SizedBox(height: 16),
          ],
          
          // Categories Tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _kCategories.length,
              itemBuilder: (ctx, i) {
                final category = _kCategories[i];
                final isSelected = category == _selectedCategory;
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
                    selectedColor: AppTheme.accent.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.accent : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                    side: BorderSide(
                      color: isSelected ? AppTheme.accent : (theme.brightness == Brightness.dark ? AppTheme.border : AppTheme.lightBorder),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),

          // Job Listings
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: theme.colorScheme.primary),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No open jobs at the moment.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                var requests = snapshot.data!.docs
                    .map((d) => ServiceRequest.fromMap(d.data() as Map<String, dynamic>, d.id))
                    .where((r) => r.status.toLowerCase() == 'open')
                    .toList();

                // Filter by category
                if (_selectedCategory != 'All') {
                  requests = requests.where((r) =>
                    r.category.toLowerCase() == _selectedCategory.toLowerCase()
                  ).toList();
                }

                if (requests.isEmpty) {
                  return Center(
                    child: Text(
                      'No jobs found in this category.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (ctx, i) {
                    final request = requests[i];
                    return Card(
                      color: theme.colorScheme.surface,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            request.title, // Removed .toUpperCase()
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(request.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.person_outline_rounded, size: 14, color: theme.textTheme.bodySmall?.color),
                                  SizedBox(width: 4),
                                  Text(request.requesterName, style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'UGX',
                                style: theme.textTheme.labelSmall,
                              ),
                              Text(
                                request.budget.toStringAsFixed(0),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailsScreen(
                                  title: request.title,
                                  description: request.description,
                                  companyName: request.requesterName,
                                  budget: 'UGX ${request.budget.toStringAsFixed(0)}',
                                  duration: 'Open',
                                  status: request.status,
                                  requiredSkills: [],
                                  request: request,
                                ),
                              ),
                            );
                          },
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
}
