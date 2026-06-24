import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campusskillexchange_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
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
  bool _obscurePassword = true;
  String _email = '';
  String _password = '';

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        await AuthService().signIn(_email.trim(), _password);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          ),
        );
      }

      if (mounted) setState(() => _isLoading = false);
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
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -- Brand mark ---------------------------------------------
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppTheme.shadowAccent,
                      ),
                      child: Icon(Icons.school_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to continue to Campus Skills Exchange',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 40),

                  // -- Email field --------------------------------------------
                  TextFormField(
                    key: const ValueKey('email'),
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  SizedBox(height: 16),

                  // -- Password field -----------------------------------------
                  TextFormField(
                    key: const ValueKey('password'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _trySubmit(),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  SizedBox(height: 32),

                  // -- Submit button ------------------------------------------
                  if (_isLoading)
                    Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  else
                    ElevatedButton(
                      onPressed: _trySubmit,
                      child: Text('Sign In'),
                    ),
                  SizedBox(height: 16),
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
                    child: Text('Create an account'),
                  ),
                  SizedBox(height: 24),
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
