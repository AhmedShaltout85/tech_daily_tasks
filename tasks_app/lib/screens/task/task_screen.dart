// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tasks_app/controller/task_providers.dart';

// import '../../common_widgets/custom_widgets/custom_drawer.dart';
// import '../../common_widgets/custom_widgets/task_item_card.dart';
// import '../../common_widgets/resuable_widgets/resuable_widgets.dart';
// import '../../controller/app_name_provider.dart';
// import '../../controller/employee_name_provider.dart';
// import '../../controller/theme_provider.dart';

// class TaskScreen extends StatefulWidget {
//   const TaskScreen({super.key});

//   @override
//   State<TaskScreen> createState() => _TaskScreenState();
// }

// class _TaskScreenState extends State<TaskScreen> {
//   // Filter states
//   String? selectedEmployee;
//   String? selectedApp;
//   bool? isActiveFilter;
//   bool showFilters = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<TaskProviders>().fetchTasks();
//       context.read<EmployeeNameProvider>().fetchEmployeeNamesAsStrings();
//       context.read<AppNameProvider>().fetchAppNamesAsStrings();
//     });
//   }

//   List<dynamic> getFilteredTasks(List<dynamic> tasks) {
//     return tasks.where((task) {
//       try {
//         if (selectedEmployee != null && selectedEmployee!.isNotEmpty) {
//           final taskEmployee = task.assignedTo?.toString() ?? '';
//           if (taskEmployee != selectedEmployee) return false;
//         }

//         if (selectedApp != null && selectedApp!.isNotEmpty) {
//           final taskApp = task.applicationName?.toString() ?? '';
//           if (taskApp != selectedApp) return false;
//         }

//         if (isActiveFilter != null) {
//           final taskActive = task.taskStatus ?? true;
//           if (taskActive != isActiveFilter) return false;
//         }

//         return true;
//       } catch (e) {
//         log('Error filtering task: $e');
//         return true;
//       }
//     }).toList();
//   }

//   void resetFilters() {
//     setState(() {
//       selectedEmployee = null;
//       selectedApp = null;
//       isActiveFilter = null;
//     });
//   }

//   bool get hasActiveFilters =>
//       selectedEmployee != null || selectedApp != null || isActiveFilter != null;

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = themeProvider.isDark;
//     final colorScheme = Theme.of(context).colorScheme;

//     List<String> employeeNames = context
//         .watch<EmployeeNameProvider>()
//         .employeeNameStrings
//         .toSet()
//         .toList();
//     List<String> appNames = context
//         .watch<AppNameProvider>()
//         .appNameStrings
//         .toSet()
//         .toList();

//     employeeNames.contains('system.admin')
//         ? employeeNames.remove('system.admin')
//         : employeeNames;

//     List<String> uniqueEmployeeNames = ['none', ...employeeNames];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tasks'),
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 tooltip: 'Filters',
//                 icon: const Icon(Icons.filter_list),
//                 onPressed: () {
//                   setState(() {
//                     showFilters = !showFilters;
//                   });
//                 },
//               ),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const SizedBox(width: 8, height: 8),
//                   ),
//                 ),
//             ],
//           ),
//           IconButton(
//             tooltip: 'Add Task',
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               showCustomBottomSheet(
//                 context: context,
//                 appNames: appNames,
//                 employeeNames: uniqueEmployeeNames,
//                 employeeNamesWithoutNone: uniqueEmployeeNames
//                     .where((name) => name != 'none')
//                     .toList(),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filter section
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             height: showFilters ? null : 0,
//             child: showFilters
//                 ? Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: isDark ? colorScheme.surface : Colors.grey[100],
//                       boxShadow: [
//                         BoxShadow(
//                           color: isDark
//                               ? Colors.black.withOpacity(0.3)
//                               : Colors.grey.withOpacity(0.3),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Filters',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: isDark ? Colors.white : Colors.black87,
//                               ),
//                             ),
//                             if (hasActiveFilters)
//                               TextButton.icon(
//                                 onPressed: resetFilters,
//                                 icon: Icon(
//                                   Icons.clear_all,
//                                   size: 18,
//                                   color: colorScheme.primary,
//                                 ),
//                                 label: Text(
//                                   'Clear All',
//                                   style: TextStyle(color: colorScheme.primary),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 initialValue: selectedEmployee,
//                                 isExpanded: true,
//                                 dropdownColor: isDark
//                                     ? colorScheme.surface
//                                     : Colors.white,
//                                 style: TextStyle(
//                                   color: isDark ? Colors.white : Colors.black87,
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'Assigned To',
//                                   labelStyle: TextStyle(
//                                     color: isDark
//                                         ? Colors.grey[400]
//                                         : Colors.grey[700],
//                                   ),
//                                   prefixIcon: Icon(
//                                     Icons.person,
//                                     color: colorScheme.primary,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   filled: true,
//                                   fillColor: isDark
//                                       ? colorScheme.surface.withOpacity(0.5)
//                                       : Colors.white,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 14,
//                                   ),
//                                 ),
//                                 items: [
//                                   DropdownMenuItem<String>(
//                                     value: null,
//                                     child: Text(
//                                       'All Employees',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: isDark
//                                             ? Colors.grey[300]
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   ...employeeNames.map((name) {
//                                     return DropdownMenuItem<String>(
//                                       value: name,
//                                       child: Text(
//                                         name,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                           color: isDark
//                                               ? Colors.grey[300]
//                                               : Colors.black87,
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 ],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedEmployee = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 5),
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 initialValue: selectedApp,
//                                 isExpanded: true,
//                                 dropdownColor: isDark
//                                     ? colorScheme.surface
//                                     : Colors.white,
//                                 style: TextStyle(
//                                   color: isDark ? Colors.white : Colors.black87,
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'Application',
//                                   labelStyle: TextStyle(
//                                     color: isDark
//                                         ? Colors.grey[400]
//                                         : Colors.grey[700],
//                                   ),
//                                   prefixIcon: Icon(
//                                     Icons.apps,
//                                     color: colorScheme.primary,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   filled: true,
//                                   fillColor: isDark
//                                       ? colorScheme.surface.withOpacity(0.5)
//                                       : Colors.white,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 14,
//                                   ),
//                                 ),
//                                 items: [
//                                   DropdownMenuItem<String>(
//                                     value: null,
//                                     child: Text(
//                                       'All Apps',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: isDark
//                                             ? Colors.grey[300]
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   ...appNames.map((name) {
//                                     return DropdownMenuItem<String>(
//                                       value: name,
//                                       child: Text(
//                                         name,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                           color: isDark
//                                               ? Colors.grey[300]
//                                               : Colors.black87,
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 ],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedApp = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 5),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: DropdownButtonFormField<bool?>(
//                                 initialValue: isActiveFilter,
//                                 isExpanded: true,
//                                 dropdownColor: isDark
//                                     ? colorScheme.surface
//                                     : Colors.white,
//                                 style: TextStyle(
//                                   color: isDark ? Colors.white : Colors.black87,
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'Status',
//                                   labelStyle: TextStyle(
//                                     color: isDark
//                                         ? Colors.grey[400]
//                                         : Colors.grey[700],
//                                   ),
//                                   prefixIcon: Icon(
//                                     Icons.toggle_on,
//                                     color: colorScheme.primary,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   filled: true,
//                                   fillColor: isDark
//                                       ? colorScheme.surface.withOpacity(0.5)
//                                       : Colors.white,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 14,
//                                   ),
//                                 ),
//                                 items: [
//                                   DropdownMenuItem<bool?>(
//                                     value: null,
//                                     child: Text(
//                                       'All Status',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: isDark
//                                             ? Colors.grey[300]
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   DropdownMenuItem<bool?>(
//                                     value: true,
//                                     child: Text(
//                                       'Active Only',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: isDark
//                                             ? Colors.grey[300]
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   DropdownMenuItem<bool?>(
//                                     value: false,
//                                     child: Text(
//                                       'Inactive Only',
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: isDark
//                                             ? Colors.grey[300]
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     isActiveFilter = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 5),
//                             const Expanded(child: SizedBox.shrink()),
//                           ],
//                         ),
//                       ],
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//           ),

//           // Task list
//           Expanded(
//             child: Consumer<TaskProviders>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading && provider.tasks.isEmpty) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: colorScheme.primary,
//                     ),
//                   );
//                 }

//                 if (provider.error != null) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           size: 64,
//                           color: colorScheme.error,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Error: ${provider.error}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: isDark ? Colors.grey[300] : Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             provider.fetchTasks();
//                           },
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (provider.tasks.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.task_outlined,
//                           size: 64,
//                           color: isDark ? Colors.grey[600] : Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No tasks found',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: isDark ? Colors.grey[400] : Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Tap + to add a new task',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: isDark ? Colors.grey[500] : Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final filteredTasks = getFilteredTasks(provider.tasks);

//                 if (filteredTasks.isEmpty && hasActiveFilters) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.search_off,
//                           size: 64,
//                           color: isDark ? Colors.grey[600] : Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No tasks match your filters',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: isDark ? Colors.grey[400] : Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextButton.icon(
//                           onPressed: resetFilters,
//                           icon: const Icon(Icons.clear_all),
//                           label: const Text('Clear Filters'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return RefreshIndicator(
//                   onRefresh: () => provider.fetchTasks(),
//                   color: colorScheme.primary,
//                   child: Column(
//                     children: [
//                       if (hasActiveFilters)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 size: 16,
//                                 color: colorScheme.primary,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Showing ${filteredTasks.length} of ${provider.tasks.length} tasks',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: colorScheme.primary,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: filteredTasks.length,
//                           itemBuilder: (context, index) {
//                             final task = filteredTasks[index];
//                             log(
//                               'Building TaskItemCard for task ID: ${task.taskPriority} at index $index with title: ${task.taskTitle}',
//                             );
//                             return TaskItemCard(
//                               task: task,
//                               isDeletedEnabled: true,
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       drawer: const CustomDrawer(),
//     );
//   }
// }
