import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';

import '../../controller/task_providers.dart';
import '../custom_widgets/custom_bottom_sheet.dart';

void showSnackBar(String message, BuildContext context) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

//navigation function using MaterialPageRoute
void navigateTo(BuildContext context, Widget widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
//navigation function using MaterialPageRoute
void navigateToNamed(BuildContext context, String routeName) =>
    Navigator.pushNamed(context, routeName);

//navigation function using pushReplacement
void navigateToReplacement(BuildContext context, Widget widget) =>
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );

//navigation function using pushNamed
void navigateToReplacementNamed(BuildContext context, String routeName) =>
    Navigator.pushNamed(context, routeName);

Widget gap({double? height, double? width}) =>
    SizedBox(height: height, width: width);

void showCustomBottomSheet({
  required BuildContext context,
  required List<String> appNames,
  required List<String> employeeNames,
  required List<String> employeeNamesWithoutNone,
}) {
  CustomBottomSheet.show(
    context: context,
    title: 'Task Information',
    fields: [
      TextFieldConfig(
        key: 'title',
        label: 'Task Title',
        hint: 'Enter task title',
        icon: Icons.title,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a task title';
          }
          return null;
        },
      ),
      DropdownFieldConfig(
        key: 'app-name',
        label: 'Enter app name',
        icon: Icons.apps,
        items: appNames,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a app name';
          }
          return null;
        },
      ),
      TextFieldConfig(
        key: 'assign-by',
        label: 'Assign By',
        hint: 'Enter assign by',
        icon: Icons.manage_accounts,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a assign by';
          }
          return null;
        },
      ),
      DropdownFieldConfig(
        key: 'assign-to',
        label: 'Assign To',
        items: employeeNamesWithoutNone,
        icon: Icons.person,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an assignee';
          }
          return null;
        },
      ),
      TextFieldConfig(
        key: 'visit-place',
        label: 'Visit Place',
        hint: 'Enter visit place',
        icon: Icons.location_on,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a visit place';
          }
          return null;
        },
      ),
      DropdownFieldConfig(
        key: 'task-priority',
        label: 'Enter task priority',
        items: ['High', 'Medium', 'Low'],
        icon: Icons.priority_high,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a task priority';
          }
          return null;
        },
      ),
      MultiSelectDropdownFieldConfig(
        key: 'co-operator',
        label: 'Co-operator',
        items: employeeNames,
        icon: Icons.person,
        hint: 'Select co-operators',
        initialValues: [],
        includeSearch: false,
        includeSelectAll: false,
        isLarge: true,
        boxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey),
        ),
        onChange: (values) {
          log('Selected co-operators: $values');
        },
      ),
      TextFieldConfig(
        key: 'expected-completion-date',
        label: 'Expected Completion Date',
        hint: 'Enter Expected Completion Date like 7, 15, 30 days',
        icon: Icons.date_range,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter expected completion date';
          }
          return null;
        },
      ),
      TextFieldConfig(
        key: 'task-note',
        label: 'Task Note',
        hint: 'Enter note',
        icon: Icons.note,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a note';
          }
          return null;
        },
      ),
    ],
    submitButtonText: 'Save',
    onSubmit: (values) async {
      log('Form submitted: $values');
      try {
        await context.read<TaskProviders>().addTask({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'taskTitle': values['title'],
          'applicationName': values['app-name'],
          'taskNote': values['task-note'],
          'assignedBy': values['assign-by'],
          'assignedTo': values['assign-to'],
          'visitPlace': values['visit-place'],
          'taskPriority': values['task-priority'],
          'coOperator': values['co-operator'],
          'taskStatus': true,
          'expectedCompletionDate': DateTime.now().add(
            Duration(
              days: int.parse(values['expected-completion-date'] as String),
            ),
          ),
        });
        log('Task added successfully');
        ReusableToast.showToast(
          message: 'Task added successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
      } catch (e) {
        log('Error adding task: $e');
        ReusableToast.showToast(
          message: 'Error adding task: $e',
          bgColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    },
    onCancel: () {
      // Just log the cancellation, don't call Navigator.pop
      log('Bottom sheet cancelled');
    },
  );
}

//reset password function
void showCustomUpdatePasswordDialog({
  required BuildContext context,
  required String title,
  required String submitButtonText,
  required void Function()? onPressed,
  required TextEditingController email,
  required TextEditingController password,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: onPressed, child: Text(submitButtonText)),
        ],
      );
    },
  );
}
