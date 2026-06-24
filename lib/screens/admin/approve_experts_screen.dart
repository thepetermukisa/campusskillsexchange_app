import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart' as model;

class ApproveExpertsScreen extends StatefulWidget {
  const ApproveExpertsScreen({super.key});

  @override
  State<ApproveExpertsScreen> createState() => _ApproveExpertsScreenState();
}

class _ApproveExpertsScreenState extends State<ApproveExpertsScreen> {
  bool _isProcessing = false;

  Future<void> _handleAction(String userId, String userName, bool approved) async {
    setState(() => _isProcessing = true);
    try {
      if (approved) {
        // Find the user's pending skill listing to get the skill name
        final skillSnap = await FirebaseFirestore.instance
            .collection('skills')
            .where('instructorId', isEqualTo: userId)
            .limit(1)
            .get();

        List<String> skillNames = [];
        if (skillSnap.docs.isNotEmpty) {
          final skillData = skillSnap.docs.first.data();
          final skillName = skillData['name'] as String? ?? '';
          if (skillName.isNotEmpty) skillNames = [skillName];
        }

        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isVerified': true,
          'verificationStatus': 'verified',
          if (skillNames.isNotEmpty) 'subSkills': FieldValue.arrayUnion(skillNames),
        });

        // Log activity
        await FirebaseFirestore.instance.collection('activity').add({
          'type': 'skill',
          'message': '$userName was verified as an expert',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isVerified': false,
          'studentIdUrl': null,
          'verificationStatus': 'rejected',
        });
      }

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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close'),
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
        title: Text('ID Verification'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          final pendingUsers = snapshot.data?.docs ?? [];

          if (pendingUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 18)),
                  Text('No pending verifications.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final doc = pendingUsers[index];
              final user = model.User.fromMap(doc.data() as Map<String, dynamic>, doc.id);

              return Card(
                color: Theme.of(context).colorScheme.surface,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                            child: Text(user.name[0], style: TextStyle(color: Color(0xFFFF6B6B))),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                Text(user.email, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 12)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showIdPreview(user.studentIdUrl!),
                            child: Text('View ID', style: TextStyle(color: Color(0xFFFF6B6B))),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(user.id, user.name, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: Text('Reject'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(user.id, user.name, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                              child: Text('Approve', style: TextStyle(color: Colors.white)),
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
