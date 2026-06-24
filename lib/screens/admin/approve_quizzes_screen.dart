import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApproveQuizzesScreen extends StatefulWidget {
  const ApproveQuizzesScreen({super.key});

  @override
  State<ApproveQuizzesScreen> createState() => _ApproveQuizzesScreenState();
}

class _ApproveQuizzesScreenState extends State<ApproveQuizzesScreen> {
  bool _isProcessing = false;
  final Map<String, int> _oralScores = {};

  Future<void> _handleAction(
    String resultId,
    bool approved, {
    int? oralScore,
    int? averageScore,
    String? level,
    String? userId,
    String? skillName,
  }) async {
    setState(() => _isProcessing = true);
    try {
      if (approved) {
        // 1. Mark as approved with oral and combined stats
        await FirebaseFirestore.instance.collection('quiz_results').doc(resultId).update({
          'status': 'approved',
          'oralScore': oralScore,
          'averageScore': averageScore,
          'level': level,
        });

        // 2. Locate and update corresponding Skill listing
        if (userId != null && skillName != null) {
          final skillSnap = await FirebaseFirestore.instance
              .collection('skills')
              .where('instructorId', isEqualTo: userId)
              .where('name', isEqualTo: skillName)
              .limit(1)
              .get();

          if (skillSnap.docs.isNotEmpty) {
            final skillDocId = skillSnap.docs.first.id;
            await FirebaseFirestore.instance.collection('skills').doc(skillDocId).update({
              'level': level,
              'tags': FieldValue.arrayUnion([level!]),
            });
          }
        }
      } else {
        await FirebaseFirestore.instance.collection('quiz_results').doc(resultId).delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? 'Quiz approved and skill level updated!' : 'Quiz result discarded.'),
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
        title: Text('Approve Quizzes'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quiz_results')
            .where('status', isNotEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          final quizResults = snapshot.data?.docs ?? [];

          if (quizResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text('No quiz results require approval.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: quizResults.length,
            itemBuilder: (context, index) {
              final doc = quizResults[index];
              final data = doc.data() as Map<String, dynamic>;
              final score = data['score'] as int? ?? 0;
              final skillId = data['skillId'] ?? 'Unknown Skill';
              final skillName = data['skillName'] ?? 'Unknown Skill';
              final userId = data['userId'] ?? 'Unknown User';
              final isPass = score >= 60;

              // Get stateful oral score, default to 75
              final oralScore = _oralScores[doc.id] ?? 75;
              final avgScore = ((score + oralScore) / 2).round();

              String level = 'Beginner';
              if (avgScore >= 90) {
                level = 'Expert';
              } else if (avgScore >= 76) {
                level = 'Intermediate';
              }

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
                                    return Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
                                  },
                                ),
                                Text(skillName, style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
                                Text('Skill ID: $skillId', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54), fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPass ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$score%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isPass ? Colors.green : Colors.redAccent,
                                  ),
                                ),
                                Text('Written', style: TextStyle(fontSize: 8, color: Colors.white38)),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(color: Colors.white12),
                      SizedBox(height: 8),
                      // Oral Interview Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Oral Interview Score:', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 13)),
                          Text('$oralScore%', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Slider(
                        value: oralScore.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: const Color(0xFFFF6B6B),
                        inactiveColor: Colors.white12,
                        onChanged: (val) {
                          setState(() {
                            _oralScores[doc.id] = val.round();
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Combined Average:', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 13)),
                          Text('$avgScore%', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Assigned Skill Level:', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 13)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: level == 'Expert' 
                                  ? Colors.green.withValues(alpha: 0.2) 
                                  : level == 'Intermediate'
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: level == 'Expert' 
                                    ? Colors.green 
                                    : level == 'Intermediate'
                                        ? Colors.amber
                                        : Colors.grey,
                              ),
                            ),
                            child: Text(
                              level.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: level == 'Expert' 
                                    ? Colors.green 
                                    : level == 'Intermediate'
                                        ? Colors.amber
                                        : Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : () => _handleAction(doc.id, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: Text('Discard'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_isProcessing || !isPass) 
                                  ? null 
                                  : () => _handleAction(
                                      doc.id, 
                                      true, 
                                      oralScore: oralScore,
                                      averageScore: avgScore,
                                      level: level,
                                      userId: userId,
                                      skillName: skillName,
                                    ),
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
