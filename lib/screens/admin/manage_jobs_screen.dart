import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/service_request.dart';
import '../../services/firebase_service.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  String _searchQuery = '';
  bool _isProcessing = false;

  Future<void> _deleteJob(String jobId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Job Post?'),
        content: Text('Are you sure you want to delete this job post? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      try {
        await FirebaseService().deleteServiceRequest(jobId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job post deleted.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting job: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Jobs'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by title or employer...',
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('requests').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                }

                var docs = snapshot.data?.docs.toList() ?? [];
                
                // Sort locally
                docs.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });
                
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['title'] as String? ?? '').toLowerCase();
                    final employer = (data['requesterName'] as String? ?? '').toLowerCase();
                    return title.contains(_searchQuery) || employer.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Text('No jobs found.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54))),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final request = ServiceRequest.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
                    final isOpen = request.status.toLowerCase() == 'open';
                    
                    return Card(
                      color: Theme.of(context).colorScheme.surface,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    request.title,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOpen ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isOpen ? 'OPEN' : 'CLOSED',
                                    style: TextStyle(
                                      color: isOpen ? Colors.green : Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              request.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 13),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business, size: 14, color: Color(0xFF6B8FFF)),
                                    SizedBox(width: 4),
                                    Text(request.requesterName, style: TextStyle(color: Color(0xFF6B8FFF), fontSize: 12)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 14, color: Color(0xFFFFB347)),
                                    Text(request.budget.toStringAsFixed(0), style: TextStyle(color: Color(0xFFFFB347), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(color: Color(0xFF333333), height: 1),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _isProcessing ? null : () => _deleteJob(request.id),
                                icon: Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                label: Text('Delete Job', style: TextStyle(color: Colors.redAccent)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
