// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_user_drawer.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/task_providers.dart';


import '../../common_widgets/custom_widgets/task_item_card.dart';

class UserTaskScreen extends StatefulWidget {
  const UserTaskScreen({super.key});

  @override
  State<UserTaskScreen> createState() => _UserTaskScreenState();
}

class _UserTaskScreenState extends State<UserTaskScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch tasks
      context.read<TaskProviders>().fetchTasksByStatus(true);
    });
  }

  void _showEditNoteDialog(
    BuildContext context,
    dynamic task,
    TaskProviders provider,
  ) {
    final TextEditingController noteController = TextEditingController(
      text: task.taskNote,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Task Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Task Note',
              hintText: 'Enter task note',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedNote = noteController.text.trim();
                Navigator.of(dialogContext).pop();

                await provider.updateTask(task.id, {'taskNote': updatedNote});

                // Show success message
                ReusableToast.showToast(
                  message: 'Task note updated successfully',
                  textColor: Colors.white,
                  bgColor: Colors.green,
                  fontSize: 16,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks Assigned to ${FirebaseAuth.instance.currentUser!.displayName}',
          // 'Tasks Assigned to ${FirebaseAuth.instance.currentUser!.email?.substring(0, FirebaseAuth.instance.currentUser!.email!.indexOf('@'))}',
        ),
        actions: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${context.watch<TaskProviders>().tasks.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<TaskProviders>(
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
                      provider.fetchTasksByStatus(true);
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
                  // SizedBox(height: 8),
                  // Text(
                  //   'Tap + to add a new task',
                  //   style: TextStyle(fontSize: 14, color: Colors.grey),
                  // ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTasks(),
            child: ListView.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                log(
                  'Building TaskItemCard for task ID: ${task.taskPriority} at index $index with title: ${task.taskTitle}',
                );
                return InkWell(
                  child: TaskItemCard(task: task, isDeletedEnabled: false),
                  onTap: () {
                    _showEditNoteDialog(context, task, provider);
                  },
                );
              },
            ),
          );
        },
      ),
      drawer: const CustomUserDrawer(),
    );
  }
}
