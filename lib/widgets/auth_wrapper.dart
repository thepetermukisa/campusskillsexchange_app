import 'package:campusskillexchange_app/screens/home_screen.dart';
import 'package:campusskillexchange_app/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final role = userData['role']?.toString().toLowerCase();

                switch (role) {
                  case 'student':
                    return const HomeScreen();
                  case 'company':
                  case 'employer':
                    return const HomeScreen();
                  case 'administrator':
                    return const HomeScreen();
                  default:
                    return const WelcomeScreen();
                }
              }

              return const WelcomeScreen();
            },
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}
