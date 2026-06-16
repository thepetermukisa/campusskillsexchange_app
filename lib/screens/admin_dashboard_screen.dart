import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusskillexchange_app/theme/app_theme.dart';
import 'package:campusskillexchange_app/screens/admin/approve_employers_screen.dart';
import 'package:campusskillexchange_app/screens/admin/approve_experts_screen.dart';
import 'package:campusskillexchange_app/screens/admin/approve_quizzes_screen.dart';
import 'package:campusskillexchange_app/screens/admin/monitor_activity_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('ADMIN_SYS_OVERRIDE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: AppTheme.accent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting().toUpperCase(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 48),

            // Quick Actions
            Text(
              'OPERATIONAL_CONTROLS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _QuickAction(
                  icon: Icons.verified_user,
                  label: 'VERIFY_EXPERTS',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ApproveExpertsScreen())),
                ),
                _QuickAction(
                  icon: Icons.business_center,
                  label: 'EMPLOYER_ADMISSION',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ApproveEmployersScreen())),
                ),
                _QuickAction(
                  icon: Icons.monitor_heart,
                  label: 'SYSTEM_MONITOR',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MonitorActivityScreen())),
                ),
                _QuickAction(
                  icon: Icons.terminal,
                  label: 'QUIZ_VALIDATOR',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ApproveQuizzesScreen())),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Stats Cards
            Text(
              'SYSTEM_TELEMETRY',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
                    child: Text('TELEMETRY_OFFLINE: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                  );
                }
                final users = snapshot.data?.docs ?? [];
                final totalUsers = users.length;
                final pendingVerifications = users.where((u) {
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
                }).length;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'TOTAL_USERS', value: totalUsers.toString().padLeft(3, '0'))),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(label: 'PENDING_SIG', value: pendingVerifications.toString().padLeft(2, '0'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'VERIFIED_EXP', value: activeExperts.toString().padLeft(2, '0'))),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(label: 'ACTIVE_EMPLOYERS', value: companies.toString().padLeft(2, '0'))),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 48),

            // Recent Activity Log
            Text(
              'EVENT_LOG_V4',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activity')
                  .orderBy('timestamp', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
                    child: Text('LOG_STREAM_INTERRUPTED: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                  );
                }
                final activities = snapshot.data?.docs ?? [];
                if (activities.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Center(
                      child: Text('LOG_BUFFER_EMPTY', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (ctx, i) => Container(height: 1, color: AppTheme.border),
                    itemBuilder: (context, index) {
                      final data = activities[index].data() as Map<String, dynamic>;
                      final type = data['type'] ?? 'info';
                      final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final timeStr = _getTimeAgo(timestamp);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            _getActivityIcon(type),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (data['message'] as String? ?? 'NULL_EVENT').toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TIMESTAMP: $timeStr',
                                    style: TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontFamily: 'Courier'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Root Access: Morning';
    if (hour < 17) return 'Root Access: Afternoon';
    return 'Root Access: Evening';
  }

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) return '${duration.inMinutes}M_AGO';
    if (duration.inHours < 24) return '${duration.inHours}H_AGO';
    return '${duration.inDays}D_AGO';
  }

  Widget _getActivityIcon(String type) {
    IconData icon;
    switch (type) {
      case 'user':
        icon = Icons.person_add;
        break;
      case 'skill':
        icon = Icons.terminal;
        break;
      case 'request':
        icon = Icons.memory;
        break;
      default:
        icon = Icons.info_outline;
    }
    return Icon(icon, color: AppTheme.accent, size: 16);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.accent,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}
