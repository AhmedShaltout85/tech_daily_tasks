import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/models/user_model.dart';
import 'package:tasks_app/services/connectivity_service.dart';

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
  String? selectedDepartment;
  String? selectedRole;
  bool _isFilterExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> roleList = ['All', 'USER', 'MANAGER', 'ADMIN'];
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    selectedAssignee = 'All';
    selectedDepartment = 'All';
    selectedRole = 'All';

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
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }
    await context.read<UserProvider>().fetchAllUsers();
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

  List<UserModel> getFilteredData(List<UserModel> users) {
    return users.where((user) {
      bool matchesAssignee = true;
      bool matchesDepartment = true;
      bool matchesRole = true;

      if (selectedAssignee != null && selectedAssignee != 'All') {
        matchesAssignee = user.username == selectedAssignee;
      }

      if (selectedDepartment != null && selectedDepartment != 'All') {
        matchesDepartment = user.department == selectedDepartment;
      }

      if (selectedRole != null && selectedRole != 'All') {
        matchesRole = user.role == selectedRole;
      }

      return matchesAssignee && matchesDepartment && matchesRole;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedAssignee = 'All';
      selectedDepartment = 'All';
      selectedRole = 'All';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final filteredData = getFilteredData(userProvider.users);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: filteredData.isEmpty
                      ? Colors.grey.shade200
                      : colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download_rounded, size: 22),
                  color: filteredData.isEmpty ? Colors.grey : Colors.white,
                  onPressed: filteredData.isEmpty
                      ? null
                      : () {
                          ReusableToast.showToast(
                            message: 'PDF generation coming soon',
                            bgColor: Colors.grey,
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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final users = userProvider.users;
          final assigneeList = [
            'All',
            ...users.map((u) => u.username).toSet().toList()
          ];
          final departmentList = [
            'All',
            ...users
                .map((u) => u.department ?? '')
                .toSet()
                .where((d) => d.isNotEmpty)
                .toList()
          ];
          final filteredData = getFilteredData(users);
          final isLoading = userProvider.isLoading;

          if (isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
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
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : Colors.white,
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
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.filter_alt_rounded,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search Filters',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
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
                                        label: 'Username',
                                        value: assigneeList
                                                .contains(selectedAssignee)
                                            ? selectedAssignee!
                                            : 'All',
                                        items: assigneeList,
                                        icon: Icons.person_outline_rounded,
                                        onChanged: (value) {
                                          setState(
                                              () => selectedAssignee = value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        label: 'Department',
                                        value: departmentList
                                                .contains(selectedDepartment)
                                            ? selectedDepartment!
                                            : 'All',
                                        items: departmentList,
                                        icon: Icons.business_outlined,
                                        onChanged: (value) {
                                          setState(
                                              () => selectedDepartment = value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRoleDropdown(
                                        value: roleList.contains(selectedRole)
                                            ? selectedRole!
                                            : 'All',
                                        items: roleList,
                                        onChanged: (value) {
                                          setState(() => selectedRole = value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _clearFilters,
                                        icon: const Icon(Icons.clear_rounded,
                                            size: 20),
                                        label: const Text('Clear Filters'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade100,
                                          foregroundColor: Colors.grey.shade700,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                            'Total Users',
                            filteredData.length.toString(),
                            colorScheme.primary,
                            Icons.list_alt_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Active',
                            filteredData
                                .where((u) => u.enabled == true)
                                .length
                                .toString(),
                            Colors.green,
                            Icons.check_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Inactive',
                            filteredData
                                .where((u) => u.enabled == false)
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
                            final user = filteredData[index];
                            return _buildUserCard(user, index);
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
            Icon(Icons.calendar_today_rounded,
                size: 20, color: Colors.grey.shade600),
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
                        fontWeight: FontWeight.w500),
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
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600),
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown({
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
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600),
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500),
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
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: Colors.grey.shade600),
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

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
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
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, int index) {
    final status = user.enabled == true ? 'Active' : 'Inactive';

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
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                  _buildInfoRow(Icons.person_outline, user.username,
                      const Color(0xFF2196F3)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.business_outlined,
                      user.department ?? 'N/A', const Color(0xFF64748B)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.badge_outlined, user.role ?? 'USER',
                      const Color(0xFF69948B)),
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
          child: Text(text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
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
            child: Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Results Found',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B)),
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
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'admin':
        return Colors.blue;
      case 'manager':
        return Colors.purple;
      case 'user':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }
}
