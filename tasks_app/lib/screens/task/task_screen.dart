import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_drawer.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_widgets.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/daily_task_provider.dart';
import 'package:tasks_app/controller/place_name_provider.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/models/daily_task_model.dart';
import 'package:tasks_app/services/connection_dialog_service.dart';
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
  final ConnectivityService _connectivity = ConnectivityService.instance;
  int _selectedDrawerIndex = 1;
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
      log('TaskScreen: _fetchData started');
      final hasConnection = await _connectivity.hasConnection();
      if (!hasConnection) {
        log('TaskScreen: No connection');
        ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _fetchDataImpl,
        );
        return;
      }
      final userProvider = context.read<UserProvider>();
      final department = userProvider.currentUser?.department;
      log('TaskScreen: User department: $department');

      // Step 1: Fetch tasks
      log('Step1: Fetching tasks...');
      await context.read<DailyTaskProvider>().fetchAllTasks();
      if (!mounted) return;
      log('Step1: Tasks done');

      // Step 2: Fetch users
      if (department != null && department.isNotEmpty) {
        log('Step2: Fetching users for $department...');
        await userProvider.fetchUsersByDepartment(department);
        if (!mounted) return;
        log('Step2: Users done');

        // Step 3: Fetch apps
        log('Step3: Fetching apps...');
        final aboutProvider = context.read<AboutAppProvider>();
        await aboutProvider.fetchAppsByDepartment(department);
        if (!mounted) return;
        log('Step3: Apps done');
      }

      // Step 4: Fetch places
      log('Step4: Fetching places...');
      await context.read<PlaceNameProvider>().fetchPlaceNameStrings();
      if (!mounted) return;
      log('Step4: Places done');

      log('TaskScreen: ALL COMPLETE!');
    } catch (e, stack) {
      log('ERROR in _fetchData: $e');
      log('Stack: $stack');
    }
  }

  Future<void> _createTask(Map<String, dynamic> values) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      ConnectionDialogService.showNoInternetDialog(
        context,
        // onRetry: () => _createTask(values),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    int daysUntilDue =
        int.tryParse(values['expected-completion-date'] ?? '7') ?? 7;

    // Filter out the selected assignee from co-operators
    final assignedTo = values['assign-to'] ?? '';
    List<dynamic> coOperators = values['co-operator'] ?? [];
    // ignore: unnecessary_type_check
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
          message: 'تم إضافة المهمة بنجاح',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
        _fetchData();
      }
    }
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
        .map((u) => u.role == 'USER' && u.enabled == true || u.role == 'MANAGER' || u.role == 'ADMIN'
            ? u.username
            : 'admin')
        .where((username) => username != 'admin' || username != 'manager')
        .toSet()
        // .where((username) => username != 'admin' || username != 'manager')
        .toList();

    // Get unique app names from AboutAppProvider
    List<String> appNames =
        aboutAppProvider.aboutApps.map((a) => a.appName).toSet().toList();

    List<String> placeNames = placeNameProvider.placeNameStrings;

    if (employeeNames.contains('admin') || employeeNames.contains('manager')) {
      employeeNames.remove('admin');
      employeeNames.remove('manager');
    } else {
      employeeNames = ['لاشئ', ...employeeNames];
    }
    List<String> uniqueEmployeeNames = ['لاشئ', ...employeeNames.toSet()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام اليومية', style: TextStyle(
              fontFamily: 'Cairo',
            )),
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
          IconButton(
            tooltip: 'إضافة مهمة',
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: const Icon(Icons.add),
            onPressed: () {
              final currentUsername = userProvider.currentUser?.username ?? '';

              showCustomBottomSheet(
                context: context,
                appNames: appNames,
                employeeNames: uniqueEmployeeNames,
                employeeNamesWithoutNone: uniqueEmployeeNames
                    .where((name) => name != 'لاشئ' && name != currentUsername)
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
                              'تخصيص',
                              style: TextStyle(
                                fontFamily: 'Cairo',
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
                                  'حدف المخصصات',
                                  style: TextStyle(color: colorScheme.primary, fontFamily: 'Cairo',
                                  ),
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
                                  labelText: 'مخصص للموظف',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Cairo',
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
                                      'كل الموظفين',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
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
                                          fontFamily: 'Cairo',
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
                                  labelText: 'التطبيق/الجهاز',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Cairo',
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
                                        fontFamily: 'Cairo',
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
                                          fontFamily: 'Cairo',
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
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            color: isDark ? Colors.grey[300] : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.fetchAllTasks();
                          },
                          child: const Text('اعادة المحاولة', style: TextStyle(fontFamily: 'Cairo',),),
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
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'قم بإضافة مهام جديدة +',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: isDark ? Colors.grey[500] : Colors.grey,
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
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: resetFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('حذف الفلترات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                              )),
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
                                  'إظهار ${filteredTasks.length} of ${provider.tasks.length} مهام',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
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
                          reverse: true ,
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
                              fontFamily: 'Cairo',
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
                                    'متاخرة',
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
                  'اسم التطبيق/الاجهزة',
                  task.appName ?? '',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person_outline,
                  'مخصص المهمة',
                  task.assignedBy ?? '',
                  Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person,
                  'مخصص ل',
                  task.assignedTo ?? '',
                  Colors.teal,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  'المكان الرئيسى',
                  task.visitPlace ?? '',
                  Colors.red,
                ),
                if (task.subPlace != null && task.subPlace.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'المكان الفرعى',
                    task.subPlace ?? '',
                    Colors.orange,
                  ),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.date_range,
                  'تاريخ المهمة',
                  task.expectedCompletionDate != null
                      ? DateFormat('yyyy-MM-dd').format(task.expectedCompletionDate)
                      : '',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.group,
                  'زملاء متعاونين',
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
                                fontFamily: 'Cairo',
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
                    const SizedBox(width: 120),
                    Expanded(
                      child: Material(
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
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Material(
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
            style: TextStyle(fontFamily: 'Cairo',
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
                  text: '',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
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
      final hasConnection = await _connectivity.hasConnection();
      if (!hasConnection) {
        // Create a wrapper function

        await ConnectionDialogService.showNoInternetDialog(
          context,
        );
        return;
      }
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
                    task.taskStatus ? 'تم الانتهااء من المهمة' : 'تم تفعيل المهمه',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Cairo',
                    ),
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
            content: Center(
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error updating task: ${e.toString()}', style: const TextStyle(fontFamily: 'Cairo',),)),
                ],
              ),
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
            const Text('حذف المهمة', style: TextStyle(fontFamily: 'Cairo',),),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هل أنت متأكد من حذف هذه المهمة؟',
              style: TextStyle(fontSize: 16, fontFamily: 'Cairo',),
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
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'هذه العملية لا يمكن التراجع عنها',
              style: TextStyle(
                fontFamily: 'Cairo',
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
            child: const Text('الغاء', style: TextStyle(fontSize: 16, fontFamily: 'Cairo',),),
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
                    content: Center(
                      child: Row(
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
                          Text('جاري الحذف...'),
                        ],
                      ),
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }

              try {
                // Delete task
                final hasConnection = await _connectivity.hasConnection();
                if (!hasConnection) {
                  // Create a wrapper function

                  await ConnectionDialogService.showNoInternetDialog(
                    context,
                    // onRetry: retryAction,
                  );
                  return;
                }
                final taskId = task.id is int
                    ? task.id
                    : int.tryParse(task.id.toString()) ?? 0;
                await provider.deleteTask(taskId);

                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).hideCurrentSnackBar();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'تم حذف المهمة بنجاح',
                                style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Cairo',),
                              ),
                            ),
                          ],
                        ),
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
                      content: Center(
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                                child:
                                    Text('Error deleting task: ${e.toString()}', style: const TextStyle(fontFamily: 'Cairo',),)),
                          ],
                        ),
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
              'حذف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
