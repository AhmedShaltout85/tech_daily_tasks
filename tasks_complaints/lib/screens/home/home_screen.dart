import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/complaint_provider.dart';
import '../../services/connectivity_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_route.dart';
import '../../common_widgets/custom_widgets/custom_text.dart';
import '../../common_widgets/custom_widgets/custom_loading.dart';
import '../../common_widgets/custom_widgets/custom_complaint_card.dart';
import '../../common_widgets/custom_widgets/custom_dropdown.dart';
import '../../common_widgets/custom_widgets/custom_button.dart';
import '../../models/complaint_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connected = await _connectivityService.hasConnection();
      if (!mounted) return;
      if (!connected) {
        _showNoInternetDialog();
        return;
      }
      if (!mounted) return;
      context.read<ComplaintProvider>().fetchAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('شكاوى الموظفين'),
      actions: [
        IconButton(
          onPressed: _showFilterBottomSheet,
          icon: const Icon(Icons.filter_list),
          tooltip: 'تصفية',
        ),
        IconButton(
          onPressed: _loadComplaints,
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const CustomLoading(size: 40);
        if (provider.error != null) return _buildErrorState(provider);
        if (provider.complaints.isEmpty) return _buildEmptyState();
        return _buildComplaintList(provider);
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, AppRoute.addComplaintRoute),
      child: const Icon(Icons.add, size: 28),
    );
  }

  Widget _buildErrorState(ComplaintProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            CustomText(
              text: provider.error!,
              fontSize: 16,
              color: AppColors.error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'إعادة المحاولة',
              onPressed: () => _loadComplaints(),
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 100,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'لا توجد شكاوى',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: 'اضغط على + لإضافة شكوى جديدة',
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintList(ComplaintProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return _buildResponsiveGrid(provider.complaints, maxWidth: 1024);
          } else if (constraints.maxWidth > 600) {
            return _buildResponsiveGrid(provider.complaints);
          }
          return _buildMobileList(provider.complaints);
        },
      ),
    );
  }

  Widget _buildMobileList(List<ComplaintModel> complaints) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: complaints.length,
      itemBuilder: (context, index) => _buildCard(complaints[index]),
    );
  }

  Widget _buildResponsiveGrid(List<ComplaintModel> complaints, {double? maxWidth}) {
    final grid = GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: complaints.length,
      itemBuilder: (context, index) => _buildCard(complaints[index]),
    );

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: grid,
        ),
      );
    }
    return grid;
  }

  Widget _buildCard(ComplaintModel complaint) {
    return CustomComplaintCard(
      complaint: complaint,
      onDelete: () => _confirmDelete(complaint),
    );
  }

  void _confirmDelete(ComplaintModel complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الشكوى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ComplaintProvider>().deleteComplaint(complaint.id!);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.wifi_off, size: 60, color: AppColors.error),
        title: const Text('لا يوجد اتصال بالإنترنت'),
        content: const Text('تحقق من اتصالك بالإنترنت وأعد المحاولة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadComplaints();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final provider = context.read<ComplaintProvider>();
    String? selectedApp;
    String? selectedDept;
    String? selectedEmp;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildFilterContent(
            provider: provider,
            setModalState: setModalState,
            selectedApp: selectedApp,
            selectedDept: selectedDept,
            selectedEmp: selectedEmp,
            onAppChanged: (value) => setModalState(() => selectedApp = value),
            onDeptChanged: (value) => setModalState(() => selectedDept = value),
            onEmpChanged: (value) => setModalState(() => selectedEmp = value),
            onApply: () {
              _applyFilter(provider, selectedApp, selectedDept, selectedEmp);
              Navigator.pop(context);
            },
            onClear: () {
              provider.clearFilter();
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterContent({
    required ComplaintProvider provider,
    required StateSetter setModalState,
    required String? selectedApp,
    required String? selectedDept,
    required String? selectedEmp,
    required ValueChanged<String?> onAppChanged,
    required ValueChanged<String?> onDeptChanged,
    required ValueChanged<String?> onEmpChanged,
    required VoidCallback onApply,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomText(
            text: 'تصفية الشكاوى',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'تطبيق/نظام',
            hint: 'اختر التطبيق',
            items: ['الكل', ...provider.getUniqueAppNames()],
            value: selectedApp ?? 'الكل',
            onChanged: onAppChanged,
            icon: Icons.phone_android,
          ),
          const SizedBox(height: 12),
          CustomDropdown(
            label: 'القسم',
            hint: 'اختر القسم',
            items: ['الكل', ...provider.getUniqueDepartments()],
            value: selectedDept ?? 'الكل',
            onChanged: onDeptChanged,
            icon: Icons.business,
          ),
          const SizedBox(height: 12),
          CustomDropdown(
            label: 'اسم الموظف',
            hint: 'اختر الموظف',
            items: ['الكل', ...provider.getUniqueEmpNames()],
            value: selectedEmp ?? 'الكل',
            onChanged: onEmpChanged,
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: CustomButton(text: 'مسح', onPressed: onClear)),
              const SizedBox(width: 12),
              Expanded(child: CustomButton(text: 'تطبيق', onPressed: onApply)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _applyFilter(
    ComplaintProvider provider,
    String? app,
    String? dept,
    String? emp,
  ) {
    if (app != null) {
      provider.filterByAppName(app);
    } else if (dept != null) {
      provider.filterByDepartment(dept);
    } else if (emp != null) {
      provider.filterByEmpName(emp);
    } else {
      provider.clearFilter();
    }
  }
}
