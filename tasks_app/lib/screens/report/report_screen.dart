import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/daily_task_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/controller/place_name_provider.dart';
import 'package:tasks_app/models/daily_task_model.dart';
import 'package:tasks_app/services/connectivity_service.dart';
import 'package:tasks_app/screens/report/widgets/generate_pdf.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedAssignee;
  String? selectedApplication;
  String? selectedVisitPlace;
  String? selectedStatus;
  String? selectedIsRemote;
  bool _isFilterExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> statusList = ['All', 'Pending', 'Completed'];
  final List<String> isRemoteList = ['All', 'Remote', 'Onsite'];
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    selectedAssignee = 'All';
    selectedApplication = 'All';
    selectedVisitPlace = 'All';
    selectedStatus = 'All';
    selectedIsRemote = 'All';

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      // Fire and forget - don't await to prevent hanging
      context.read<DailyTaskProvider>().fetchAllTasks();
      context.read<PlaceNameProvider>().fetchPlaceNameStrings();

      final userProvider = context.read<UserProvider>();
      final department = userProvider.currentUser?.department;

      if (department != null && department.isNotEmpty) {
        userProvider.fetchUsersByDepartment(department);
        context.read<AboutAppProvider>().fetchAppsByDepartment(department);
      } else {
        context.read<AboutAppProvider>().fetchAllAboutApps();
      }
    } catch (e) {
      debugPrint('Error in _fetchData: $e');
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  List<DailyTaskModel> getFilteredData(List<DailyTaskModel> tasks) {
    return tasks.where((task) {
      bool matchesDate = true;
      bool matchesAssignee = true;
      bool matchesApplication = true;
      bool matchesVisitPlace = true;
      bool matchesStatus = true;
      bool matchesIsRemote = true;

      if (startDate != null || endDate != null) {
        DateTime? taskDate = task.createdAt;
        if (startDate != null && taskDate.isBefore(startDate!)) {
          matchesDate = false;
        }
        if (endDate != null &&
            taskDate.isAfter(endDate!.add(const Duration(days: 1)))) {
          matchesDate = false;
        }
      }

      if (selectedAssignee != null && selectedAssignee != 'All') {
        matchesAssignee = task.assignedTo == selectedAssignee;
      }

      if (selectedApplication != null && selectedApplication != 'All') {
        matchesApplication = task.appName == selectedApplication;
      }

      if (selectedVisitPlace != null && selectedVisitPlace != 'All') {
        matchesVisitPlace = task.visitPlace == selectedVisitPlace;
      }

      if (selectedStatus != null && selectedStatus != 'All') {
        String taskStatusString = task.taskStatus ? 'Pending' : 'Completed';
        matchesStatus = taskStatusString == selectedStatus;
      }

      if (selectedIsRemote != null && selectedIsRemote != 'All') {
        bool taskIsRemote = task.isRemote ?? false;
        String isRemoteString = taskIsRemote ? 'Remote' : 'Onsite';
        matchesIsRemote = isRemoteString == selectedIsRemote;
      }

      return matchesDate &&
          matchesAssignee &&
          matchesApplication &&
          matchesVisitPlace &&
          matchesStatus &&
          matchesIsRemote;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedAssignee = 'All';
      selectedApplication = 'All';
      selectedVisitPlace = 'All';
      selectedStatus = 'All';
      selectedIsRemote = 'All';
    });
    ReusableToast.showToast(
      message: 'Filters cleared',
      bgColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          Consumer<DailyTaskProvider>(
            builder: (context, taskProvider, child) {
              final filteredData = getFilteredData(taskProvider.tasks);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: filteredData.isEmpty
                      ? Colors.grey.shade200
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download_rounded, size: 22),
                  color: filteredData.isEmpty ? Colors.grey : Colors.white,
                  onPressed: filteredData.isEmpty
                      ? null
                      : () {
                          generatePDF(
                            filteredData: filteredData,
                            startDate: startDate,
                            endDate: endDate,
                            selectedStatus: selectedStatus,
                            selectedAssignee: selectedAssignee,
                            selectedApplication: selectedApplication,
                            selectedVisitPlace: selectedVisitPlace,
                            selectedIsRemote: selectedIsRemote,
                          );
                          ReusableToast.showToast(
                            message: 'PDF generated successfully!',
                            bgColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16,
                          );
                        },
                  tooltip: 'Download PDF Report',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DailyTaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;
          final userProvider = context.read<UserProvider>();
          final aboutAppProvider = context.read<AboutAppProvider>();

          // Get app names from AboutAppProvider (filtered by department)
          final appNames =
              aboutAppProvider.aboutApps.map((a) => a.appName).toSet().toList();

          // Get place names from PlaceNameProvider
          final placeProvider = context.read<PlaceNameProvider>();
          final visitPlaceNames = placeProvider.placeNameStrings;

          // Get employee names from UserProvider
          final employeeNames = userProvider.users
              .map((u) => u.username)
              .toSet()
              .toList()
            ..removeWhere((element) => element.contains('admin'));

          final filteredData = getFilteredData(tasks);
          final assigneeList = ['All', ...employeeNames];
          final applicationList = ['All', ...appNames];
          final visitPlaceList = ['All', ...visitPlaceNames];
          final isLoading = taskProvider.isLoading ||
              userProvider.isLoading ||
              aboutAppProvider.isLoading ||
              placeProvider.isLoading;

          if (isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading reports...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.filter_alt_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Search Filters',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: _isFilterExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: Container(),
                          secondChild: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(
                                        label: 'Start Date',
                                        date: startDate,
                                        onTap: () => _selectDate(context, true),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDateField(
                                        label: 'End Date',
                                        date: endDate,
                                        onTap: () =>
                                            _selectDate(context, false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        label: 'Assigned To',
                                        value: assigneeList.contains(
                                          selectedAssignee,
                                        )
                                            ? selectedAssignee!
                                            : 'All',
                                        items: assigneeList,
                                        icon: Icons.person_outline_rounded,
                                        onChanged: (value) {
                                          setState(
                                            () => selectedAssignee = value,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        label: 'Application',
                                        value: applicationList.contains(
                                          selectedApplication,
                                        )
                                            ? selectedApplication!
                                            : 'All',
                                        items: applicationList,
                                        icon: Icons.apps_rounded,
                                        onChanged: (value) {
                                          setState(
                                            () => selectedApplication = value,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        label: 'Visit Place',
                                        value: visitPlaceList.contains(
                                          selectedVisitPlace,
                                        )
                                            ? selectedVisitPlace!
                                            : 'All',
                                        items: visitPlaceList,
                                        icon: Icons.location_on_rounded,
                                        onChanged: (value) {
                                          setState(
                                            () => selectedVisitPlace = value,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatusDropdown(
                                        value:
                                            statusList.contains(selectedStatus)
                                                ? selectedStatus!
                                                : 'All',
                                        items: statusList,
                                        onChanged: (value) {
                                          setState(
                                            () => selectedStatus = value,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildIsRemoteDropdown(
                                        value: isRemoteList
                                                .contains(selectedIsRemote)
                                            ? selectedIsRemote!
                                            : 'All',
                                        items: isRemoteList,
                                        onChanged: (value) {
                                          setState(
                                            () => selectedIsRemote = value,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _clearFilters,
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 20,
                                        ),
                                        label: const Text('Clear Filters'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade100,
                                          foregroundColor: Colors.grey.shade700,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
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
                          crossFadeState: _isFilterExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filteredData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Tasks',
                            filteredData.length.toString(),
                            Theme.of(context).colorScheme.primary,
                            Icons.list_alt_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            filteredData
                                .where((t) => !t.taskStatus)
                                .length
                                .toString(),
                            Colors.green,
                            Icons.check_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            filteredData
                                .where((t) => t.taskStatus)
                                .length
                                .toString(),
                            Colors.orange,
                            Icons.pending_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredData.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final task = filteredData[index];
                            return _buildTaskCard(task, index);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'Select Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          items: items.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Row(
                children: [
                  if (status != 'All')
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(status),
                      ),
                    )
                  else
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  if (status == 'All') const SizedBox(width: 12),
                  Text(status),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildIsRemoteDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          items: items.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Row(
                children: [
                  Icon(
                    type == 'Remote'
                        ? Icons.home_work_rounded
                        : type == 'Onsite'
                            ? Icons.location_on_rounded
                            : Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Text(type),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(DailyTaskModel task, int index) {
    final status = task.taskStatus ? 'Pending' : 'Completed';
    final date = DateFormat('MMM dd, yyyy').format(task.createdAt);
    final isRemote = task.isRemote ?? false ? 'Remote' : 'Onsite';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.taskTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(status),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.apps_rounded,
                    task.appName,
                    const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person,
                    task.assignedBy,
                    const Color.fromARGB(255, 25, 109, 225),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person_outline_rounded,
                    task.assignedTo,
                    const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    date,
                    const Color(0xFF60048B),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.home_work_rounded,
                    isRemote,
                    const Color(0xFF69948B),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.group,
                    task.coOperator.length > 0
                        ? '${task.coOperator.toString().replaceAll('[', ' ').replaceAll(']', ' ')} Co-Operators'
                        : 'No Co-Operators',
                    const Color(0xFF69948B),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters to find what you\'re looking for',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green;
      case 'in progress':
      case 'ongoing':
        return Colors.orange;
      case 'pending':
        return const Color(0xFF2196F3);
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
