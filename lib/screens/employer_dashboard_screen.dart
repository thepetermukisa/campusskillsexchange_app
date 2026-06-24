import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_request.dart';
import '../models/role.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'applicants_screen.dart';
import 'job_details_screen.dart';
import 'post_request_screen.dart';
import 'expert_list_screen.dart';
import 'settings_screen.dart';
import 'chat_list_screen.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  void _addNewProject() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PostRequestScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employer Dashboard', style: theme.textTheme.bodySmall),
            Text('Control Center', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            tooltip: 'Messages',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewProject,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded),
        label: Text('New Post'),
      ),
      body: currentUser == null
          ? Center(child: Text('Unauthorized access'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final employerName = (userData?['name'] as String?) ?? 'Employer';
                final userRole = RoleHelper.fromString(userData?['role']);
                final profileImageUrl = userData?['profileImageUrl'] as String?;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .where('requesterId', isEqualTo: currentUser.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final projects = snapshot.data?.docs.toList() ?? [];
                    // Sort locally to avoid Firestore composite index requirement
                    projects.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });
                    
                    final activeCount = projects.length;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // -- Profile header ----------------------------------------
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                              border: Border.all(color: theme.colorScheme.outline, width: 0.6),
                              boxShadow: AppTheme.shadowSm,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: profileImageUrl == null || profileImageUrl.isEmpty ? AppTheme.accentGradient : null,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    image: profileImageUrl != null && profileImageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(profileImageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: profileImageUrl == null || profileImageUrl.isEmpty
                                      ? Icon(Icons.business_rounded, color: Colors.white, size: 26)
                                      : null,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employerName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 0.6),
                                        ),
                                        child: Text(
                                          userRole.name[0].toUpperCase() + userRole.name.substring(1),
                                          style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // -- Stats row ----------------------------------------------
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: 'Active Posts', value: activeCount.toString(), icon: Icons.folder_open_rounded)),
                              SizedBox(width: 12),
                              Expanded(child: _HiredStatCard(employerId: currentUser.uid)),
                              SizedBox(width: 12),
                              const Expanded(child: _StatCard(label: 'Rating', value: '—', icon: Icons.star_rounded)),
                            ],
                          ),
                          SizedBox(height: 24),

                          // -- Section header ----------------------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your Posts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  Text('Manage your active job listings', style: theme.textTheme.bodySmall),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ExpertListScreen(categoryName: 'All')),
                                ),
                                icon: Icon(Icons.search_rounded, size: 16),
                                label: Text('Browse Talent'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          if (projects.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                                border: Border.all(color: theme.colorScheme.outline, width: 0.6),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.folder_open_rounded, size: 48, color: AppTheme.textSecondary),
                                  SizedBox(height: 16),
                                  Text('No posts yet', style: theme.textTheme.titleSmall),
                                  SizedBox(height: 6),
                                  Text('Create your first job post to find talent', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _addNewProject,
                                    icon: Icon(Icons.add_rounded, size: 16),
                                    label: Text('Create Post'),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final data = projects[index].data() as Map<String, dynamic>;
                                final project = ServiceRequest.fromMap(data, projects[index].id);

                                return _ProjectCard(
                                  projectName: project.title,
                                  description: project.description,
                                  postedDaysAgo: DateTime.now().difference(project.createdAt).inDays,
                                  budget: project.budget.toStringAsFixed(0),
                                  status: project.status,
                                  onTapView: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JobDetailsScreen(
                                        title: project.title,
                                        description: project.description,
                                        companyName: project.requesterName,
                                        budget: 'UGX ${project.budget.toStringAsFixed(0)}',
                                        duration: '1 Month',
                                        status: project.status,
                                        requiredSkills: ['Flutter', 'Firebase'],
                                        request: project,
                                      ),
                                    ),
                                  ),
                                  onTapApplicants: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApplicantsScreen(
                                        jobId: project.id,
                                        jobTitle: project.title,
                                        employerId: currentUser.uid,
                                      ),
                                    ),
                                  ),
                                  onTapToggleStatus: () async {
                                    final isCurrentlyOpen = project.status.toLowerCase() == 'open';
                                    final newStatus = isCurrentlyOpen ? 'closed' : 'open';
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(isCurrentlyOpen ? 'Close post?' : 'Reopen post?'),
                                        content: Text(isCurrentlyOpen ? 'This job will no longer be visible to applicants.' : 'This job will be visible to applicants again.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text(isCurrentlyOpen ? 'Close Job' : 'Reopen Job', style: TextStyle(color: theme.colorScheme.error)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await FirebaseService().updateRequestStatus(project.id, newStatus);
                                    }
                                  },
                                  onTapEdit: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PostRequestScreen(requestToEdit: project)),
                                  ),
                                  onTapDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('Delete post?'),
                                        content: Text('This action cannot be undone.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await FirebaseService().deleteServiceRequest(project.id);
                                    }
                                  },
                                );
                              },
                            ),
                          SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: theme.colorScheme.outline, width: 0.6),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.accent),
          SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.accent)),
          SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Reads accepted applications from Firestore for a real "Hired Talent" count.
class _HiredStatCard extends StatelessWidget {
  final String employerId;
  const _HiredStatCard({required this.employerId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: theme.colorScheme.outline, width: 0.6),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.people_rounded, size: 18, color: AppTheme.accent),
              SizedBox(height: 8),
              Text(count.toString(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.accent)),
              SizedBox(height: 2),
              Text('Hired Talent', style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String projectName;
  final String description;
  final int postedDaysAgo;
  final String budget;
  final String status;
  final VoidCallback onTapView;
  final VoidCallback onTapApplicants;
  final VoidCallback onTapToggleStatus;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  const _ProjectCard({
    required this.projectName,
    required this.description,
    required this.postedDaysAgo,
    required this.budget,
    required this.status,
    required this.onTapView,
    required this.onTapApplicants,
    required this.onTapToggleStatus,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = status.toLowerCase() == 'open';
    final statusColor = isOpen ? const Color(0xFF34D399) : Colors.grey;
    final statusLabel = isOpen ? 'Open' : 'Closed';
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: theme.colorScheme.outline, width: 0.6),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(projectName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.6),
                      ),
                      child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                SizedBox(height: 12),
                Row(
                  children: [
                    _DetailChip(label: 'UGX $budget', icon: Icons.payments_outlined),
                    SizedBox(width: 8),
                    _DetailChip(label: '${postedDaysAgo}d ago', icon: Icons.schedule_rounded),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outline),
          Row(
            children: [
              Expanded(child: _ActionButton(label: 'View', icon: Icons.open_in_new_rounded, color: AppTheme.accent, onTap: onTapView)),
              Expanded(child: _ActionButton(label: 'Applicants', icon: Icons.people_rounded, color: const Color(0xFF34D399), onTap: onTapApplicants)),
              Expanded(child: _ActionButton(label: isOpen ? 'Close' : 'Reopen', icon: isOpen ? Icons.close_rounded : Icons.replay_rounded, color: AppTheme.textSecondary, onTap: onTapToggleStatus)),
              Expanded(child: _ActionButton(label: 'Edit', icon: Icons.edit_outlined, color: AppTheme.textSecondary, onTap: onTapEdit)),
              Expanded(child: _ActionButton(label: 'Delete', icon: Icons.delete_outline_rounded, color: theme.colorScheme.error, onTap: onTapDelete)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _DetailChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: theme.colorScheme.outline, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radiusXl),
        bottomRight: Radius.circular(AppTheme.radiusXl),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
