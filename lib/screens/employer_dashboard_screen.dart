import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_request.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'job_details_screen.dart';
import 'post_request_screen.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  bool _isAdding = false;

  void _addNewProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostRequestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('EMPLOYER_CONTROL_CENTER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: AppTheme.accent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('UNAUTHORIZED_ACCESS'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final employerName = (userData?['name'] as String?) ?? 'EMPLOYER';
                final userRole = RoleHelper.fromString(userData?['role']);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .where('requesterId', isEqualTo: currentUser.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final projects = snapshot.data?.docs ?? [];
                    final activeCount = projects.length;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  border: Border.all(color: AppTheme.accent),
                                ),
                                child: const Icon(Icons.business, color: AppTheme.accent, size: 28),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          employerName.toUpperCase(),
                                          style: Theme.of(context).textTheme.headlineMedium,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accent.withOpacity(0.2),
                                            border: Border.all(color: AppTheme.accent),
                                          ),
                                          child: Text(
                                            userRole.name.toUpperCase(),
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
                                    Text(
                                      'ID: ${currentUser.uid.substring(0, 8).toUpperCase()}',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: 'ACTIVE_POSTS', value: activeCount.toString().padLeft(2, '0'))),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: 'HIRED_TALENT', value: '04')),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: 'EMPLOYER_RATING', value: '4.9')),
                            ],
                          ),
                          const SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PROJECT_INVENTORY',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (_isAdding)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                                )
                              else
                                InkWell(
                                  onTap: _addNewProject,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.accent),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.add, color: AppTheme.accent, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'NEW_DEPLOYMENT',
                                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                color: AppTheme.accent,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (projects.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
                              ),
                              child: const Center(
                                  child: Text(
                                    'NO_ACTIVE_DEPLOYMENTS_FOUND',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final data = projects[index].data() as Map<String, dynamic>;
                                final project = ServiceRequest.fromMap(data, projects[index].id);

                                return _ProjectCard(
                                  projectName: project.title.toUpperCase(),
                                  description: project.description,
                                  postedDate: '${DateTime.now().difference(project.createdAt).inDays}D_AGO',
                                  budget: project.budget.toStringAsFixed(0),
                                  status: 'STATUS_OPEN',
                                  onTapView: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobDetailsScreen(
                                          title: project.title,
                                          description: project.description,
                                          companyName: project.requesterName,
                                          budget: 'UGX ${project.budget}',
                                          duration: '1 Month',
                                          status: 'Open',
                                          requiredSkills: const ['Flutter', 'Firebase'],
                                        ),
                                      ),
                                    );
                                  },
                                  onTapEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostRequestScreen(requestToEdit: project),
                                      ),
                                    );
                                  },
                                  onTapDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppTheme.surface,
                                        title: const Text('CONFIRM_DELETION', style: TextStyle(color: AppTheme.textPrimary)),
                                        content: const Text('Are you sure you want to delete this project?', style: TextStyle(color: AppTheme.textSecondary)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseService().deleteServiceRequest(project.id);
                                    }
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.accent,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String projectName;
  final String description;
  final String postedDate;
  final String budget;
  final String status;
  final VoidCallback onTapView;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  const _ProjectCard({
    required this.projectName,
    required this.description,
    required this.postedDate,
    required this.budget,
    required this.status,
    required this.onTapView,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        projectName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _DetailItem(label: 'BUDGET', value: 'UGX $budget'),
                    const SizedBox(width: 24),
                    _DetailItem(label: 'POSTED', value: postedDate),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTapView,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'VIEW_METRICS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.accent),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onTapEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'EDIT_CONFIG',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 44, color: AppTheme.border),
                Expanded(
                  child: InkWell(
                    onTap: onTapDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Center(
                        child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 8, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, fontFamily: 'Courier'),
        ),
      ],
    );
  }
}
