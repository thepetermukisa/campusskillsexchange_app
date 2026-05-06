import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User not found.'));
                }
                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final currentUser = User.fromMap(data, uid);
                return _ProfileBody(user: currentUser);
              },
            ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final User user;
  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
                  backgroundImage: (user.profileImageUrl != null &&
                          user.profileImageUrl!.isNotEmpty)
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: (user.profileImageUrl == null ||
                          user.profileImageUrl!.isEmpty)
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 28,
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
                        user.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: const TextStyle(color: Color(0xFFCCCCCC))),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          user.subSkills.isNotEmpty ? 'Expert' : 'Student',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: user.subSkills.isNotEmpty
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF4CAF50),
                        labelStyle:
                            const TextStyle(color: Colors.white),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // ── Expert details ───────────────────────────────────────────────
          if (user.subSkills.isNotEmpty) ...[
            const Text('Expert Details',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                          label: 'Jobs',
                          value: user.completedJobs.toString(),
                          icon: Icons.work_outline),
                      _StatItem(
                          label: 'Rating',
                          value: user.rating.toStringAsFixed(1),
                          icon: Icons.star_border),
                      _StatItem(
                          label: 'Reviews',
                          value: user.reviews.toString(),
                          icon: Icons.reviews_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF333333)),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Skills & Endorsements',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.subSkills
                          .map((skill) => Chip(
                                label: Text(skill,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white)),
                                backgroundColor:
                                    const Color(0xFF333333),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],

          // ── Account options ──────────────────────────────────────────────
          const Text('Account Options',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          const _ProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'View and manage your notifications'),
          const _ProfileOption(
              icon: Icons.language_outlined,
              title: 'Change language',
              subtitle: 'English (US)'),
          const SizedBox(height: 20),
          const Text('Support',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          const _ProfileOption(
              icon: Icons.chat_bubble_outline,
              title: 'Get in touch',
              subtitle: 'Email, call or find us on social media'),
          const _ProfileOption(
              icon: Icons.help_outline,
              title: 'Guides and tours',
              subtitle: 'What do you want to learn today?'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6B6B), size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC))),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFF6B6B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFCCCCCC))),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF666666)),
        ],
      ),
    );
  }
}
