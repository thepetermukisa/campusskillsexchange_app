import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApproveQuizzesScreen extends StatefulWidget {
  const ApproveQuizzesScreen({super.key});

  @override
  State<ApproveQuizzesScreen> createState() => _ApproveQuizzesScreenState();
}

class _ApproveQuizzesScreenState extends State<ApproveQuizzesScreen> {
  bool _isProcessing = false;

  Future<void> _handleAction(String resultId, bool approved) async {
    setState(() => _isProcessing = true);
    try {
      if (approved) {
        // In a real app, we'd add the skill to the user's profile here
        // For now, we'll just mark the result as processed/approved
        await FirebaseFirestore.instance.collection('quiz_results').doc(resultId).update({
          'status': 'approved',
        });
      } else {
        await FirebaseFirestore.instance.collection('quiz_results').doc(resultId).delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? 'Quiz result approved!' : 'Quiz result discarded.'),
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
        title: const Text('Approve Quizzes'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quiz_results')
            .where('status', isNotEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          final quizResults = snapshot.data?.docs ?? [];

          if (quizResults.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text('No quiz results require approval.', style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizResults.length,
            itemBuilder: (context, index) {
              final doc = quizResults[index];
              final data = doc.data() as Map<String, dynamic>;
              final score = data['score'] as int? ?? 0;
              final skillId = data['skillId'] ?? 'Unknown Skill';
              final userId = data['userId'] ?? 'Unknown User';
              final isPass = score >= 60;

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                                  builder: (context, userSnap) {
                                    final name = (userSnap.data?.data() as Map<String, dynamic>?)?['name'] ?? 'User';
                                    return Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
                                  },
                                ),
                                Text('Skill ID: $skillId', style: const TextStyle(color: Color(0xFFCCCCCC))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPass ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$score%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPass ? Colors.green : Colors.redAccent,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(doc.id, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: const Text('Discard'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_isProcessing || !isPass) ? null : () => _handleAction(doc.id, true),
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
