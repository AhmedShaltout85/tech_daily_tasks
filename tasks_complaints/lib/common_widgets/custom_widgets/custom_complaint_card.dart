import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_colors.dart';
import 'custom_text.dart';

class CustomComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback? onDelete;

  const CustomComplaintCard({
    super.key,
    required this.complaint,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_android, complaint.appName),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.report_problem, complaint.complaintName),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.location_on, '${complaint.placeName}${complaint.subPlace != 'none' ? ' - ${complaint.subPlace}' : ''}'),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.business, complaint.department),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.person, '${complaint.empName} (${complaint.empNumber})'),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.phone, complaint.empMobile.toString()),
            if (complaint.createdAt != null) ...[
              const SizedBox(height: 6),
              _buildInfoRow(Icons.access_time, _formatDate(complaint.createdAt!)),
            ],
            if (onDelete != null) ...[
              const Divider(height: 16),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusChip(),
        _buildAppNameChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: complaint.isEnable
            ? AppColors.enabledChip.withOpacity(0.1)
            : AppColors.disabledChip.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: complaint.isEnable ? AppColors.enabledChip : AppColors.disabledChip,
        ),
      ),
      child: CustomText(
        text: complaint.isEnable ? 'مفعل' : 'معطل',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: complaint.isEnable ? AppColors.enabledChip : AppColors.disabledChip,
      ),
    );
  }

  Widget _buildAppNameChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      child: CustomText(
        text: complaint.appName,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: CustomText(
            text: text,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          tooltip: 'حذف',
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar_SA').format(date);
  }
}
