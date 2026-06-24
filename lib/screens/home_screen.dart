import 'package:flutter/material.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/job_board_screen.dart';
import '../screens/expert_list_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/become_expert_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentDashboardScreen(),
    const JobBoardScreen(),
    const ExpertListScreen(categoryName: 'All'),
    const ChatListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BecomeExpertScreen()),
          );
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        tooltip: 'Offer a Skill',
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Skills',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
