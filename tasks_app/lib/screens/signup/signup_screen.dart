import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/resuable_widgets.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/services/connectivity_service.dart';
import 'package:tasks_app/utils/app_colors.dart';
import 'package:tasks_app/utils/app_route.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'USER';
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  String? _validateInputs() {
    if (_displayNameController.text.trim().isEmpty) {
      return 'Please enter a display name';
    }
    if (_usernameController.text.trim().isEmpty) {
      return 'Please enter a username';
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
    // if (_departmentController.text.trim().isEmpty) {
    //   return 'Please enter a department';
    // }
    return null;
  }

  Future<bool> _checkConnectivity() async {
    return await _connectivity.hasConnection();
  }

  Future<void> _handleSignup() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      ReusableToast.showToast(
        message: validationError,
        bgColor: AppColors.redColor,
        textColor: AppColors.whiteColor,
        fontSize: 16,
      );
      return;
    }

    final hasConnection = await _checkConnectivity();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<UserProvider>().signUp(
            displayName: _displayNameController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            role: '$_selectedRole',
            department: 'ادراة البرامج وصيانتها',
          );

      if (mounted) {
        final userProvider = context.read<UserProvider>();
        if (userProvider.error != null) {
          ReusableToast.showToast(
            message: userProvider.error!,
            bgColor: AppColors.redColor,
            textColor: AppColors.whiteColor,
            fontSize: 16,
          );
          userProvider.clearError();
        } else {
          ReusableToast.showToast(
            message: 'Account created successfully! Please log in.',
            bgColor: AppColors.greenColor,
            textColor: AppColors.whiteColor,
            fontSize: 16,
          );
          navigateToReplacementNamed(context, AppRoute.loginRouteName);
        }
      }
    } catch (e) {
      log('Signup error: $e');
      if (mounted) {
        ReusableToast.showToast(
          message: 'An unexpected error occurred. Please try again.',
          bgColor: AppColors.redColor,
          textColor: AppColors.whiteColor,
          fontSize: 16,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text(
          'No internet found. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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
                  Text(
                    'Let\'s Get Started!',
                    style: TextStyle(
                      fontSize: fontSize * 2,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  gap(height: 8),
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
                  _buildThemedInputField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    controller: _displayNameController,
                    hintText: 'Display Name',
                    icon: Icons.badge_outlined,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),
                  gap(height: 18),
                  _buildThemedInputField(
                    controller: _usernameController,
                    hintText: 'Username',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    keyboardType: TextInputType.name,
                  ),
                  // gap(height: 18),
                  // _buildThemedInputField(
                  //   controller: _departmentController,
                  //   hintText: 'Department',
                  //   icon: Icons.business_outlined,
                  //   isDark: isDark,
                  //   colorScheme: colorScheme,
                  //   keyboardType: TextInputType.text,
                  // ),
                  // gap(height: 18),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   decoration: BoxDecoration(
                  //     color: isDark ? colorScheme.surface : Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: isDark
                  //         ? Border.all(color: Colors.grey.shade800, width: 1)
                  //         : Border.all(color: Colors.grey.shade300, width: 1),
                  //   ),
                  //   child: DropdownButtonHideUnderline(
                  //     child: DropdownButton<String>(
                  //       value: _selectedRole,
                  //       isExpanded: true,
                  //       dropdownColor:
                  //           isDark ? colorScheme.surface : Colors.white,
                  //       style: TextStyle(
                  //         color: isDark ? Colors.white : Colors.black87,
                  //         fontSize: 16,
                  //       ),
                  //       items: const [
                  //         DropdownMenuItem(
                  //           value: 'USER',
                  //           child: Text('USER'),
                  //         ),
                  //         DropdownMenuItem(
                  //           value: 'MANAGER',
                  //           child: Text('MANAGER'),
                  //         ),
                  //         DropdownMenuItem(
                  //           value: 'ADMIN',
                  //           child: Text('ADMIN'),
                  //         ),
                  //       ],
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _selectedRole = value!;
                  //         });
                  //       },
                  //     ),
                  //   ),
                  // ),
                  gap(height: 18),
                  _buildThemedInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  gap(height: 18),
                  _buildThemedInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  gap(height: 35),
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
                          navigateToReplacementNamed(
                            context,
                            AppRoute.loginRouteName,
                          );
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
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
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
          suffixIcon: suffixIcon,
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
          fillColor:
              isDark ? colorScheme.surface.withOpacity(0.5) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
