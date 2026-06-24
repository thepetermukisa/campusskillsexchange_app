import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ApproveEmployersScreen extends StatefulWidget {
  const ApproveEmployersScreen({super.key});

  @override
  State<ApproveEmployersScreen> createState() => _ApproveEmployersScreenState();
}

class _ApproveEmployersScreenState extends State<ApproveEmployersScreen> {
  bool _isProcessing = false;

  Future<void> _handleAction(String userId, String name, bool approved) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseService().updateUser(userId, {
        'isVerified': approved,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name has been ${approved ? 'approved' : 'rejected'}.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approve Employers'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', whereIn: ['Company', 'Employer', 'company', 'employer'])
            .where('isVerified', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          final pendingEmployers = snapshot.data?.docs ?? [];

          if (pendingEmployers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text('No pending employers.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: pendingEmployers.length,
            itemBuilder: (context, index) {
              final doc = pendingEmployers[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown Employer';
              final industry = data['industry'] ?? 'Service Provider';
              final userId = doc.id;

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
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.business, color: Color(0xFFFF6B6B)),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                Text(industry, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(userId, name, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: Text('Decline'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(userId, name, true),
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
