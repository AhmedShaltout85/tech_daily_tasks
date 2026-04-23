import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_drawer.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/resuable_widgets.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/daily_task_provider.dart';
import 'package:tasks_app/controller/place_name_provider.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/models/daily_task_model.dart';
import 'package:tasks_app/services/connectivity_service.dart';

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
  int _selectedDrawerIndex = 1;

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
    final userProvider = context.read<UserProvider>();
    final department = userProvider.currentUser?.department;

    await context.read<DailyTaskProvider>().fetchAllTasks();

    if (department != null && department.isNotEmpty) {
      await userProvider.fetchUsersByDepartment(department);
    }
    await context.read<AboutAppProvider>().fetchAllAboutApps();
    await context.read<PlaceNameProvider>().fetchPlaceNameStrings();
  }

  Future<void> _createTask(Map<String, dynamic> values) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    int daysUntilDue =
        int.tryParse(values['expected-completion-date'] ?? '7') ?? 7;

    // Filter out the selected assignee from co-operators
    final assignedTo = values['assign-to'] ?? '';
    List<dynamic> coOperators = values['co-operator'] ?? [];
    if (coOperators is List) {
      coOperators = coOperators.where((op) => op != assignedTo).toList();
    }

    final newTask = DailyTaskModel(
      taskTitle: values['title'] ?? '',
      taskStatus: true,
      appName: values['app-name'] ?? '',
      visitPlace: values['visit-place'] ?? '',
      subPlace: values['sub-place'] ?? '',
      assignedTo: assignedTo,
      assignedBy: currentUser?.username ?? '',
      coOperator: coOperators,
      expectedCompletionDate: DateTime.now().add(Duration(days: daysUntilDue)),
      taskPriority: values['task-priority'] ?? 'MEDIUM',
      taskNote: values['task-note'] ?? 'none',
      isRemote: false,
      createdAt: DateTime.now(),
    );

    await context.read<DailyTaskProvider>().createTask(newTask);

    if (mounted) {
      final provider = context.read<DailyTaskProvider>();
      if (provider.error != null) {
        ReusableToast.showToast(
          message: provider.error!,
          bgColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
        provider.clearError();
      } else {
        ReusableToast.showToast(
          message: 'Task added successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
        _fetchData();
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;

    final userProvider = context.watch<UserProvider>();
    final aboutAppProvider = context.watch<AboutAppProvider>();
    final placeNameProvider = context.watch<PlaceNameProvider>();

    //Filter out the admin
    List<String> employeeNames = userProvider.users
        .map((u) => u.username)
        .where((username) => username != 'admin')
        .toList();

    // Get unique app names from AboutAppProvider
    List<String> appNames =
        aboutAppProvider.aboutApps.map((a) => a.appName).toSet().toList();

    List<String> placeNames = placeNameProvider.placeNameStrings;

    List<String> uniqueEmployeeNames = ['none', ...employeeNames];

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
              final currentUsername = userProvider.currentUser?.username ?? '';

              showCustomBottomSheet(
                context: context,
                appNames: appNames,
                employeeNames: uniqueEmployeeNames,
                employeeNamesWithoutNone: uniqueEmployeeNames
                    .where((name) => name != 'none' && name != currentUsername)
                    .toList(),
                placeNames: placeNames,
                selectedAssignee: currentUsername,
                onSubmitTask: (values) async {
                  await _createTask(values);
                },
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
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                                  ...employeeNames.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(
                                        name,
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
                                  ...appNames.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(
                                        name,
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
            child: Consumer<DailyTaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[300] : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.fetchAllTasks();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.tasks.isEmpty) {
                  return Center(
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
                  );
                }

                final filteredTasks = getFilteredTasks(provider.tasks);

                if (filteredTasks.isEmpty && hasActiveFilters) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks match your filters',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: resetFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchAllTasks(),
                  color: colorScheme.primary,
                  child: Column(
                    children: [
                      if (hasActiveFilters)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Showing ${filteredTasks.length} of ${provider.tasks.length} tasks',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return _buildTaskCard(
                                task, index, isDark, colorScheme, provider);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedDrawerIndex,
        onIndexChanged: (index) {
          setState(() => _selectedDrawerIndex = index);
        },
      ),
    );
  }

  Widget _buildTaskCard(
    dynamic task,
    int index,
    bool isDark,
    ColorScheme colorScheme,
    DailyTaskProvider provider,
  ) {
    final isOverdue = task.expectedCompletionDate.isBefore(DateTime.now()) &&
        task.taskStatus == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: _getBorderColor(task), width: 2.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCardColor(task),
                _getCardColor(task).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.taskTitle ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (isOverdue)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildPriorityBadge(task.taskPriority ?? 'MEDIUM'),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                  Icons.business,
                  'Application',
                  task.appName ?? '',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person_outline,
                  'Assigned By',
                  task.assignedBy ?? '',
                  Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person,
                  'Assigned To',
                  task.assignedTo ?? '',
                  Colors.teal,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  'Visit Place',
                  task.visitPlace ?? '',
                  Colors.red,
                ),
                if (task.subPlace != null && task.subPlace.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Sub Place',
                    task.subPlace ?? '',
                    Colors.orange,
                  ),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.group,
                  'Co-Operator',
                  task.coOperator != null && task.coOperator.isNotEmpty
                      ? task.coOperator.join(', ')
                      : 'None',
                  Colors.brown,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: task.taskStatus == true
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: task.taskStatus == true
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              task.taskStatus == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 18,
                              color: task.taskStatus == true
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.taskStatus == true ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: task.taskStatus == true
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: task.taskStatus == true
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _toggleTaskStatus(task, provider),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            task.taskStatus == true
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showDeleteConfirmation(task, provider),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
                          ),
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
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (priority.toUpperCase()) {
      case 'HIGH':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.priority_high;
        break;
      case 'MEDIUM':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.remove;
        break;
      case 'LOW':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        icon = Icons.low_priority;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCardColor(dynamic task) {
    final colorMap = {
      'HIGH': Colors.red.shade50,
      'MEDIUM': Colors.orange.shade50,
      'LOW': Colors.blue.shade50,
    };

    return colorMap[task.taskPriority?.toUpperCase()] ?? Colors.grey.shade50;
  }

  Color _getBorderColor(dynamic task) {
    final colorMap = {
      'HIGH': Colors.red.shade300,
      'MEDIUM': Colors.orange.shade300,
      'LOW': Colors.blue.shade300,
    };

    return colorMap[task.taskPriority?.toUpperCase()] ?? Colors.grey.shade300;
  }

  Future<void> _toggleTaskStatus(
    dynamic task,
    DailyTaskProvider provider,
  ) async {
    try {
      final updatedTask = task.copyWith(taskStatus: !task.taskStatus);
      await provider.updateTask(task.id, updatedTask);
      await provider.fetchAllTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  task.taskStatus ? Icons.check_circle : Icons.info,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.taskStatus
                        ? 'Task marked as inactive'
                        : 'Task marked as active',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error updating task: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(dynamic task, DailyTaskProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('Delete Task'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this task?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${task.taskTitle}"',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final dialogContext = context;
              Navigator.pop(dialogContext);

              // Show loading indicator
              if (mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Deleting task...'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }

              try {
                final taskId = task.id is int
                    ? task.id
                    : int.tryParse(task.id.toString()) ?? 0;
                await provider.deleteTask(taskId);

                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).hideCurrentSnackBar();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Task deleted successfully',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).hideCurrentSnackBar();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                              child:
                                  Text('Error deleting task: ${e.toString()}')),
                        ],
                      ),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
