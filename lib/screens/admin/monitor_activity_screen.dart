import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonitorActivityScreen extends StatelessWidget {
  const MonitorActivityScreen({super.key});

  /// Fetches the 5 most recent documents from each activity collection,
  /// merges them into one sorted list, and returns the top 20.
  Future<List<_ActivityItem>> _fetchActivity() async {
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get(),
      firestore
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get(),
      firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get(),
      firestore
          .collection('skills')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get(),
    ]);

    final items = <_ActivityItem>[];

    // Users
    for (final doc in results[0].docs) {
      final d = doc.data();
      final name = (d['name'] as String?) ?? 'Unknown';
      final role = (d['role'] as String?) ?? 'User';
      items.add(_ActivityItem(
        title: 'New $role Registered',
        desc: '$name joined as $role',
        icon: Icons.person_add,
        color: Colors.blue,
        timestamp: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }

    // Requests
    for (final doc in results[1].docs) {
      final d = doc.data();
      final title = (d['title'] as String?) ?? 'Unnamed request';
      final requester = (d['requesterName'] as String?) ?? 'Someone';
      items.add(_ActivityItem(
        title: 'Service Request Posted',
        desc: '$requester posted "$title"',
        icon: Icons.post_add,
        color: Colors.orange,
        timestamp: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }

    // Reviews
    for (final doc in results[2].docs) {
      final d = doc.data();
      final reviewer = (d['reviewerName'] as String?) ?? 'Someone';
      final rating = (d['rating'] as num?)?.toDouble() ?? 0;
      items.add(_ActivityItem(
        title: 'New Review Left',
        desc: '$reviewer left a ${rating.toStringAsFixed(1)}★ review',
        icon: Icons.star,
        color: Colors.amber,
        timestamp: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }

    // Skills (expert applications)
    for (final doc in results[3].docs) {
      final d = doc.data();
      final instructor = (d['instructorName'] as String?) ?? 'Someone';
      final skillName = (d['name'] as String?) ?? 'a skill';
      items.add(_ActivityItem(
        title: 'Expert Skill Added',
        desc: '$instructor offered "$skillName"',
        icon: Icons.verified,
        color: Colors.teal,
        timestamp: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items.take(20).toList();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor Activity'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<_ActivityItem>>(
        future: _fetchActivity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Text(
                'No recent activity yet.',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54)),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(color: Color(0xFF333333)),
            itemBuilder: (context, index) {
              final act = items[index];
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                leading: CircleAvatar(
                  backgroundColor: act.color.withValues(alpha: 0.2),
                  child: Icon(act.icon, color: act.color),
                ),
                title: Text(act.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(act.desc,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7))),
                trailing: Text(
                  _timeAgo(act.timestamp),
                  style: TextStyle(
                      color: Color(0xFF9E9E9E), fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final DateTime timestamp;

  const _ActivityItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}
