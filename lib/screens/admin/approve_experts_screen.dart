import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart' as model;
import '../../services/firebase_service.dart';

class ApproveExpertsScreen extends StatefulWidget {
  const ApproveExpertsScreen({super.key});

  @override
  State<ApproveExpertsScreen> createState() => _ApproveExpertsScreenState();
}

class _ApproveExpertsScreenState extends State<ApproveExpertsScreen> {
  bool _isProcessing = false;

  Future<void> _handleAction(String userId, bool approved) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseService().updateUser(userId, {
        'isVerified': approved,
        // If rejected, we might want to clear the studentIdUrl or keep it for record
        if (!approved) 'studentIdUrl': null, 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? 'Student verified successfully!' : 'Verification rejected.'),
            backgroundColor: approved ? Colors.green : Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showIdPreview(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(url, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('studentIdUrl', isNull: false)
            .where('isVerified', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          final pendingUsers = snapshot.data?.docs ?? [];

          if (pendingUsers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  Text('No pending verifications.', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final doc = pendingUsers[index];
              final user = model.User.fromMap(doc.data() as Map<String, dynamic>, doc.id);

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
                            child: Text(user.name[0], style: const TextStyle(color: Color(0xFFFF6B6B))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                Text(user.email, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showIdPreview(user.studentIdUrl!),
                            child: const Text('View ID', style: TextStyle(color: Color(0xFFFF6B6B))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(user.id, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(user.id, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                              child: const Text('Approve', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
