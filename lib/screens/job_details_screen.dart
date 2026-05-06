import 'package:flutter/material.dart';

class JobDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String companyName;
  final String budget;
  final String duration;
  final String status;
  final List<String> requiredSkills;

  const JobDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.companyName,
    required this.budget,
    required this.duration,
    required this.status,
    required this.requiredSkills,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: const Icon(Icons.business, color: Color(0xFFFF6B6B), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: const TextStyle(fontSize: 16, color: Color(0xFFFF6B6B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildBadge(Icons.attach_money, budget),
                const SizedBox(width: 12),
                _buildBadge(Icons.timer_outlined, duration),
                const SizedBox(width: 12),
                _buildBadge(Icons.info_outline, status, isStatus: true),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Job Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Color(0xFFCCCCCC), height: 1.5),
            ),
            const SizedBox(height: 30),
            const Text(
              'Required Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: requiredSkills.map((skill) => Chip(
                label: Text(skill, style: const TextStyle(color: Colors.white)),
                backgroundColor: const Color(0xFF1E1E1E),
                side: const BorderSide(color: Color(0xFF333333)),
              )).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted successfully!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Apply Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, {bool isStatus = false}) {
    Color bgColor = const Color(0xFF1E1E1E);
    Color textColor = const Color(0xFFCCCCCC);
    
    if (isStatus) {
      bgColor = text == 'Open' ? const Color(0xFF4CAF50).withOpacity(0.2) : const Color(0xFF9E9E9E).withOpacity(0.2);
      textColor = text == 'Open' ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isStatus ? Colors.transparent : const Color(0xFF333333)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isStatus ? textColor : const Color(0xFFFF6B6B)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
