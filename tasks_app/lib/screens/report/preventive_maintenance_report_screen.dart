
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tasks_app/controller/preventive_provider.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/controller/place_name_provider.dart';
import 'package:tasks_app/models/preventive_maintenance_model.dart';
import 'package:tasks_app/services/connection_dialog_service.dart';
import 'package:tasks_app/services/connectivity_service.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/screens/report/widgets/preventive_maintenance_export_pdf.dart';
import 'package:tasks_app/utils/app_colors.dart';

class PreventiveMaintenanceReportScreen extends StatefulWidget {
  const PreventiveMaintenanceReportScreen({super.key});

  @override
  State<PreventiveMaintenanceReportScreen> createState() =>
      _PreventiveMaintenanceReportScreenState();
}

class _PreventiveMaintenanceReportScreenState
    extends State<PreventiveMaintenanceReportScreen>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivity = ConnectivityService();
  String? selectedUsername;
  String? selectedAppName;
  String? selectedPlaceName;
  String? selectedDepartment;
  bool? selectedIsRemote;
  DateTime? startDate;
  DateTime? endDate;
  bool _isFilterExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Cache for filtered data to improve performance
  List<PreventiveMaintenanceModel>? _cachedFilteredData;
  List<PreventiveMaintenanceModel>? _cachedItems;

  // Debounce timer for filters
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    selectedUsername = 'الكل';
    selectedAppName = 'الكل';
    selectedPlaceName = 'الكل';
    selectedDepartment = 'الكل';
    selectedIsRemote = null;
    startDate = null;
    endDate = null;

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
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Clear cache when filters change
  void _clearCache() {
    _cachedFilteredData = null;
    _cachedItems = null;
  }

  // Debounced filter update to prevent excessive rebuilds
  void _debouncedFilterUpdate(VoidCallback update) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _clearCache();
      setState(update);
    });
  }

  Future<void> _fetchData() async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      ConnectionDialogService.showNoInternetDialog(
        context,
        onRetry: _fetchData,
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final department = userProvider.currentUser?.department;
    debugPrint('User department: $department');

    if (department != null && department.isNotEmpty) {
      await context.read<AboutAppProvider>().fetchAppsByDepartment(department);
    } else {
      await context.read<AboutAppProvider>().fetchAllAboutApps();
    }
    await context.read<PlaceNameProvider>().fetchPlaceNameStrings();

    String dept = department ?? 'IT';
    debugPrint('Fetching with department: $dept');
    await context
        .read<PreventiveProvider>()
        .fetchAllPreventiveMaintenanceByDepartment(dept);

    // Check results
    final provider = context.read<PreventiveProvider>();
    debugPrint('After fetch - items: ${provider.preventiveMaintenance.length}');

    // If no results, try again with IT
    if (provider.preventiveMaintenance.isEmpty) {
      debugPrint('No results, trying IT department...');
      await context
          .read<PreventiveProvider>()
          .fetchAllPreventiveMaintenanceByDepartment('IT');
      debugPrint(
          'After IT fallback - items: ${provider.preventiveMaintenance.length}');
    }

    // Clear cache after new data fetch
    _clearCache();
  }

  List<PreventiveMaintenanceModel> getFilteredData(
      List<PreventiveMaintenanceModel> items) {
    // Return cached data if items haven't changed and cache exists
    if (_cachedFilteredData != null && _cachedItems == items) {
      return _cachedFilteredData!;
    }

    // Store current items for cache validation
    _cachedItems = items;

    if (items.isEmpty) {
      _cachedFilteredData = [];
      return [];
    }

    final filtered = items.where((item) {
      bool matchesUser = true;
      bool matchesApp = true;
      bool matchesPlace = true;
      bool matchesRemote = true;
      bool matchesDate = true;
      bool matchesDepartment = true;

      // Username filtering
      if (selectedUsername != null && selectedUsername != 'الكل') {
        matchesUser = item.username == selectedUsername;
      }

      // Department filtering
      if (selectedDepartment != null && selectedDepartment != 'الكل') {
        matchesDepartment = item.department == selectedDepartment;
      }

      // Date filtering using createdAt (which is already DateTime)
      if (startDate != null && item.createdAt != null) {
        matchesDate = item.createdAt!
            .isAfter(startDate!.subtract(const Duration(days: 1)));
      } else if (startDate != null && item.createdAt == null) {
        matchesDate = false;
      }

      if (endDate != null && item.createdAt != null && matchesDate) {
        matchesDate =
            item.createdAt!.isBefore(endDate!.add(const Duration(days: 1)));
      } else if (endDate != null && item.createdAt == null) {
        matchesDate = false;
      }

      // App name filtering
      if (selectedAppName != null &&
          selectedAppName != 'الكل' &&
          selectedAppName != null) {
        matchesApp = item.appName == selectedAppName;
      }

      // Place name filtering
      if (selectedPlaceName != null &&
          selectedPlaceName != 'الكل' &&
          selectedPlaceName != null) {
        matchesPlace = item.placeName == selectedPlaceName;
      }

      // Remote filtering
      if (selectedIsRemote != null) {
        matchesRemote = item.isRemote == (selectedIsRemote! ? 'true' : 'false');
      }

      return matchesUser &&
          matchesApp &&
          matchesPlace &&
          matchesRemote &&
          matchesDate &&
          matchesDepartment;
    }).toList();

    // Cache the filtered result
    _cachedFilteredData = filtered;
    return filtered;
  }

  void _clearFilters() {
    _debouncedFilterUpdate(() {
      selectedUsername = 'الكل';
      selectedAppName = 'الكل';
      selectedPlaceName = 'الكل';
      selectedDepartment = 'الكل';
      selectedIsRemote = null;
      startDate = null;
      endDate = null;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _debouncedFilterUpdate(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    // Remove duplicates to prevent the error
    final uniqueItems = items.toSet().toList();

    // Ensure value exists in items, otherwise use first item or null
    final validValue = uniqueItems.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered label row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: validValue,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down,
                color: Colors.grey.shade600, size: 20),
            hint: Center(
              child: Text(
                'اختر $label',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            items: uniqueItems.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Center(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              _debouncedFilterUpdate(() => onChanged(value));
            },
            selectedItemBuilder: (BuildContext context) {
              return uniqueItems.map((item) {
                return Center(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRemoteDropdown({
    required String label,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered label row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<bool?>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down,
                color: Colors.grey.shade600, size: 20),
            hint: const Center(
              child: Text(
                'اختر نوع العمل',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Center(
                  child: Text('الكل', style: TextStyle(fontSize: 14)),
                ),
              ),
              DropdownMenuItem(
                value: true,
                child: Center(
                  child: Text('عن بُعد', style: TextStyle(fontSize: 14)),
                ),
              ),
              DropdownMenuItem(
                value: false,
                child: Center(
                  child: Text('موقع', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onChanged: (value) {
              _debouncedFilterUpdate(() => onChanged(value));
            },
            selectedItemBuilder: (BuildContext context) {
              return const [
                Center(child: Text('الكل', style: TextStyle(fontSize: 14))),
                Center(child: Text('عن بُعد', style: TextStyle(fontSize: 14))),
                Center(child: Text('موقع', style: TextStyle(fontSize: 14))),
              ];
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered label row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  date != null ? DateFormat('yyyy-MM-dd').format(date) : label,
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.black87 : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PreventiveMaintenanceModel item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.appName ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isRemote == 'true'
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isRemote == 'true' ? 'عن بُعد' : 'موقع',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          item.isRemote == 'true' ? Colors.blue : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.username ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.placeName ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20, color: AppColors.purpleColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.createdAt != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt!)
                        : '',
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (item.action.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.repartition_sharp, size: 20, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.action,
                        style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد نتائج',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'جرب تعديل الفلاتر',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تقرير صيانة وقائية',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Consumer<PreventiveProvider>(
            builder: (context, provider, child) {
              final filteredData =
                  getFilteredData(provider.preventiveMaintenance);
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
                      : () async {
                          ReusableToast.showToast(
                            message: 'جاري إنشاء PDF',
                            bgColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 14,
                          );
                          try {
                            await generatePreventiveMaintenancePDF(
                              filteredData: filteredData,
                              selectedUsername: selectedUsername,
                              selectedAppName: selectedAppName,
                              selectedPlaceName: selectedPlaceName,
                              selectedIsRemote: selectedIsRemote,
                              startDate: startDate,
                              endDate: endDate,
                            );
                            final hasConnection =
                                await _connectivity.hasConnection();
                            if (!hasConnection) {
                              await ConnectionDialogService
                                  .showNoInternetDialog(
                                context,
                              );
                              return;
                            }
                          } catch (e) {
                            ReusableToast.showToast(
                              message: 'خطأ في إنشاء PDF: $e',
                              bgColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 14,
                            );
                          }
                        },
                  tooltip: 'تحميل تقرير',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer4<PreventiveProvider, AboutAppProvider, UserProvider,
          PlaceNameProvider>(
        builder: (context, preventiveProvider, aboutAppProvider, userProvider,
            placeProvider, child) {
          final items = preventiveProvider.preventiveMaintenance;
          final appNames =
              aboutAppProvider.aboutApps.map((a) => a.appName).toSet().toList();

          // Get current user info for role-based department filtering
          final currentUser = userProvider.currentUser;
          final userRole = currentUser?.role ?? '';
          final userDepartment = currentUser?.department ?? '';

          // Build department list based on role
          List<String> departmentList = [];
          List<String> usernames = [];

          if (userRole == 'USER') {
            departmentList = [userDepartment.isEmpty ? 'IT' : userDepartment];
            selectedDepartment = userDepartment.isEmpty ? 'IT' : userDepartment;
            usernames = [currentUser?.username ?? ''];
          } else if (userRole == 'ADMIN' || userRole == 'MANAGER') {
            departmentList = [userDepartment.isEmpty ? 'IT' : userDepartment];
            if (selectedDepartment == 'الكل') {
              selectedDepartment =
                  userDepartment.isEmpty ? 'IT' : userDepartment;
            }
            usernames = userProvider.users
                .where((u) => u.department == userDepartment)
                .map((u) => u.username)
                .where((u) => u != 'admin')
                .where((u) => u != 'gm')
                .toSet()
                .toList();
          } else if (userRole == 'GENERAL_MANAGER' ||
              userRole == 'SECTOR_MANAGER') {
            final allDepartments = userProvider.users
                .map((u) => u.department ?? '')
                .where((d) => d.isNotEmpty)
                .toSet()
                .toList();
            departmentList = ['الكل', ...allDepartments];
            usernames = userProvider.users
                .map((u) => u.username)
                .where((u) => u != 'admin')
                .where((u) => u != 'gm')
                .where((u) => u != 'manager')
                .where((u) => u != 'manager1')
                .toSet()
                .toList();
          } else {
            departmentList = ['الكل'];
            usernames = userProvider.users
                .map((u) => u.username)
                .where((u) => u != 'admin')
                .toSet()
                .toList();
          }

          final placeNames = placeProvider.placeNameStrings;

          final filteredData = getFilteredData(items);

          // Ensure userList has unique values
          final userList = [
            if (currentUser != null && currentUser.role != 'USER') 'الكل',
            ...usernames,
          ].toSet().toList();

          final appList = ['الكل', ...appNames].toSet().toList();
          final placeList = ['الكل', ...placeNames].toSet().toList();

          final isLoading = preventiveProvider.isLoadingMaintenance ||
              aboutAppProvider.isLoading ||
              placeProvider.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
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
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'تصفية البحث',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _isFilterExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateField(
                                      label: 'من تاريخ',
                                      date: startDate,
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDateField(
                                      label: 'إلى تاريخ',
                                      date: endDate,
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(
                                      label: 'الإدارة',
                                      value: departmentList.contains(
                                              selectedDepartment ?? 'الكل')
                                          ? selectedDepartment!
                                          : 'الكل',
                                      items: departmentList,
                                      icon: Icons.business,
                                      onChanged: (value) {
                                        selectedDepartment = value;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDropdown(
                                      label: 'المستخدم',
                                      value: userList.contains(selectedUsername)
                                          ? selectedUsername!
                                          : 'الكل',
                                      items: userList,
                                      icon: Icons.person,
                                      onChanged: (value) {
                                        selectedUsername = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(
                                      label: 'اسم التطبيق',
                                      value: appList.contains(selectedAppName)
                                          ? selectedAppName!
                                          : 'الكل',
                                      items: appList,
                                      icon: Icons.apps,
                                      onChanged: (value) {
                                        selectedAppName = value;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDropdown(
                                      label: 'مكان الزيارة',
                                      value:
                                          placeList.contains(selectedPlaceName)
                                              ? selectedPlaceName!
                                              : 'الكل',
                                      items: placeList,
                                      icon: Icons.location_on,
                                      onChanged: (value) {
                                        selectedPlaceName = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildRemoteDropdown(
                                      label: 'نوع العمل',
                                      value: selectedIsRemote,
                                      onChanged: (value) {
                                        selectedIsRemote = value;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    child: ElevatedButton.icon(
                                      onPressed: _clearFilters,
                                      icon: const Icon(Icons.clear),
                                      label: const Text('مسح الكل'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade100,
                                        foregroundColor: Colors.grey.shade700,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
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
                if (filteredData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 100,
                          child: _buildStatCard(
                            'إجمالي',
                            filteredData.length.toString(),
                            Theme.of(context).colorScheme.primary,
                            Icons.list_alt_rounded,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: _buildStatCard(
                            'عن بُعد',
                            filteredData
                                .where((i) => i.isRemote == 'true')
                                .length
                                .toString(),
                            Colors.blue,
                            Icons.home_work_rounded,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: _buildStatCard(
                            'موقع',
                            filteredData
                                .where((i) => i.isRemote != 'true')
                                .length
                                .toString(),
                            Colors.orange,
                            Icons.location_on_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (filteredData.isNotEmpty) const SizedBox(height: 16),
                Expanded(
                  child: filteredData.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            return _buildCard(item, index);
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
}
