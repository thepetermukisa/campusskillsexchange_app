import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';
import '../services/firebase_service.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'submit_review_screen.dart';

class ApplicantsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String employerId;

  const ApplicantsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.employerId,
  });

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  bool _isProcessing = false;

  Future<void> _updateStatus(
    Application application,
    String status,
  ) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseService()
          .updateApplicationStatus(application.id, status);

      if (status == 'accepted') {
        // Send a chat notification to the applicant
        await ChatService().sendMessage(
          widget.employerId,
          application.applicantId,
          'Your application for "${widget.jobTitle}" has been accepted! 🎉 Let\'s discuss next steps.',
        );
        // Log activity
        await FirebaseService().logActivity(
          type: 'request',
          message:
              '${application.applicantName} was accepted for "${widget.jobTitle}"',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'accepted'
                  ? 'Applicant accepted! Chat notification sent.'
                  : 'Application rejected.',
            ),
            backgroundColor:
                status == 'accepted' ? Colors.green : Colors.redAccent,
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
              content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Applicants', style: theme.textTheme.bodySmall),
            Text(
              widget.jobTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('jobId', isEqualTo: widget.jobId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs.toList() ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 56,
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.lightTextSecondary),
                  SizedBox(height: 16),
                  Text('No applications yet',
                      style: theme.textTheme.titleMedium),
                  SizedBox(height: 6),
                  Text('Applications will appear here',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }

          var applications = docs
              .map((d) =>
                  Application.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();

          applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (ctx, i) {
              final app = applications[i];
              return _ApplicantCard(
                application: app,
                isProcessing: _isProcessing,
                employerId: widget.employerId,
                onAccept: () => _updateStatus(app, 'accepted'),
                onReject: () => _updateStatus(app, 'rejected'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Application application;
  final bool isProcessing;
  final String employerId;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantCard({
    required this.application,
    required this.isProcessing,
    required this.employerId,
    required this.onAccept,
    required this.onReject,
  });

  Color get _statusColor {
    switch (application.status) {
      case 'accepted':
        return const Color(0xFF34D399);
      case 'rejected':
        return Colors.redAccent;
      default:
        return const Color(0xFFFFB347);
    }
  }

  String get _statusLabel {
    switch (application.status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
            color: isDark ? AppTheme.border : AppTheme.lightBorder,
            width: 0.6),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(userId: application.applicantId)),
                );
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
                      child: Text(
                        application.applicantName.isNotEmpty
                            ? application.applicantName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: AppTheme.accent, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.applicantName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _timeAgo(application.createdAt),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                            color: _statusColor.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (application.message.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                application.message,
                style: theme.textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 12),

            // Action buttons (only for pending)
            if (application.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing ? null : onReject,
                      icon: Icon(Icons.close_rounded, size: 14),
                      label: Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : onAccept,
                      icon: Icon(Icons.check_rounded, size: 14),
                      label: Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Quick message button
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: application.applicantId,
                          receiverName: application.applicantName,
                        ),
                      ),
                    ),
                    icon: Icon(Icons.chat_bubble_outline_rounded,
                        color: AppTheme.accent),
                    tooltip: 'Message applicant',
                  ),
                ],
              )
            else
              // For decided applications, show message and conditionally review
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            receiverId: application.applicantId,
                            receiverName: application.applicantName,
                          ),
                        ),
                      ),
                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 14),
                      label: Text('Message'),
                    ),
                  ),
                  if (application.status == 'accepted') ...[
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmitReviewScreen(
                              targetId: application.applicantId,
                              targetName: application.applicantName,
                            ),
                          ),
                        ),
                        icon: Icon(Icons.star_rate_rounded, size: 14),
                        label: Text('Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
