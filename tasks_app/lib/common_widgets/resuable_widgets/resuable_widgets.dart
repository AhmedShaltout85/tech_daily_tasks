import 'dart:developer';

import 'package:flutter/material.dart';

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
  List<String>? placeNames,
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
      DropdownFieldConfig(
        key: 'visit-place',
        label: 'Visit Place',
        icon: Icons.location_on,
        items: placeNames ?? [],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a visit place';
          }
          return null;
        },
      ),
      TextFieldConfig(
        key: 'sub-place',
        label: 'Sub Place',
        hint: 'Enter sub place (optional)',
        icon: Icons.location_on_outlined,
      ),
      DropdownFieldConfig(
        key: 'task-priority',
        label: 'Enter task priority',
        items: ['HIGH', 'MEDIUM', 'LOW'],
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
    },
    onCancel: () {
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
