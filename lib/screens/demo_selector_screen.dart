import 'package:campusskillexchange_app/screens/admin_dashboard_screen.dart';
import 'package:campusskillexchange_app/screens/employer_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:campusskillexchange_app/screens/home_screen.dart';

class DemoSelectorScreen extends StatelessWidget {
  const DemoSelectorScreen({super.key});

  void _navigateToRole(BuildContext context, String role) {
    Widget screen;
    switch (role) {
      case 'Student':
        screen = const HomeScreen();
        break;
      case 'Employer':
        screen = const EmployerDashboardScreen();
        break;
      case 'Administrator':
        screen = const AdminDashboardScreen();
        break;
      default:
        screen = const HomeScreen();
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildRoleCard(
    BuildContext context,
    String role,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToRole(context, role),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.7), color.withValues(alpha: 0.4)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                role,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tap to Enter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface,
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              // Header
              Text(
                'Campus Skill Exchange',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Demo Mode - Select Your Role',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 50),
              // Role Cards
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 1,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.5,
                    children: [
                      _buildRoleCard(
                        context,
                        'Student',
                        Icons.school,
                        Colors.blue,
                        'Browse skills, connect with experts, and enhance your learning',
                      ),
                      _buildRoleCard(
                        context,
                        'Employer',
                        Icons.business,
                        Colors.green,
                        'Find talented students and offer internship opportunities',
                      ),
                      _buildRoleCard(
                        context,
                        'Administrator',
                        Icons.admin_panel_settings,
                        Colors.orange,
                        'Manage platform, users, and monitor activities',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
