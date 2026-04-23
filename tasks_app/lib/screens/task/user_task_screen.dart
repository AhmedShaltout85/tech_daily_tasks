// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_user_drawer.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/services/connectivity_service.dart';

class UserTaskScreen extends StatefulWidget {
  const UserTaskScreen({super.key});

  @override
  State<UserTaskScreen> createState() => _UserTaskScreenState();
}

class _UserTaskScreenState extends State<UserTaskScreen> {
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasks();
    });
  }

  Future<void> _fetchTasks() async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }
    await context.read<UserProvider>().fetchEnabledUsersByRole('USER', true);
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;

    final userProvider = context.watch<UserProvider>();
    final users = userProvider.users;
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks Assigned to ${currentUser?.displayName ?? 'User'}',
        ),
        actions: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${users.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTasks,
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user.displayName[0]),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.department ?? ''),
                        trailing: user.enabled == true
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.cancel, color: Colors.red),
                      );
                    },
                  ),
                ),
      drawer: const CustomUserDrawer(),
    );
  }
}
