import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campusskillexchange_app/services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback? onShowLogin;
  const SignupScreen({super.key, this.onShowLogin});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _role = 'Student';
  String _name = '';
  String _email = '';
  String _password = '';

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().signUp(_email.trim(), _password, _name.trim(), _role);
        
        if (!mounted) return;
        
        // No manual navigation needed. main.dart StreamBuilder handles it.
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
                      'NETWORK_ENROLLMENT_V4',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'CREATE ACCOUNT',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'INITIALIZE USER PROFILE WITHIN THE CAMPUS ECOSYSTEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 48),
                DropdownButtonFormField<String>(
                  value: _role,
                  dropdownColor: AppTheme.surface,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    labelText: 'ACCOUNT_TYPE',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  items: ['Student', 'Company', 'Administrator']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase())))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const ValueKey('name'),
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'FULL_NAME',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'REQUIRED_FIELD';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                const SizedBox(height: 20),
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
                    child: const Text('ENROLL_SYSTEM'),
                  ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    if (widget.onShowLogin != null) {
                      widget.onShowLogin!();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  child: const Text('EXISTING_OPERATOR_LOGIN'),
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
