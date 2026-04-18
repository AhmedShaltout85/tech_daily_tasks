
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/resuable_widgets.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/employee_name_provider.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/screens/auth/auth_wrapper.dart';

import '../login/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Validates all input fields before signup
  String? _validateInputs() {
    if (_firstNameController.text.trim().isEmpty) {
      return 'Please enter your first name';
    }
    if (_lastNameController.text.trim().isEmpty) {
      return 'Please enter your last name';
    }
    if (_userNameController.text.trim().isEmpty) {
      return 'Please enter a username';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      return 'Please enter a valid email address';
    }
    if (_passwordController.text.isEmpty) {
      return 'Please enter a password';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (_confirmPasswordController.text.isEmpty) {
      return 'Please confirm your password';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Email validation helper
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Comprehensive Firebase Auth exception handler
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    log('🔥 Firebase Auth Error: ${e.code} - ${e.message}');

    switch (e.code) {
      // Email-related errors
      case 'email-already-in-use':
        return 'This email is already registered. Please login or use a different email.';
      case 'invalid-email':
        return 'Invalid email address format. Please check and try again.';

      // Password-related errors
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';

      // Account-related errors
      case 'user-not-found':
        return 'No account found with this email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';

      // Operation errors
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';

      // Credential errors
      case 'invalid-credential':
        return 'Invalid credentials provided. Please check your information.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account.';

      // Network errors
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';

      // Token errors
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please restart the process.';

      // Quota errors
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';

      // Default case
      default:
        log('⚠️ Unhandled Firebase error code: ${e.code}');
        return 'Signup failed: ${e.message ?? "An unexpected error occurred"}';
    }
  }

  /// Handle the signup process
  Future<void> _handleSignup() async {
    // Validate inputs first
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorToast(validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      log('📝 Starting signup process...');

      // Create Firebase account
      // await FirebaseApiSAuthServices.createUserWithEmailAndPassword(
      //   emailAddress: _emailController.text.trim(),
      //   password: _passwordController.text.trim(),
      // );
      log('✅ Firebase account created');

      // Get user data
      // final userId = FirebaseAuth.instance.currentUser!.uid;
      final displayName = capitalizeFirstLetter(
        _userNameController.text.trim(),
      );

      // Save to Firestore
      // await AddNewUserToDB.saveUser({
      //   'id': userId,
      //   'firstName': capitalizeFirstLetter(_firstNameController.text.trim()),
      //   'lastName': capitalizeFirstLetter(_lastNameController.text.trim()),
      //   'displayName': displayName,
      //   'email': _emailController.text.trim(),
      //   'password': _passwordController.text.trim(),
      // });
      log('✅ User saved to Firestore');

      // Update display name
      await FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
      log('✅ Display name updated');

      // Add to provider
      if (context.mounted) {
        await context.read<EmployeeNameProvider>().addEmployeeName(displayName);
        log('✅ Employee name added to provider');
      }

      // Sign out immediately
      log('🚪 Signing out user...');
      await FirebaseAuth.instance.signOut();
      log('✅ User signed out successfully');

      // Small delay for auth state propagation
      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        _showSuccessToast('Account created successfully! Please log in.');

        // Navigate to login
        log('🧭 Navigating to AuthWrapper...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
        log('✅ Navigation completed');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      final errorMessage = _handleFirebaseAuthException(e);

      // Clean up: sign out if account was partially created
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {
        log('⚠️ Could not sign out after error');
      }

      if (context.mounted) {
        _showErrorToast(errorMessage);
      }
    } catch (e, stackTrace) {
      // Handle any other errors
      log('❌ Unexpected signup error: $e');
      log('Stack trace: $stackTrace');

      // Clean up
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}

      if (context.mounted) {
        _showErrorToast('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show error toast helper
  void _showErrorToast(String message) {
    ReusableToast.showToast(
      message: message,
      textColor: Colors.white,
      fontSize: 16,
      bgColor: Colors.red,
    );
  }

  /// Show success toast helper
  void _showSuccessToast(String message) {
    ReusableToast.showToast(
      message: message,
      textColor: Colors.white,
      fontSize: 16,
      bgColor: Colors.green,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final double fontSize = 14;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),

                  gap(height: 24),

                  // Title
                  Text(
                    'Let\'s Get Started!',
                    style: TextStyle(
                      fontSize: fontSize * 2,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  gap(height: 8),

                  // Subtitle
                  Text(
                    'Create an account on TASKS to get all features',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.normal,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  gap(height: 35),

                  // First Name field
                  _buildThemedInputField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    controller: _firstNameController,
                    hintText: 'First Name',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),

                  gap(height: 18),

                  // Last Name field
                  _buildThemedInputField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    controller: _lastNameController,
                    hintText: 'Last Name',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),

                  gap(height: 18),

                  // User Name field
                  _buildThemedInputField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    controller: _userNameController,
                    hintText: 'User Name',
                    icon: Icons.badge_outlined,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),

                  gap(height: 18),

                  // Email field
                  _buildThemedInputField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  gap(height: 18),

                  // Password field
                  _buildThemedInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    obscureText: true,
                  ),

                  gap(height: 18),

                  // Confirm Password field
                  _buildThemedInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    obscureText: true,
                  ),

                  gap(height: 35),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: isDark ? Colors.black87 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: isDark ? Colors.black87 : Colors.white,
                              ),
                            )
                          : Text(
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                fontSize: fontSize + 2,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  gap(height: 25),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.normal,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigateTo(context, const LoginScreen());
                        },
                        child: Text(
                          'Login here',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemedInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    required ColorScheme colorScheme,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: Colors.grey.shade800, width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          prefixIcon: Icon(icon, color: colorScheme.primary, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: isDark
              ? colorScheme.surface.withOpacity(0.5)
              : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
