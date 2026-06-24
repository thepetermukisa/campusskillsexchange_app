import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusskillexchange_app/theme/app_theme.dart';
import 'package:campusskillexchange_app/screens/admin/approve_employers_screen.dart';
import 'package:campusskillexchange_app/screens/admin/approve_experts_screen.dart';
import 'package:campusskillexchange_app/screens/admin/approve_quizzes_screen.dart';
import 'package:campusskillexchange_app/screens/admin/monitor_activity_screen.dart';
import 'package:campusskillexchange_app/screens/admin/manage_users_screen.dart';
import 'package:campusskillexchange_app/screens/admin/manage_jobs_screen.dart';
import 'package:campusskillexchange_app/screens/settings_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: theme.textTheme.bodySmall),
            Text(_greeting(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accent, size: 48),
                  SizedBox(height: 12),
                  Text('Admin Control Center', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard_rounded,
              title: 'Dashboard Home',
              color: Colors.white,
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: Color(0xFF333333)),
            _DrawerItem(
              icon: Icons.people_alt_rounded,
              title: 'Manage Users',
              color: const Color(0xFFB066FF),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.work_rounded,
              title: 'Manage Jobs',
              color: const Color(0xFFFF6B6B),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageJobsScreen()));
              },
            ),
            Divider(color: Color(0xFF333333)),
            _DrawerItem(
              icon: Icons.verified_user_rounded,
              title: 'Verify Experts',
              color: const Color(0xFF5CC1B5),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveExpertsScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.business_center_rounded,
              title: 'Approve Employers',
              color: const Color(0xFF6B8FFF),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveEmployersScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.quiz_rounded,
              title: 'Review Quizzes',
              color: const Color(0xFFFFB347),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveQuizzesScreen()));
              },
            ),
            const Divider(color: Color(0xFF333333)),
            _DrawerItem(
              icon: Icons.monitor_heart_rounded,
              title: 'Monitor Activity',
              color: const Color(0xFFFF8C69),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MonitorActivityScreen()));
              },
            ),
            const Divider(color: Color(0xFF333333)),
            _DrawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              color: const Color(0xFF9E9E9E),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load stats: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }

          final users = snapshot.data?.docs ?? [];
          final totalUsers = users.length;
          final pendingExperts = users.where((u) {
            final data = u.data() as Map<String, dynamic>;
            return data['studentIdUrl'] != null && data['isVerified'] == false;
          }).length;
          final activeExperts = users.where((u) {
            final data = u.data() as Map<String, dynamic>;
            return data['isVerified'] == true;
          }).length;
          final companies = users.where((u) {
            final data = u.data() as Map<String, dynamic>;
            final r = data['role']?.toString().toLowerCase();
            return r == 'company' || r == 'employer';
          });
          final totalCompanies = companies.length;
          final pendingEmployers = companies.where((u) {
            final data = u.data() as Map<String, dynamic>;
            return data['isVerified'] == false;
          }).length;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Actionable Alerts --------------------------------------------
                if (pendingExperts > 0 || pendingEmployers > 0) ...[
                  Text('Action Required', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  if (pendingExperts > 0)
                    _AlertBanner(
                      icon: Icons.verified_user_rounded,
                      title: '$pendingExperts Experts Awaiting Verification',
                      color: const Color(0xFF5CC1B5),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveExpertsScreen())),
                    ),
                  if (pendingExperts > 0 && pendingEmployers > 0) SizedBox(height: 8),
                  if (pendingEmployers > 0)
                    _AlertBanner(
                      icon: Icons.business_center_rounded,
                      title: '$pendingEmployers Employers Awaiting Approval',
                      color: const Color(0xFF6B8FFF),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveEmployersScreen())),
                    ),
                  SizedBox(height: 28),
                ],

                // -- Platform Stats ------------------------------------------------
                Text('Platform Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Live data from Firestore', style: theme.textTheme.bodySmall),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatCard(label: 'Total Users', value: totalUsers.toString(), icon: Icons.people_rounded),
                      SizedBox(width: 12),
                      _StatCard(label: 'Verified Experts', value: activeExperts.toString(), icon: Icons.verified_rounded),
                      SizedBox(width: 12),
                      _StatCard(label: 'Total Employers', value: totalCompanies.toString(), icon: Icons.business_rounded),
                    ],
                  ),
                ),
                SizedBox(height: 28),

                // -- Activity Log --------------------------------------------------
                Text('Recent Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Latest platform events', style: theme.textTheme.bodySmall),
                SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activity')
                      .orderBy('timestamp', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, activitySnapshot) {
                    if (activitySnapshot.hasError) {
                      return Text('Could not load activity: ${activitySnapshot.error}', style: TextStyle(color: theme.colorScheme.error));
                    }
                    if (activitySnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: AppTheme.accent));
                    }
                    final activities = activitySnapshot.data?.docs ?? [];
                    if (activities.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          border: Border.all(color: theme.colorScheme.outline, width: 0.6),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 36, color: AppTheme.textSecondary),
                            SizedBox(height: 12),
                            Text('No recent activity', style: theme.textTheme.titleSmall),
                            SizedBox(height: 4),
                            Text('Events will appear here as they happen', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: theme.colorScheme.outline, width: 0.6),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length,
                        separatorBuilder: (ctx, i) => Divider(height: 1, color: theme.colorScheme.outline),
                        itemBuilder: (context, index) {
                          final data = activities[index].data() as Map<String, dynamic>;
                          final type = data['type'] ?? 'info';
                          final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _activityColor(type).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Icon(_activityIcon(type), size: 16, color: _activityColor(type)),
                            ),
                            title: Text(data['message'] as String? ?? 'Unknown event', style: theme.textTheme.titleSmall),
                            subtitle: Text(_timeAgo(timestamp), style: theme.textTheme.labelSmall),
                          );
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _timeAgo(DateTime dateTime) {
    final d = DateTime.now().difference(dateTime);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'user':    return Icons.person_add_rounded;
      case 'skill':   return Icons.auto_awesome_rounded;
      case 'request': return Icons.send_rounded;
      default:        return Icons.info_outline_rounded;
    }
  }

  Color _activityColor(String type) {
    switch (type) {
      case 'user':    return const Color(0xFF5CC1B5);
      case 'skill':   return const Color(0xFF6B8FFF);
      case 'request': return const Color(0xFFFF8C69);
      default:        return AppTheme.textSecondary;
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AlertBanner({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
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
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 140,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppTheme.accent),
          SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.accent)),
          SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
