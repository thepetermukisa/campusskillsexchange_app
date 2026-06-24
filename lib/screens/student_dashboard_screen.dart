import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../widgets/my_profile_card.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'post_request_screen.dart';
import 'expert_list_screen.dart';

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
            SnackBar(
              content: Text('ID uploaded! Verification pending.'),
              backgroundColor: AppTheme.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
          );
        }
      }
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Center(child: Text('Not logged in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppTheme.accent));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('User not found.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final currentUser = User.fromMap(data, uid);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, currentUser),
          body: _buildBody(currentUser, data),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, User currentUser) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_greeting()},',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            currentUser.name.split(' ')[0],
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildBody(User currentUser, Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyProfileCard(user: currentUser),
          if (!currentUser.isVerified && data['verificationStatus'] != 'pending') ...[
            SizedBox(height: 16),
            _buildVerificationCard(currentUser.id),
          ],
          SizedBox(height: 24),
          _buildQuickActions(context, currentUser),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(String uid) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(Icons.verified_user_rounded, color: AppTheme.accent, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verify your identity', style: theme.textTheme.titleSmall),
                SizedBox(height: 2),
                Text('Unlock expert status and more visibility', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (_isUploading)
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
          else
            TextButton(
              onPressed: () => _verifyIdentity(uid),
              child: Text('Verify'),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, User currentUser) {
    if (currentUser.role != Role.student) return SizedBox();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Post a Request card
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostRequestScreen())),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C69).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(Icons.send_rounded, size: 24, color: Color(0xFFFF8C69)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Post a Request', style: theme.textTheme.titleMedium),
                        SizedBox(height: 4),
                        Text('Get AI matches for your project needs', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // Browse Skills card
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpertListScreen(categoryName: 'All')),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(Icons.school_rounded, size: 24, color: AppTheme.accent),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Browse Skills', style: theme.textTheme.titleMedium),
                        SizedBox(height: 4),
                        Text('Find verified experts in any category', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
