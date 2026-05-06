import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campusskillexchange_app/services/auth_service.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onShowSignup;
  const LoginScreen({super.key, this.onShowSignup});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  // Removed _role from login since we get it from Firestore

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().signIn(_email.trim(), _password);
        // Do not navigate manually! main.dart's StreamBuilder will rebuild the root.
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred.'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SECURE_ACCESS_V4',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'SYSTEM LOGIN',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'AUTHORIZATION REQUIRED TO ACCESS CAMPUS PROTOCOL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 64),
                TextFormField(
                  key: const ValueKey('email'),
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'EMAIL_ADDRESS',
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'INVALID_EMAIL_FORMAT';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const ValueKey('password'),
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'PASSWORD',
                    prefixIcon: Icon(Icons.lock_outline, size: 20),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 7) {
                      return 'INSUFFICIENT_LENGTH_MIN_07';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 48),
                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: AppTheme.accent))
                else
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: const Text('AUTHENTICATE'),
                  ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    if (widget.onShowSignup != null) {
                      widget.onShowSignup!();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    }
                  },
                  child: const Text('REQUEST_NEW_ACCOUNT'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
