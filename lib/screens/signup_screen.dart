import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campusskillexchange_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32),
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
                          SizedBox(width: 12),
                          Text(
                            'Getting Started',
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join the Campus Skills Exchange community',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      SizedBox(height: 48),
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        dropdownColor: theme.colorScheme.surface,
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Account Type',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        ),
                        items: ['Student', 'Employer', 'Administrator']
                            .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        key: const ValueKey('name'),
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        key: const ValueKey('email'),
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.alternate_email, size: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        key: const ValueKey('password'),
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 7) {
                            return 'Password must be at least 7 characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      SizedBox(height: 48),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator(color: AppTheme.accent))
                      else
                        ElevatedButton(
                          onPressed: _trySubmit,
                          child: Text('Sign Up'),
                        ),
                      SizedBox(height: 24),
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
                        child: Text('I already have an account'),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode, color: theme.colorScheme.primary),
                tooltip: 'Toggle Theme',
                onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
