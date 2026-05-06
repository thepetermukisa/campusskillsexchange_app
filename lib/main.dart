import 'package:campusskillexchange_app/screens/auth_screen.dart';
import 'package:campusskillexchange_app/screens/home_screen.dart';
import 'package:campusskillexchange_app/screens/company_dashboard_screen.dart';
import 'package:campusskillexchange_app/screens/admin_dashboard_screen.dart';
import 'package:campusskillexchange_app/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './theme/theme_provider.dart';
import './theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Campus Skill Exchange',
      theme: AppTheme.theme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is logged in, navigate based on role from Firestore
            return FutureBuilder<String?>(
              future: AuthService().getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                  );
                }
                
                final role = roleSnapshot.data;
                if (role == 'company') {
                  return const CompanyDashboardScreen();
                } else if (role == 'administrator') {
                  return const AdminDashboardScreen();
                } else {
                  return const HomeScreen(); // Default to student
                }
              },
            );
          }
          // User is not logged in
          return const AuthScreen();
        },
      ),
    );
  }
}
