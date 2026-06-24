import 'package:campusskillexchange_app/screens/auth_screen.dart';
import 'package:campusskillexchange_app/screens/home_screen.dart';
import 'package:campusskillexchange_app/screens/employer_dashboard_screen.dart';
import 'package:campusskillexchange_app/screens/admin_dashboard_screen.dart';
import 'package:campusskillexchange_app/services/auth_service.dart';
import 'package:campusskillexchange_app/models/role.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './theme/theme_provider.dart';
import './theme/app_theme.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initial seeding should not run from the unauthenticated client.
  // Use a secure admin script or emulator-based seed process instead.
  // await SeedingService.seedInitialData();
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is logged in, navigate based on the ensured Firestore profile.
            return FutureBuilder<Role>(
              future: AuthService().ensureUserDocument(snapshot.data!),
                builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                  );
                }

                if (roleSnapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'PROFILE_SYNC_FAILED',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Firebase account exists, but the app could not create or read your profile. Check Firestore rules and network access, then try again.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => AuthService().signOut(),
                              child: const Text('SIGN_OUT'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final role = roleSnapshot.data;
                if (role == Role.employer) {
                  return const EmployerDashboardScreen();
                } else if (role == Role.administrator) {
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
