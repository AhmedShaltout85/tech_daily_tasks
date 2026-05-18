import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_user_drawer.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_user_bottom_sheet.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/daily_task_provider.dart';
import 'package:tasks_app/controller/place_name_provider.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/models/daily_task_model.dart';
import 'package:tasks_app/services/connectivity_service.dart';

class UserTaskScreen extends StatefulWidget {
  const UserTaskScreen({super.key});

  @override
  State<UserTaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<UserTaskScreen> {
  String? selectedApp;
  String? selectedIsRemote;
  String? selectedPriority;
  bool showFilters = false;
  final ConnectivityService _connectivity = ConnectivityService();
  int _selectedDrawerIndex = 0;
  bool _hasFetchedData = false;
  bool _initStateScheduled = false;

  @override
  void initState() {
    super.initState();
    if (!_initStateScheduled) {
      _initStateScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasFetchedData) return;
        _hasFetchedData = true;
        _fetchData();
      });
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    // Already checked in initState callback
    await _fetchDataImpl();
  }

  Future<void> _fetchDataImpl() async {
    if (!mounted) return;

    try {
      log('UserTaskScreen: _fetchData started');
      final hasConnection = await _connectivity.hasConnection();
      if (!hasConnection) {
        log('UserTaskScreen: No connection');
        _showNoInternetDialog();
        return;
      }
      final userProvider = context.read<UserProvider>();
      final username = userProvider.currentUser?.username;
      final department = userProvider.currentUser?.department;
      log('UserTaskScreen: Username: $username, Department: $department');
      // await userProvider.fetchAllUsers();
      await context
          .read<UserProvider>()
          .fetchUsersByDepartment(department ?? '');
      // Step 1: Fetch tasks assigned to current user
      if (username != null) {
        log('Step1: Fetching tasks assigned to $username...');
        await context.read<DailyTaskProvider>().fetchTasksAssignedTo(username);
        if (!mounted) return;
        log('Step1: Tasks done');
      }

      // Step 2: Fetch apps
      if (department != null && department.isNotEmpty) {
        log('Step2: Fetching apps for $department...');
        final aboutProvider = context.read<AboutAppProvider>();
        await aboutProvider.fetchAppsByDepartment(department);
        if (!mounted) return;
        log('Step2: Apps done');
      }

      // Step 3: Fetch places
      log('Step3: Fetching places...');
      await context.read<PlaceNameProvider>().fetchPlaceNameStrings();
      if (!mounted) return;
      log('Step3: Places done');

      log('UserTaskScreen: ALL COMPLETE!');
    } catch (e, stack) {
      log('ERROR in _fetchData: $e');
      log('Stack: $stack');
    }
  }

  // Create a new task
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

    // // Filter out the selected assignee from co-operators
    // final assignedTo = values['assign-to'] ?? '';
    // List<dynamic> coOperators = values['co_operator_users'] ?? [];
    // // ignore: unnecessary_type_check
    // if (coOperators is List) {
    //   coOperators = coOperators.where((op) => op != assignedTo).toList();
    // }

    final newTask = DailyTaskModel(
      taskTitle: values['task_title'] ?? '',
      taskStatus: true,
      appName: values['app_name'] ?? '',
      visitPlace: values['place_name'] ?? '',
      subPlace: values['sub-place'] ?? '',
      assignedTo: userProvider.currentUser?.username ?? '',
      assignedBy: currentUser?.username ?? '',
      coOperator: values['co_operator_users'] ?? [],
      expectedCompletionDate: DateTime.now().add(Duration(days: daysUntilDue)),
      taskPriority: values['task-priority'] ?? 'HIGH',
      taskNote: values['task-note'] ?? 'لايوجد ملاحظات',
      isRemote: values['is_remote'] ?? false,
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
          message: 'تم إضافة المهمة بنجاح',
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
        title: const Text('لا يوجد اتصال بالانترنت'),
        content: const Text(
          'يرجى التحقق من الاتصال والمحاولة مرة اخرى',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنا'),
          ),
        ],
      ),
    );
  }

  List<dynamic> getFilteredTasks(List<dynamic> tasks) {
    return tasks.where((task) {
      try {
        // if (selectedEmployee != null && selectedEmployee!.isNotEmpty) {
        //   final taskEmployee = Provider.of<UserProvider>(context).currentUser ?? '';
        //   if (taskEmployee != selectedEmployee) return false;
        // }

        if (selectedApp != null && selectedApp!.isNotEmpty) {
          final taskApp = task.appName?.toString() ?? '';
          if (taskApp != selectedApp) return false;
        }

        if (selectedIsRemote != null && selectedIsRemote != 'الكل') {
          final taskIsRemote = task.isRemote == true;
          final filterValue = selectedIsRemote == 'عن بعد';
          if (taskIsRemote != filterValue) return false;
        }

        if (selectedPriority != null && selectedPriority != 'الكل') {
          final taskPriority = task.taskPriority?.toString() ?? '';
          final priorityMap = {
            'عالية': 'HIGH',
            'متوسطة': 'MEDIUM',
            'منخفضة': 'LOW',
          };
          final mappedPriority =
              priorityMap[selectedPriority] ?? selectedPriority;
          if (taskPriority != mappedPriority) return false;
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
      selectedApp = null;
      selectedIsRemote = null;
      selectedPriority = null;
    });
  }

  bool get hasActiveFilters =>
      selectedApp != null ||
      selectedIsRemote != null ||
      selectedPriority != null;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;

    final userProvider = context.watch<UserProvider>();
    final aboutAppProvider = context.watch<AboutAppProvider>();

    // Get unique app names from AboutAppProvider
    List<String> appNames =
        aboutAppProvider.aboutApps.map((a) => a.appName).toSet().toList();

    List<String> placeNames =
        context.watch<PlaceNameProvider>().placeNameStrings;
    List<String> employeeNames = userProvider.users
        .map((u) => u.role == 'USER' ? u.username : 'NULL')
        // .where((username) =>
        //     username != 'admin' ||
        //     username != userProvider.currentUser?.username)
        .toSet()
        .toList();
        employeeNames.remove(userProvider.currentUser?.username);
        employeeNames.remove('NULL');
      log('employeeNames: $employeeNames');
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${userProvider.currentUser?.username}' + ' - ' + 'المهام اليومية'),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'تخصيص',
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
          // In your UserTaskScreen, update the onPressed callback:
          IconButton(
            tooltip: 'إضافة مهمة',
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: const Icon(Icons.add),
            onPressed: () {
              // Don't pass hardcoded initial values that might not exist in the lists
              showUserAddTaskBottomSheet(
                context: context,
                appNames: appNames,
                placeNames: placeNames,
                coOperatorUsers: employeeNames,
                // Only pass initial values if they exist in the lists
                initialTaskTitle: null, // Let the user enter
                initialAppName: appNames.isNotEmpty ? appNames.first : null,
                initialPlaceName:
                    placeNames.isNotEmpty ? placeNames.first : null,
                initialSubPlace: 'لايوجد',
                initialIsRemote: false,
                initialCoOperatorUsers: employeeNames,
                onSubmitTask: (values) async {
                  // Handle the submitted values

                  log('Task Title: ${values['task_title']}');
                  log('App Name: ${values['app_name']}');
                  log('Place Name: ${values['place_name']}');
                  log('Sub Place: ${values['sub_place']}');
                  log('Is Remote: ${values['is_remote']}');
                  log('Co-operator Users: ${values['co_operator_users']}');
                  // Add your logic here
                  await _createTask(values);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade700,
                      content: Center(
                          child: Text(
                        'Task added: ${values['task_title']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )),
                    ),
                  );
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
                              'تخصيصات',
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
                                  'حذف التصفية',
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                value: selectedIsRemote,
                                isExpanded: true,
                                dropdownColor:
                                    isDark ? colorScheme.surface : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'نوع الصيانة',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
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
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      'الكل',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'عن بعد',
                                    child: Text(
                                      'عن بعد',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'في الموقع',
                                    child: Text(
                                      'في الموقع',
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
                                    selectedIsRemote = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                value: selectedPriority,
                                isExpanded: true,
                                dropdownColor:
                                    isDark ? colorScheme.surface : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'الاولوية',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.priority_high,
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
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      'الكل',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'عالية',
                                    child: Text(
                                      'عالية',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'متوسطة',
                                    child: Text(
                                      'متوسطة',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'منخفضة',
                                    child: Text(
                                      'منخفضة',
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
                                    selectedPriority = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
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
                                  labelText: 'التطبيق/الجهاز',
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
                                      'كل التطبيقات',
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
                            provider.fetchTasksAssignedTo(
                                userProvider.currentUser!.username);
                          },
                          child: const Text('اعادة المحاولة'),
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
                          'لا توجد مهام',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredTasks = getFilteredTasks(provider.tasks)
                    .where(
                      (task) => task.taskStatus == true,
                    )
                    .toList();

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
                          'لا توجد نتائج للبحث الحالي',
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
                  onRefresh: () => provider
                      .fetchTasksAssignedTo(userProvider.currentUser!.username),
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
                                  'إظهار ${filteredTasks.length} of ${provider.tasks.length} مهام',
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
      drawer: CustomUserDrawer(
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
                                    'متأخرة',
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
                  '',
                  task.appName ?? '',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person_outline,
                  '',
                  task.assignedBy ?? '',
                  Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person,
                  '',
                  task.assignedTo ?? '',
                  Colors.teal,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  '',
                  task.visitPlace ?? '',
                  Colors.red,
                ),
                if (task.subPlace != null && task.subPlace.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    '',
                    task.subPlace ?? '',
                    Colors.orange,
                  ),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.group,
                  '',
                  task.coOperator != null && task.coOperator.isNotEmpty
                      ? task.coOperator.join(', ')
                      : 'لا يوجد شركاء',
                  Colors.brown,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: task.taskStatus == true
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(7),
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
                              task.taskStatus == true ? 'نشط' : 'غير نشط',
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
                    const SizedBox(width: 10),
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
                    const SizedBox(width: 18),
                    Material(
                      color: task.isRemote == true
                          ? Colors.blue.shade600
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          log('Tapping isRemote button for task ${task.id}');
                          final provider = context.read<DailyTaskProvider>();
                          final taskId = task.id is int
                              ? task.id
                              : int.tryParse(task.id.toString()) ?? 0;
                          final newIsRemote = !(task.isRemote ?? false);
                          log('Current isRemote: ${task.isRemote}, New value: $newIsRemote');

                          await provider.updateTask(
                            taskId,
                            task.copyWith(isRemote: newIsRemote),
                          );
                          log('Update complete. Tasks in provider: ${provider.tasks.length}');

                          final username = context
                              .read<UserProvider>()
                              .currentUser
                              ?.username;
                          if (username != null) {
                            await provider.fetchTasksAssignedTo(username);
                          }

                          log('After fetch - checking task $taskId:');
                          for (var t in provider.tasks) {
                            log('  Task ${t.id}: isRemote=${t.isRemote}');
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      newIsRemote
                                          ? Icons.home_work
                                          : Icons.home,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        newIsRemote
                                            ? 'تم تغيير إلى العمل عن بعد'
                                            : 'تم تغيير إلى موقع العمل',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.blue.shade700,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            task.isRemote == true
                                ? Icons.home_work
                                : Icons.home,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: (task.taskNote != null &&
                              task.taskNote.isNotEmpty &&
                              task.taskNote != 'none')
                          ? Colors.orange.shade600
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showTaskNoteDialog(task),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.note_alt_outlined,
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
                  text: '$label',
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
      final userProvider = context.read<UserProvider>();
      final username = userProvider.currentUser?.username;
      final updatedTask = task.copyWith(taskStatus: !task.taskStatus);
      await provider.updateTask(task.id, updatedTask);
      if (username != null) {
        await provider.fetchTasksAssignedTo(username);
      }

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
                    task.taskStatus ? 'المهمة تم تعطيلها' : 'المهمة تم تفعيلها',
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

  Future<void> _toggleRemoteStatus(
    dynamic task,
    DailyTaskProvider provider,
  ) async {
    try {
      final userProvider = context.read<UserProvider>();
      final username = userProvider.currentUser?.username;
      final newIsRemote = !(task.isRemote ?? false);
      log('Toggling isRemote from ${task.isRemote} to $newIsRemote');

      final taskId =
          task.id is int ? task.id : int.tryParse(task.id.toString()) ?? 0;
      final updatedTask = task.copyWith(isRemote: newIsRemote);

      await provider.updateTask(taskId, updatedTask);

      if (username != null) {
        await provider.fetchTasksAssignedTo(username);
      }

      log('After fetch - tasks count: ${provider.tasks.length}');
      if (provider.tasks.isNotEmpty) {
        final updatedTaskFromList = provider.tasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => provider.tasks.first,
        );
        log('Task $taskId isRemote in list: ${updatedTaskFromList.isRemote}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newIsRemote ? Icons.home_work : Icons.home,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    newIsRemote
                        ? 'تم تغيير إلى العمل عن بعد'
                        : 'تم تغيير إلى موقع العمل',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
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

  void _showTaskNoteDialog(dynamic task) {
    final noteController = TextEditingController(text: task.taskNote ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.note_alt_outlined),
            SizedBox(width: 12),
            Text('ملاحظة المهمة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملاحظة: ${task.taskTitle}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'أضف ملاحظة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNote = noteController.text.trim();
              final provider = context.read<DailyTaskProvider>();
              final taskId = task.id is int
                  ? task.id
                  : int.tryParse(task.id.toString()) ?? 0;

              await provider.updateTask(
                taskId,
                task.copyWith(taskNote: newNote.isEmpty ? 'none' : newNote),
              );

              final username =
                  context.read<UserProvider>().currentUser?.username;
              if (username != null) {
                await provider.fetchTasksAssignedTo(username);
              }

              if (mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الملاحظة'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
