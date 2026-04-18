// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controller/local_control/task_provider.dart';
import '../../../models/hive_model/task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final taskTitleController = TextEditingController();
  final taskDescriptionController = TextEditingController();
  final taskNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize tasks on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tasks are already loaded via stream in provider
    });
  }

  @override
  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    taskNoteController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    // Clear previous input
    taskTitleController.clear();
    taskDescriptionController.clear();
    taskNoteController.clear();

    showDialog(
      context: context,
      builder: (context) {
        bool isAdding = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskTitleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: taskDescriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: taskNoteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                ],
              ),
              actions: [
                if (isAdding)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          // Validate input
                          if (taskTitleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a title'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isAdding = true;
                          });

                          try {
                            final provider = Provider.of<TaskProvider>(
                              dialogContext,
                              listen: false,
                            );

                            final task = TaskModel(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              title: taskTitleController.text.trim(),
                              status: true, // Default to active
                              taskDescription: taskDescriptionController.text
                                  .trim(),
                              notes: taskNoteController.text.trim(),
                              assignedTo: 'Anonymous',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            await provider.addTask(task);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              // Show success message using the main context
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Center(
                                        child: Text('Task added successfully'),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              });
                            }
                          } catch (e) {
                            log('Error adding task: $e');
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isAdding = false;
                              });
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(color: Colors.blue)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.blue),
            onPressed: () {
              // Manual sync trigger (optional)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(child: Text('Syncing...')),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_off, color: Colors.orange),
            onPressed: () {
              // Show sync status
              final provider = context.read<TaskProvider>();
              final unsyncedTasks = provider.tasks
                  .where((task) => !task.isSynced)
                  .length;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$unsyncedTasks tasks pending sync'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading
                      provider.notifyListeners();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add a new task',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger refresh
              provider.notifyListeners();
            },
            child: ListView.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return TaskItemCard(task: task);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TaskItemCard extends StatelessWidget {
  final TaskModel task;

  const TaskItemCard({super.key, required this.task});

  void _toggleTaskStatus(BuildContext context) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    try {
      final updatedTask = task.copyWith(
        status: !task.status,
        updatedAt: DateTime.now(),
      );
      await provider.updateTask(updatedTask);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                task.status
                    ? 'Task marked as inactive'
                    : 'Task marked as active',
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      log('Error updating task: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _deleteTask(BuildContext context) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    try {
      await provider.deleteTask(task.id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } catch (e) {
      log('Error deleting task: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              _deleteTask(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorList = <Color>[
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.yellow.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: colorList[task.id.hashCode.abs() % colorList.length],
        border: Border.all(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!task.isSynced)
              const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
          ],
        ),
        title: Text(
          task.title ?? 'No Title',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.taskDescription?.isNotEmpty ?? false)
                Text(
                  'Description: ${task.taskDescription}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              if (task.notes?.isNotEmpty ?? false)
                Text(
                  'Note: ${task.notes}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    task.status ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: task.status ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${task.status ? "Active" : "Inactive"}',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (task.createdAt != null)
                Text(
                  'Created: ${_formatDate(task.createdAt!)}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              if (task.assignedTo?.isNotEmpty ?? false)
                Text(
                  'Assigned to: ${task.assignedTo}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle Status Button
            IconButton(
              icon: Icon(
                task.status ? Icons.toggle_on : Icons.toggle_off,
                color: task.status ? Colors.green : Colors.grey,
                size: 32,
              ),
              onPressed: () => _toggleTaskStatus(context),
            ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
