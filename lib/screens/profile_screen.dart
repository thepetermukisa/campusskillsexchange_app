import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUser = uid == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: uid == null
          ? Center(child: Text('Not logged in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: AppTheme.accent));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('User not found.'));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final currentUser = User.fromMap(data, uid);
                return _ProfileBody(user: currentUser, isCurrentUser: isCurrentUser);
              },
            ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  const _ProfileBody({required this.user, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Hero card -----------------------------------------------------
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppTheme.surface, AppTheme.surfaceElevated]
                    : [AppTheme.lightSurface, const Color(0xFFF0F6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
              boxShadow: AppTheme.shadowMd,
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.accentGradient,
                    boxShadow: AppTheme.shadowAccent,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.5),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: isDark ? AppTheme.surfaceElevated : const Color(0xFFEFF6F5),
                      backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 28, color: AppTheme.accent, fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                          ),
                          if (user.isVerified)
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, color: Colors.blue, size: 20),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(user.email, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                      if (user.bio.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(user.bio, style: theme.textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.subSkills.isNotEmpty
                              ? AppTheme.accent.withValues(alpha: 0.12)
                              : Colors.blue.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: user.subSkills.isNotEmpty ? AppTheme.accent.withValues(alpha: 0.4) : Colors.blue.withValues(alpha: 0.4),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.subSkills.isNotEmpty ? Icons.verified_rounded : Icons.school_rounded,
                              size: 11,
                              color: user.subSkills.isNotEmpty ? AppTheme.accent : Colors.blue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              user.subSkills.isNotEmpty ? 'Expert' : 'Student',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: user.subSkills.isNotEmpty ? AppTheme.accent : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isCurrentUser) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.edit, size: 18),
                label: Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
                },
              ),
            ),
          ],
          
          SizedBox(height: 24),

          // -- Expert metrics ------------------------------------------------
          if (user.subSkills.isNotEmpty) ...[
            Text('Expert Metrics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Jobs', value: user.completedJobs.toString(), icon: Icons.work_outline_rounded),
                      _StatItem(label: 'Rating', value: user.rating.toStringAsFixed(1), icon: Icons.star_outline_rounded),
                      _StatItem(label: 'Reviews', value: user.reviews.toString(), icon: Icons.reviews_outlined),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(height: 1),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Skills & Endorsements', style: theme.textTheme.titleSmall),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.subSkills.map((skill) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceElevated : const Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
                        ),
                        child: Text(skill, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],

          // -- Settings ------------------------------------------------------
          Text('Account', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          _ProfileOption(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Manage alerts and push notifications'),
          _ProfileOption(icon: Icons.language_outlined, title: 'Language & Region', subtitle: 'English (US)'),
          SizedBox(height: 24),
          Text('Support', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          _ProfileOption(icon: Icons.chat_bubble_outline_rounded, title: 'Contact Support', subtitle: 'Email, call or connect with us'),
          _ProfileOption(icon: Icons.help_outline_rounded, title: 'Help Center', subtitle: 'Read guides and tutorials'),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: AppTheme.accent, size: 24),
        SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.accent)),
        SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileOption({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
        boxShadow: AppTheme.shadowSm,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: theme.textTheme.bodySmall) : null,
        trailing: Icon(Icons.chevron_right_rounded, color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary, size: 20),
      ),
    );
  }
}
