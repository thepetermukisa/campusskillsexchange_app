// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User header — loaded from Firestore ──────────────────────
            if (firebaseUser != null)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(firebaseUser.uid)
                    .get(),
                builder: (context, snapshot) {
                  String displayName = firebaseUser.displayName ??
                      firebaseUser.email ??
                      'User';
                  String? photoUrl = firebaseUser.photoURL;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    displayName = (data['name'] as String?)?.isNotEmpty == true
                        ? data['name'] as String
                        : displayName;
                    photoUrl = (data['profileImageUrl'] as String?)
                            ?.isNotEmpty == true
                        ? data['profileImageUrl'] as String
                        : photoUrl;
                  }

                  return _UserHeader(
                      displayName: displayName, photoUrl: photoUrl);
                },
              ),

            const SizedBox(height: 16),

            // ── Settings options ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _SettingItem(
                    icon: Icons.light_mode,
                    title: 'Dark mode',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeThumbColor: const Color(0xFFFF6B6B),
                      activeTrackColor:
                          const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                    ),
                    onTap: () {},
                  ),
                  const Divider(),
                  _SettingItem(
                    icon: Icons.thumb_up_alt_outlined,
                    title: 'Recommend',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Thanks for recommending our app! Link copied to clipboard.')),
                      );
                    },
                  ),
                  const Divider(),
                  _SettingItem(
                    icon: Icons.message_outlined,
                    title: 'Get in touch',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Opening Support channels...')),
                      );
                    },
                  ),
                  const Divider(),
                  _SettingItem(
                    icon: Icons.logout,
                    title: 'Sign out',
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── User header widget ────────────────────────────────────────────────────────
class _UserHeader extends StatelessWidget {
  final String displayName;
  final String? photoUrl;

  const _UserHeader({required this.displayName, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                const Color(0xFFFF6B6B).withValues(alpha: 0.2),
            backgroundImage:
                hasPhoto ? NetworkImage(photoUrl!) : null,
            child: !hasPhoto
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                if (FirebaseAuth.instance.currentUser?.email != null)
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Setting item ──────────────────────────────────────────────────────────────
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? const Color(0xFFFF6B6B)),
      title: Text(
        title,
        style: TextStyle(
            color: textColor ??
                Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
