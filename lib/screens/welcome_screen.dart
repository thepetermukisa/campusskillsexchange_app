import 'package:flutter/material.dart';
import './login_screen.dart';
import './signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Campus Skill Exchange',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Learn, Teach, and Grow',
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 15,
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const SignupScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: EdgeInsets.symmetric(
                  horizontal: 72,
                  vertical: 15,
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
