import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/screens/login/login_screen.dart';
import 'package:tasks_app/screens/task/task_screen.dart';
import 'package:tasks_app/screens/task/user_task_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  bool _isAdminUser(String? role) {
    return role == 'ADMIN' || role == 'MANAGER';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = userProvider.token;
        final currentUser = userProvider.currentUser;

        if (token == null || token.isEmpty) {
          return const LoginScreen();
        }

        final role = currentUser?.role;

        if (_isAdminUser(role)) {
          return const TaskScreen();
        } else {
          return const UserTaskScreen();
        }
      },
    );
  }
}
