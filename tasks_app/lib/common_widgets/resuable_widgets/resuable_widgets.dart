// ignore_for_file: unused_element_parameter

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tasks_app/utils/app_colors.dart';

import '../custom_widgets/custom_bottom_sheet.dart';
import '../custom_widgets/custom_bottom_sheet.dart' as configs;

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
  String? selectedAssignee,
  Function(Map<String, dynamic>)? onSubmitTask,
}) {
  String? currentAssignee;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => StatefulBuilder(
      builder: (context, setState) {
        // Update co-operator list based on current assignee
        final filteredCoOperators = employeeNames
            .where((name) =>
                name.isNotEmpty && name != 'none' && name != currentAssignee)
            .toList();

        return _buildBottomSheetContent(
          context: bottomSheetContext,
          appNames: appNames,
          employeeNamesWithoutNone: employeeNamesWithoutNone,
          placeNames: placeNames,
          filteredCoOperators: filteredCoOperators,
          onAssigneeChanged: (value) {
            setState(() {
              currentAssignee = value;
            });
          },
          onSubmitTask: onSubmitTask,
        );
      },
    ),
  );
}

Widget _buildBottomSheetContent({
  required BuildContext context,
  required List<String> appNames,
  required List<String> employeeNamesWithoutNone,
  List<String>? placeNames,
  required List<String> filteredCoOperators,
  required Function(String?) onAssigneeChanged,
  Function(Map<String, dynamic>)? onSubmitTask,
}) {
  // Build the fields with the filtered co-operator list
  final fields = [
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
      initialValue: 'admin',
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
      onChanged: onAssigneeChanged,
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
      items: filteredCoOperators,
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
    ),
    TextFieldConfig(
      key: 'expected-completion-date',
      label: 'Expected Completion Date',
      hint: 'Enter Expected Completion Date like 7, 15, 30 days',
      icon: Icons.date_range,
      initialValue: '1',
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
      initialValue: 'None',
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
  ];

  return _CustomBottomSheetContent(
    title: 'Task Information',
    fields: fields,
    submitButtonText: 'Save',
    onSubmit: (values) async {
      if (onSubmitTask != null) {
        onSubmitTask!(values);
      }
    },
  );
}

// Internal widget to show the bottom sheet content
class _CustomBottomSheetContent extends StatefulWidget {
  final String title;
  final List<FieldConfig> fields;
  final String submitButtonText;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;

  const _CustomBottomSheetContent({
    required this.title,
    required this.fields,
    this.submitButtonText = 'Submit',
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<_CustomBottomSheetContent> createState() =>
      _CustomBottomSheetContentState();
}

class _CustomBottomSheetContentState extends State<_CustomBottomSheetContent> {
  late Map<String, TextEditingController> _controllers;
  late Map<String, String?> _dropdownValues;
  late Map<String, List<String>> _multiSelectValues;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _dropdownValues = {};
    _multiSelectValues = {};

    for (var field in widget.fields) {
      if (field is TextFieldConfig) {
        _controllers[field.key] =
            TextEditingController(text: field.initialValue);
      } else if (field is DropdownFieldConfig) {
        _dropdownValues[field.key] = field.initialValue;
      } else if (field is MultiSelectDropdownFieldConfig) {
        _multiSelectValues[field.key] =
            List<String>.from(field.initialValues ?? []);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == ThemeData.dark().brightness;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.whiteColor : AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ...widget.fields
                  .map((field) => _buildField(field, isDark, colorScheme)),
              const SizedBox(height: 24),
              Row(
                children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.submitButtonText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    ),
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ])
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(FieldConfig field, bool isDark, ColorScheme colorScheme) {
    if (field is TextFieldConfig) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: _controllers[field.key],
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: field.label,
            labelStyle:
                TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
            hintText: field.hint,
            hintStyle:
                TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
            prefixIcon: field.icon != null
                ? Icon(field.icon, color: colorScheme.primary)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: isDark
                ? colorScheme.surface.withValues(alpha: 0.5)
                : Colors.grey[50],
          ),
          keyboardType: field.keyboardType,
          maxLines: field.maxLines,
          obscureText: field.obscureText,
          validator: field.validator,
        ),
      );
    } else if (field is DropdownFieldConfig) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          value: _dropdownValues[field.key],
          dropdownColor: isDark ? colorScheme.surface : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: field.label,
            labelStyle:
                TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
            hintText: field.hint,
            hintStyle:
                TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
            prefixIcon: field.icon != null
                ? Icon(field.icon, color: colorScheme.primary)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: isDark
                ? colorScheme.surface.withValues(alpha: 0.5)
                : Colors.grey[50],
          ),
          items: field.items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item,
                        style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.black87)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _dropdownValues[field.key] = value;
            });
            field.onChanged?.call(value);
          },
          validator: field.validator,
        ),
      );
    } else if (field is MultiSelectDropdownFieldConfig) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(field.label,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.black87)),
              ),
            Container(
              decoration: field.boxDecoration ??
                  BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: field.items.map((item) {
                      final isSelected =
                          _multiSelectValues[field.key]?.contains(item) ??
                              false;
                      return FilterChip(
                        label: Text(item),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _multiSelectValues[field.key] ??= [];
                            if (selected) {
                              _multiSelectValues[field.key]!.add(item);
                            } else {
                              _multiSelectValues[field.key]!.remove(item);
                            }
                          });
                        },
                        selectedColor:
                            colorScheme.primary.withValues(alpha: 0.3),
                        checkmarkColor: colorScheme.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final values = <String, dynamic>{};
      _controllers.forEach((key, controller) => values[key] = controller.text);
      _dropdownValues.forEach((key, value) {
        if (value != null) values[key] = value;
      });
      _multiSelectValues.forEach((key, value) => values[key] = value);
      widget.onSubmit(values);
      Navigator.pop(context);
    }
  }
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
