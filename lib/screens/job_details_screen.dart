import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_request.dart';
import '../services/firebase_service.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final String title;
  final String description;
  final String companyName;
  final String budget;
  final String duration;
  final String status;
  final List<String> requiredSkills;
  // Optional — when the full request object is available
  final ServiceRequest? request;

  const JobDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.companyName,
    required this.budget,
    required this.duration,
    required this.status,
    required this.requiredSkills,
    this.request,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isApplying = false;
  bool _hasApplied = false;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkIfApplied() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final jobId = widget.request?.id;
    if (uid == null || jobId == null || jobId.isEmpty) return;

    final applied = await FirebaseService().hasApplied(jobId, uid);
    if (mounted) setState(() => _hasApplied = applied);
  }

  Future<void> _apply() async {
    final user = FirebaseAuth.instance.currentUser;
    final request = widget.request;
    if (user == null) return;

    // If we don't have a full request object, just show a snackbar
    if (request == null || request.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot apply: job data unavailable.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Show message dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Apply for this Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Include a short message to ${widget.companyName}:'),
            SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Briefly describe why you are a good fit...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isApplying = true);

    try {
      // Fetch applicant name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final applicantName = userDoc.data()?['name'] ?? 'Applicant';

      // Submit application document
      await FirebaseService().submitApplication({
        'jobId': request.id,
        'jobTitle': request.title,
        'applicantId': user.uid,
        'applicantName': applicantName,
        'employerId': request.requesterId,
        'message': _messageController.text.trim(),
      });

      // Notify employer via chat
      await ChatService().sendMessage(
        user.uid,
        request.requesterId,
        '$applicantName applied for your job: "${request.title}"',
      );

      // Log activity
      await FirebaseService().logActivity(
        type: 'request',
        message: '$applicantName applied for "${request.title}"',
      );

      if (mounted) {
        setState(() => _hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application submitted! Employer notified.'),
            backgroundColor: const Color(0xFF34D399),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error applying: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _messageEmployer() async {
    final user = FirebaseAuth.instance.currentUser;
    final request = widget.request;
    if (user == null || request == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: request.requesterId,
          receiverName: widget.companyName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwnPost = widget.request?.requesterId == currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                    color: isDark ? AppTheme.border : AppTheme.lightBorder,
                    width: 0.6),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(Icons.business_rounded,
                        color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.companyName,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Badges row
            Row(
              children: [
                _buildBadge(theme, Icons.payments_outlined, widget.budget),
                SizedBox(width: 10),
                _buildBadge(theme, Icons.timer_outlined, widget.duration),
                SizedBox(width: 10),
                _buildStatusBadge(theme, widget.status),
              ],
            ),
            SizedBox(height: 24),

            // Description
            Text('Job Description',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 10),
            Text(
              widget.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            SizedBox(height: 24),

            // Required Skills
            if (widget.requiredSkills.isNotEmpty) ...[
              Text('Required Skills',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.requiredSkills
                    .map((skill) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                                color:
                                    AppTheme.accent.withValues(alpha: 0.3)),
                          ),
                          child: Text(skill,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
              SizedBox(height: 80),
            ] else
              SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: isOwnPost
          ? null
          : SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (widget.request != null) ...[
                      // Message Employer button
                      OutlinedButton.icon(
                        onPressed: _messageEmployer,
                        icon: Icon(Icons.chat_bubble_outline_rounded,
                            size: 16),
                        label: Text('Message'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLg)),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_hasApplied || _isApplying) ? null : _apply,
                        icon: _isApplying
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Icon(
                                _hasApplied
                                    ? Icons.check_circle_rounded
                                    : Icons.send_rounded,
                                size: 16),
                        label: Text(
                          _hasApplied
                              ? 'Already Applied'
                              : _isApplying
                                  ? 'Applying…'
                                  : 'Apply Now',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasApplied
                              ? const Color(0xFF34D399)
                              : AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLg)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBadge(ThemeData theme, IconData icon, String text) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
            color: isDark ? AppTheme.border : AppTheme.lightBorder, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          SizedBox(width: 6),
          Text(text,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    final isOpen = status.toLowerCase() == 'open';
    final color = isOpen ? const Color(0xFF34D399) : Colors.grey;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          SizedBox(width: 6),
          Text(status,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
