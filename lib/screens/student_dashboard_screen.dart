import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../models/skill.dart';
import '../models/skill_category.dart';
import '../models/service_request.dart';
import '../widgets/category_card.dart';
import '../widgets/my_profile_card.dart';
import '../services/firebase_service.dart';
import '../services/ai_matchmaking_service.dart';
import '../theme/app_theme.dart';
import 'become_expert_screen.dart';
import 'post_request_screen.dart';
import 'chat_list_screen.dart';
import 'profile_screen.dart';

// Static category definitions — these are domain constants, not dummy data.
const _kCategories = [
  SkillCategory(id: 'cat_programming', name: 'Programming', icon: 'code'),
  SkillCategory(id: 'cat_it',          name: 'IT',          icon: 'computer'),
  SkillCategory(id: 'cat_design',      name: 'Design',      icon: 'palette'),
  SkillCategory(id: 'cat_multimedia',  name: 'Multimedia',  icon: 'movie'),
  SkillCategory(id: 'cat_security',    name: 'Security',    icon: 'lock'),
];

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isUploading = false;

  Future<void> _verifyIdentity(String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);
      final String? url =
          await FirebaseService().uploadImage(image, 'id_verifications/$uid.jpg');
      if (url != null) {
        await FirebaseService().updateUserVerificationStatus(uid, url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID Uploaded! Verification pending.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) setState(() => _isUploading = false);
    }
  }

  /// Queries Firestore once to get expert counts per category.
  Future<List<SkillCategory>> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('skills').get();

    final Map<String, int> counts = {};
    for (final doc in snapshot.docs) {
      final cat = (doc.data()['category'] as String?) ?? '';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    return _kCategories
        .map((c) => c.copyWith(expertCount: counts[c.name] ?? 0))
        .toList();
  }

  /// Fetches the latest request for this user, then asks Gemini to match
  /// against real skills from Firestore.
  Future<List<Skill>> _fetchAIRecommendations(String uid) async {
    // 1. Get latest request
    final reqSnap = await FirebaseFirestore.instance
        .collection('requests')
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (reqSnap.docs.isEmpty) return [];

    final latestRequest = ServiceRequest.fromMap(
      reqSnap.docs.first.data(),
      reqSnap.docs.first.id,
    );

    // 2. Get all skills from Firestore
    final skillsSnap =
        await FirebaseFirestore.instance.collection('skills').get();
    final allSkills = skillsSnap.docs
        .map((d) => Skill.fromMap(d.data(), d.id))
        .toList();

    if (allSkills.isEmpty) return [];

    // 3. Ask Gemini to rank them
    final matchedIds = await AIMatchmakingService.getMatches(
      request: latestRequest,
      availableSkills: allSkills,
    );

    // 4. Return matched Skill objects in order
    return matchedIds
        .map((id) {
          try {
            return allSkills.firstWhere((s) => s.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Skill>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Not logged in'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: AppTheme.accent));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User not found.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final currentUser = User.fromMap(data, uid);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: const Color(0xFF161616),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAMPUS SKILL EXCHANGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accent,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Welcome, ${currentUser.name.split(' ')[0].toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        border: Border.all(color: AppTheme.accent),
                      ),
                      child: Text(
                        currentUser.role.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.logout_outlined, color: AppTheme.textSecondary),
              ),
            ],
          ),
          body: _buildBody(currentUser, data),
        );
      },
    );
  }

  Widget _buildBody(User currentUser, Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyProfileCard(user: currentUser),
          if (!currentUser.isVerified &&
              data['verificationStatus'] != 'pending') ...[
            const SizedBox(height: 24),
            _buildVerificationCard(currentUser.id),
          ],
          const SizedBox(height: 32),
          _buildQuickActions(context, currentUser),
          const SizedBox(height: 48),
          _buildSectionHeader('AI RECOMMENDATIONS', 'SMART_MATCH_V2'),
          const SizedBox(height: 24),
          _buildRecommendedSkills(currentUser.id),
          const SizedBox(height: 48),
          _buildSectionHeader('BROWSE CATEGORIES', 'SYSTEM_CORE'),
          const SizedBox(height: 24),
          FutureBuilder<List<SkillCategory>>(
            future: _fetchCategories(),
            builder: (context, catSnapshot) {
              final categories = catSnapshot.data ?? _kCategories.toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: categories.length,
                itemBuilder: (ctx, i) =>
                    CategoryCard(category: categories[i]),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String tag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              color: AppTheme.accent,
            ),
            const SizedBox(width: 8),
            Text(
              tag,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildVerificationCard(String uid) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_outlined,
                  color: AppTheme.accent, size: 24),
              const SizedBox(width: 12),
              Text(
                'IDENTITY VERIFICATION',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Upgrade to expert status by verifying your student ID.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_isUploading)
            LinearProgressIndicator(color: AppTheme.accent)
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _verifyIdentity(uid),
                child: const Text('START VERIFICATION'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, User currentUser) {
    final buttons = <Widget>[];
    
    // All roles can see MESSAGES
    buttons.add(
      Expanded(
        child: _QuickActionButton(
          icon: Icons.message_outlined,
          label: 'MESSAGES',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const ChatListScreen()),
          ),
        ),
      ),
    );
    
    // Students and Employers can OFFER SKILL
    if (currentUser.role == Role.student || currentUser.role == Role.employer) {
      buttons.insertAll(0, [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_box_outlined,
            label: 'OFFER SKILL',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const BecomeExpertScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ]);
    }
    
    // Students can REQUEST
    if (currentUser.role == Role.student) {
      buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: _QuickActionButton(
            icon: Icons.send_outlined,
            label: 'REQUEST',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const PostRequestScreen()),
            ),
          ),
        ),
      );
    }
    
    return Row(
      children: buttons,
    );
  }

  Widget _buildRecommendedSkills(String uid) {
    return FutureBuilder<List<Skill>>(
      future: _fetchAIRecommendations(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
          );
        }

        final matchedSkills = snapshot.data ?? [];

        if (matchedSkills.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              color: AppTheme.surface,
            ),
            child: const Center(
              child: Text(
                'NO RELEVANT MATCHES FOUND.\nPOST A REQUEST TO TRIGGER AI MATCHING.',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.0,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matchedSkills.length,
            itemBuilder: (context, index) =>
                _buildMatchCard(matchedSkills[index]),
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(Skill skill) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MATCH // 0${skill.id.hashCode % 9}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Icon(Icons.auto_awesome, color: AppTheme.accent, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            skill.name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'INSTRUCTOR: ${skill.instructorName.toUpperCase()}',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: skill.instructorId),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('VIEW PROFILE', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accent, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
