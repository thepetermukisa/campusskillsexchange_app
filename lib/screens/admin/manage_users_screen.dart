import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart' as model;
import '../../models/role.dart';
import '../../services/firebase_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchQuery = '';
  bool _isProcessing = false;

  Future<void> _toggleBanStatus(String userId, bool currentStatus) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseService().updateUser(userId, {'isBanned': !currentStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!currentStatus ? 'User has been banned.' : 'User has been unbanned.'),
            backgroundColor: !currentStatus ? Colors.redAccent : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _changeRole(String userId, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select New Role'),
        children: ['student', 'employer', 'admin'].map((roleStr) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, roleStr),
            child: Text(roleStr.toUpperCase(), style: TextStyle(
              fontWeight: currentRole.toLowerCase() == roleStr ? FontWeight.bold : FontWeight.normal,
            )),
          );
        }).toList(),
      ),
    );

    if (newRole != null && newRole.toLowerCase() != currentRole.toLowerCase()) {
      setState(() => _isProcessing = true);
      try {
        await FirebaseService().updateUser(userId, {'role': newRole});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role updated successfully.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating role: $e'), backgroundColor: Colors.red),
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
        title: Text('Manage Users'),
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
                hintText: 'Search by name or email...',
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
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                }

                var docs = snapshot.data?.docs ?? [];
                
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    final email = (data['email'] as String? ?? '').toLowerCase();
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Text('No users found.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54))),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = model.User.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
                    
                    return Card(
                      color: Theme.of(context).colorScheme.surface,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: user.isBanned ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(color: user.isBanned ? Colors.red : const Color(0xFFFF6B6B)),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(user.name, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: user.isBanned ? TextDecoration.lineThrough : null,
                              )),
                            ),
                            if (user.isBanned)
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.block, color: Colors.red, size: 16),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(user.email, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7), fontSize: 12)),
                            SizedBox(height: 4),
                            Text('Role: ${RoleHelper.toStringValue(user.role).toUpperCase()}', 
                                style: TextStyle(color: Color(0xFF5CC1B5), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                          color: const Color(0xFF2A2A2A),
                          onSelected: (value) {
                            if (_isProcessing) return;
                            if (value == 'ban') {
                              _toggleBanStatus(user.id, user.isBanned);
                            } else if (value == 'role') {
                              _changeRole(user.id, RoleHelper.toStringValue(user.role));
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'role',
                              child: Text('Change Role', style: TextStyle(color: Colors.white)),
                            ),
                            PopupMenuItem(
                              value: 'ban',
                              child: Text(
                                user.isBanned ? 'Unban User' : 'Ban User',
                                style: TextStyle(color: user.isBanned ? Colors.green : Colors.redAccent),
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
