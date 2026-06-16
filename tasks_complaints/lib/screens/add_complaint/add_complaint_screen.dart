import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/connection_dialog_service.dart';
import '../../controller/complaint_provider.dart';
import '../../controller/lookup_provider.dart';
import '../../controller/retrieve_emp_data_provider.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_colors.dart';
import '../../common_widgets/custom_widgets/custom_text_field.dart';
import '../../common_widgets/custom_widgets/custom_dropdown.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _complaintNameController = TextEditingController();
  final _subPlaceController = TextEditingController();
  final _empNameController = TextEditingController();
  final _empNumberController = TextEditingController();
  final _empMobileController = TextEditingController();

  String? _selectedAppName;
  String? _selectedPlaceName;
  String? _selectedDepartment;

  bool _isSubmitting = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  static const List<String> _departments = [
    'ادارة البرامج وصيانتها'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LookupProvider>().fetchAllLookups();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _complaintNameController.dispose();
    _subPlaceController.dispose();
    _empNameController.dispose();
    _empNumberController.dispose();
    _empMobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إضافة شكوى جديدة'),
      centerTitle: true,
      automaticallyImplyLeading: !kIsWeb,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_comment_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'تسجيل شكوى جديدة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'يرجى ملء جميع الحقول المطلوبة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildSectionHeader('بيانات الشكوى', Icons.report_problem_rounded),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                _buildAppDropdown(),
                const SizedBox(height: 14),
                _buildComplaintNameField(),
                const SizedBox(height: 14),
                _buildPlaceDropdown(),
                const SizedBox(height: 14),
                _buildDepartmentDropdown(),
                const SizedBox(height: 14),
                _buildSubPlaceField(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('بيانات الموظف', Icons.person_rounded),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                _buildEmpNumberField(),
                const SizedBox(height: 14),
                _buildEmpNameField(),
                const SizedBox(height: 14),
                _buildEmpMobileField(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAppDropdown() {
    final appNames = context.watch<LookupProvider>().appNames;
    return CustomDropdown(
      label: 'المنظومة',
      hint: 'اختر المنظومة',
      items: appNames,
      value: _selectedAppName,
      validator: (value) => value == null ? 'اختر المنظومة' : null,
      onChanged: (value) => setState(() => _selectedAppName = value),
      icon: Icons.phone_android_rounded,
    );
  }

  Widget _buildComplaintNameField() {
    return CustomTextField(
      label: 'اسم الشكوى',
      hint: 'أدخل وصف الشكوى',
      maxLines: 2,
      controller: _complaintNameController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'أدخل اسم الشكوى';
        return null;
      },
      icon: Icons.edit_note_rounded,
    );
  }

  Widget _buildPlaceDropdown() {
    final placeNames = context.watch<LookupProvider>().placeNames;
    return CustomDropdown(
      label: 'المكان الرئيسي',
      hint: 'اختر المكان',
      items: placeNames,
      value: _selectedPlaceName,
      validator: (value) => value == null ? 'اختر المكان' : null,
      onChanged: (value) => setState(() => _selectedPlaceName = value),
      icon: Icons.location_on_rounded,
    );
  }

  Widget _buildDepartmentDropdown() {
    return CustomDropdown(
      label: 'الادارة',
      hint: 'اختر الادارة',
      items: _departments,
      value: _selectedDepartment,
      validator: (value) => value == null ? 'اختر الادارة' : null,
      onChanged: (value) => setState(() => _selectedDepartment = value),
      icon: Icons.business_rounded,
    );
  }

  Widget _buildSubPlaceField() {
    return CustomTextField(
      label: 'المكان الفرعي',
      hint: 'اختياري',
      controller: _subPlaceController,
      icon: Icons.place_rounded,
    );
  }

  Widget _buildEmpNameField() {
    return CustomTextField(
      label: 'اسم الموظف',
      hint: 'أدخل اسم الموظف',
      controller: _empNameController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'أدخل اسم الموظف';
        return null;
      },
      icon: Icons.person_rounded,
    );
  }

  Widget _buildEmpNumberField() {
    return Consumer<RetrieveEmpDataProvider>(
      builder: (context, empProvider, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: CustomTextField(
                label: 'الرقم الوظيفى',
                hint: '5 أرقام',
                controller: _empNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'أدخل رقم الموظف';
                  }
                  if (value.trim().length != 5) {
                    return 'رقم الموظف يجب أن يكون 5 أرقام';
                  }
                  return null;
                },
                icon: Icons.badge_rounded,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              height: 50,
              child: IconButton(
                onPressed: empProvider.isLoading
                    ? null
                    : () => _fetchEmpName(empProvider),
                icon: empProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search, color: AppColors.primary),
                tooltip: 'بحث عن اسم الموظف',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _fetchEmpName(RetrieveEmpDataProvider provider) async {
    final empNumber = _empNumberController.text.trim();
    if (empNumber.length != 5) {
      Fluttertoast.showToast(
        msg: 'أدخل رقم وظيفى صحيح (5 أرقام)',
        backgroundColor: AppColors.warning,
        textColor: Colors.white,
      );
      return;
    }

    await provider.fetchEmpByEmpId(int.parse(empNumber));

    if (!mounted) return;

    if (provider.empData != null) {
      _empNameController.text = provider.empData!.empName;
      Fluttertoast.showToast(
        msg: 'تم العثور على: ${provider.empData!.empName}',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    } else if (provider.error != null) {
      Fluttertoast.showToast(
        msg: provider.error!,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildEmpMobileField() {
    return CustomTextField(
      label: 'رقم موبايل الموظف',
      hint: '11 رقم',
      controller: _empMobileController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'أدخل موبايل الموظف';
        if (value.trim().length != 11) return 'موبايل الموظف يجب أن يكون 11 رقم';
        return null;
      },
      icon: Icons.phone_rounded,
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'حفظ الشكوى',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ComplaintProvider>();

    final connected = await ConnectionDialogService.checkAndHandleConnection(
      context,
      onConnected: _submitForm,
    );
    if (!connected) return;

    setState(() => _isSubmitting = true);

    final complaint = ComplaintModel(
      appName: _selectedAppName!,
      complaintName: _complaintNameController.text.trim(),
      placeName: _selectedPlaceName!,
      department: _selectedDepartment!,
      subPlace: _subPlaceController.text.trim().isEmpty
          ? 'none'
          : _subPlaceController.text.trim(),
      empName: _empNameController.text.trim(),
      empNumber: _empNumberController.text.trim(),
      empMobile: _empMobileController.text.trim(),
    );

    try {
      await provider.createComplaint(complaint);

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (provider.error == null) {
          _showSuccessDialog();
        } else {
          _showErrorToast(provider.error!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showErrorToast('حدث خطأ: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(
              'تمت الإضافة بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ],
        ),
        content: const Text(
          'تم إضافة الشكوى بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'موافق',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}
