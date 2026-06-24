import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/profile_screen.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- User header -------------------------------------------------
            if (firebaseUser != null)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get(),
                builder: (context, snapshot) {
                  String displayName = firebaseUser.displayName ?? firebaseUser.email ?? 'User';
                  String? photoUrl = firebaseUser.photoURL;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    if ((data['name'] as String?)?.isNotEmpty == true) displayName = data['name'] as String;
                    if ((data['profileImageUrl'] as String?)?.isNotEmpty == true) photoUrl = data['profileImageUrl'] as String;
                  }

                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: _UserHeader(displayName: displayName, photoUrl: photoUrl),
                  );
                },
              ),
            SizedBox(height: 24),

            // -- Preferences -------------------------------------------------
            Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            _SettingGroup(
              children: [
                _SettingItem(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: 'Dark mode',
                  subtitle: isDark ? 'Switch to light theme' : 'Switch to dark theme',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeThumbColor: AppTheme.accent,
                  ),
                  onTap: () => themeProvider.toggleTheme(),
                ),
              ],
            ),
            SizedBox(height: 20),

            // -- App ---------------------------------------------------------
            Text('App', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            _SettingGroup(
              children: [
                _SettingItem(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Recommend the app',
                  subtitle: 'Share Campus Skills Exchange',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thanks for recommending us! Link copied.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                    );
                  },
                ),
                Divider(height: 1, indent: 56),
                _SettingItem(
                  icon: Icons.message_outlined,
                  title: 'Get in touch',
                  subtitle: 'Contact our support team',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening support channels...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // -- Account -----------------------------------------------------
            Text('Account', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            _SettingGroup(
              children: [
                _SettingItem(
                  icon: Icons.logout_rounded,
                  title: 'Sign out',
                  subtitle: 'You will need to sign in again',
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String displayName;
  final String? photoUrl;

  const _UserHeader({required this.displayName, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
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
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
            backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
            child: !hasPhoto
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 22, color: AppTheme.accent, fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                if (FirebaseAuth.instance.currentUser?.email != null)
                  Text(FirebaseAuth.instance.currentUser!.email!, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? AppTheme.accent;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: textColor),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary, size: 20),
      onTap: onTap,
    );
  }
}
