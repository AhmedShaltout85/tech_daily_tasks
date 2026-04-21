import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/services/connectivity_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ConnectivityService _connectivity = ConnectivityService();

  Future<bool> _checkConnectivity() async {
    return await _connectivity.hasConnection();
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

  void _showChangePasswordDialog(bool isDark, ColorScheme colorScheme) {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: isDark ? colorScheme.surface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lock_reset,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: !showCurrentPassword,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                      hintText: 'Enter current password',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onPressed: () {
                          setDialogState(() {
                            showCurrentPassword = !showCurrentPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? colorScheme.surface.withValues(alpha: 0.5)
                          : Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: !showNewPassword,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                      hintText: 'Enter new password',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onPressed: () {
                          setDialogState(() {
                            showNewPassword = !showNewPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? colorScheme.surface.withValues(alpha: 0.5)
                          : Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                      hintText: 'Re-enter new password',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onPressed: () {
                          setDialogState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? colorScheme.surface.withValues(alpha: 0.5)
                          : Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  final hasConnection =
                                      await _checkConnectivity();
                                  if (!hasConnection) {
                                    _showNoInternetDialog();
                                    return;
                                  }

                                  setDialogState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    final userProvider =
                                        Provider.of<UserProvider>(
                                      dialogContext,
                                      listen: false,
                                    );

                                    await userProvider.changePassword(
                                      currentPassword:
                                          currentPasswordController.text,
                                      newPassword: newPasswordController.text,
                                    );

                                    if (!dialogContext.mounted) return;

                                    if (userProvider.error != null) {
                                      ReusableToast.showToast(
                                        message: userProvider.error!,
                                        bgColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16,
                                      );
                                      userProvider.clearError();
                                    } else {
                                      Navigator.pop(dialogContext);
                                      ReusableToast.showToast(
                                        message:
                                            'Password changed successfully',
                                        bgColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16,
                                      );
                                    }
                                  } catch (e) {
                                    if (!dialogContext.mounted) return;
                                    ReusableToast.showToast(
                                      message:
                                          'Failed to change password. Please try again.',
                                      bgColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16,
                                    );
                                  } finally {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? Colors.black87 : Colors.white,
                                ),
                              )
                            : const Text(
                                'Change Password',
                                style: TextStyle(fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        '${user?.displayName.substring(0, 1).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user?.displayName}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.department ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Security',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lock_reset, color: colorScheme.primary),
              ),
              title: Text(
                'Change Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Update your account password',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onTap: () => _showChangePasswordDialog(isDark, colorScheme),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.primary,
                ),
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isDark ? 'Switch to light theme' : 'Switch to dark theme',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              value: isDark,
              activeThumbColor: colorScheme.primary,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
