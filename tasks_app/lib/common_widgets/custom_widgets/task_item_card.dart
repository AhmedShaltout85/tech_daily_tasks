import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controller/task_providers.dart';
import '../../models/task.dart';

class TaskItemCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool isDeletedEnabled;

  const TaskItemCard({
    super.key,
    required this.task,
    this.onTap,
    required this.isDeletedEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProviders>(context, listen: false);
    final isOverdue =
        task.expectedCompletionDate.isBefore(DateTime.now()) && task.taskStatus;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: _getBorderColor(task), width: 2.0),
      ),
      child: InkWell(
        onTap: onTap,
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
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Title
                          Text(
                            task.taskTitle,
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
                    // Priority Badge
                    _buildPriorityBadge(task.taskPriority),
                  ],
                ),

                const Divider(height: 24, thickness: 1),

                // Task Details
                _buildDetailRow(
                  Icons.business,
                  'Application',
                  task.applicationName,
                  Colors.blue,
                ),
                const SizedBox(height: 8),

                if (task.assignedBy.isNotEmpty &&
                    task.assignedTo.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.person_outline,
                    'Assigned By',
                    task.assignedBy,
                    Colors.deepPurple,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.person,
                    'Assigned To',
                    task.assignedTo,
                    Colors.teal,
                  ),
                  const SizedBox(height: 8),
                ],

                _buildDetailRow(
                  Icons.location_on,
                  'Visit Place',
                  task.visitPlace,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.group,
                  'Co-Operator',
                  task.coOperator.length > 1
                      ? '${task.coOperator.first}, ${task.coOperator.last}'
                      : task.coOperator.first,
                  Colors.brown,
                ),
                const SizedBox(height: 8),

                // Dates Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDateRow(
                        Icons.calendar_today,
                        'Created',
                        task.createdAt,
                        Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      _buildDateRow(
                        Icons.event,
                        'Expected Completion',
                        task.expectedCompletionDate,
                        isOverdue ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    // Status Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: task.taskStatus
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: task.taskStatus
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              task.taskStatus
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 18,
                              color: task.taskStatus
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.taskStatus ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: task.taskStatus
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Toggle Status Button
                    Material(
                      color: task.taskStatus
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _toggleTaskStatus(context, provider),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            task.taskStatus
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete Button
                    isDeletedEnabled
                        ? Material(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () =>
                                  _showDeleteConfirmation(context, provider),
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
                          )
                        : const SizedBox.shrink(),
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

    switch (priority.toLowerCase()) {
      case 'high':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.priority_high;
        break;
      case 'medium':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.remove;
        break;
      case 'low':
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

  Widget _buildDateRow(
    IconData icon,
    String label,
    DateTime date,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCardColor(Task task) {
    final colorMap = {
      'high': Colors.red.shade50,
      'medium': Colors.orange.shade50,
      'low': Colors.blue.shade50,
    };

    return colorMap[task.taskPriority.toLowerCase()] ?? Colors.grey.shade50;
  }

  Color _getBorderColor(Task task) {
    final colorMap = {
      'high': Colors.red.shade300,
      'medium': Colors.orange.shade300,
      'low': Colors.blue.shade300,
    };

    return colorMap[task.taskPriority.toLowerCase()] ?? Colors.grey.shade300;
  }

  Future<void> _toggleTaskStatus(
    BuildContext context,
    TaskProviders provider,
  ) async {
    try {
      await provider.updateTask(task.id, {'taskStatus': !task.taskStatus});
      isDeletedEnabled
          ? await provider.fetchTasks()
          : provider.fetchTasksByStatus(true);

      if (context.mounted) {
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
      if (context.mounted) {
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

  void _showDeleteConfirmation(BuildContext context, TaskProviders provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context);
              try {
                await provider.deleteTask(task.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Error deleting task: ${e.toString()}'),
                          ),
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

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }
}
