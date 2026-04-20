import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_drawer.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/services/connectivity_service.dart';
import 'package:tasks_app/utils/app_colors.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String? selectedEmployee;
  String? selectedApp;
  bool? isActiveFilter;
  bool showFilters = false;
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }
    await context.read<UserProvider>().fetchAllUsers();
    await context.read<UserProvider>().fetchUsersByRole('USER');
  }

  List<dynamic> getFilteredTasks(List<dynamic> tasks) {
    return tasks.where((task) {
      try {
        if (selectedEmployee != null && selectedEmployee!.isNotEmpty) {
          final taskEmployee = task.assignedTo?.toString() ?? '';
          if (taskEmployee != selectedEmployee) return false;
        }

        if (selectedApp != null && selectedApp!.isNotEmpty) {
          final taskApp = task.appName?.toString() ?? '';
          if (taskApp != selectedApp) return false;
        }

        if (isActiveFilter != null) {
          final taskActive = task.taskStatus ?? true;
          if (taskActive != isActiveFilter) return false;
        }

        return true;
      } catch (e) {
        log('Error filtering task: $e');
        return true;
      }
    }).toList();
  }

  void resetFilters() {
    setState(() {
      selectedEmployee = null;
      selectedApp = null;
      isActiveFilter = null;
    });
  }

  bool get hasActiveFilters =>
      selectedEmployee != null || selectedApp != null || isActiveFilter != null;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Filters',
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                },
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 8, height: 8),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Add Task',
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: const Icon(Icons.add),
            onPressed: () {
              ReusableToast.showToast(
                message: 'Add Task coming soon',
                bgColor: AppColors.grayColor,
                textColor: AppColors.whiteColor,
                fontSize: 16,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showFilters ? null : 0,
            child: showFilters
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : Colors.grey[100],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (hasActiveFilters)
                              TextButton.icon(
                                onPressed: resetFilters,
                                icon: Icon(
                                  Icons.clear_all,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                label: Text(
                                  'Clear All',
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedEmployee,
                                isExpanded: true,
                                dropdownColor:
                                    isDark ? colorScheme.surface : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Assigned To',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? colorScheme.surface
                                          .withValues(alpha: 0.5)
                                      : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'All Employees',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  ...users.map((user) {
                                    return DropdownMenuItem<String>(
                                      value: user.username,
                                      child: Text(
                                        user.displayName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[300]
                                              : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedEmployee = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedApp,
                                isExpanded: true,
                                dropdownColor:
                                    isDark ? colorScheme.surface : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Application',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.apps,
                                    color: colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? colorScheme.surface
                                          .withValues(alpha: 0.5)
                                      : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'All Apps',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedApp = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<bool?>(
                                value: isActiveFilter,
                                isExpanded: true,
                                dropdownColor:
                                    isDark ? colorScheme.surface : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Status',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.toggle_on,
                                    color: colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? colorScheme.surface
                                          .withValues(alpha: 0.5)
                                      : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<bool?>(
                                    value: null,
                                    child: Text(
                                      'All Status',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<bool?>(
                                    value: true,
                                    child: Text(
                                      'Active Only',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<bool?>(
                                    value: false,
                                    child: Text(
                                      'Inactive Only',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    isActiveFilter = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: userProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_outlined,
                              size: 64,
                              color: isDark ? Colors.grey[600] : Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add a new task',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[500] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        color: colorScheme.primary,
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user.displayName[0]),
                              ),
                              title: Text(user.displayName),
                              subtitle: Text(user.role ?? 'USER'),
                              trailing: Icon(
                                user.enabled == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: user.enabled == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
    );
  }
}
