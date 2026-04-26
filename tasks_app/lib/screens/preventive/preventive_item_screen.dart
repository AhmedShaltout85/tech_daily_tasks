import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/controller/preventive_provider.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/models/preventive_item_model.dart';
import 'package:tasks_app/services/connectivity_service.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';

class PreventiveItemScreen extends StatefulWidget {
  const PreventiveItemScreen({super.key});

  @override
  State<PreventiveItemScreen> createState() => _PreventiveItemScreenState();
}

class _PreventiveItemScreenState extends State<PreventiveItemScreen> {
  final ConnectivityService _connectivity = ConnectivityService();
  final TextEditingController _actionController = TextEditingController();
  bool _isLoading = false;
  String? _selectedAppName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    final userProvider = context.read<UserProvider>();
    final department = userProvider.currentUser?.department;

    if (department != null && department.isNotEmpty) {
      await context.read<AboutAppProvider>().fetchAppsByDepartment(department);
    } else {
      await context.read<AboutAppProvider>().fetchAllAboutApps();
    }
    await context.read<PreventiveProvider>().fetchAllPreventiveItems();
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text('Please check your connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<PreventiveItemModel> _getItemsForApp(String appName) {
    final provider = context.read<PreventiveProvider>();
    return provider.preventiveItems
        .where((item) => item.appName == appName)
        .toList();
  }

  void _showAddEditDialog(
      {PreventiveItemModel? item, required String appName}) async {
    if (item != null) {
      _actionController.text = item.action;
    } else {
      _actionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item == null ? 'Add Action to $appName' : 'Edit Action',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _actionController,
                decoration: InputDecoration(
                  labelText: 'Action',
                  hintText: 'Enter preventive action',
                  prefixIcon: const Icon(Icons.build),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveItem(item, appName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(item == null ? 'Add' : 'Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem(PreventiveItemModel? item, String appName) async {
    if (_actionController.text.isEmpty) {
      ReusableToast.showToast(
        message: 'Please enter an action',
        bgColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 14,
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final provider = context.read<PreventiveProvider>();
      if (item == null) {
        await provider.addPreventiveItem(appName, _actionController.text);
        ReusableToast.showToast(
          message: 'Action added successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14,
        );
      } else {
        await provider.updatePreventiveItem(
            item.id!, appName, _actionController.text);
        ReusableToast.showToast(
          message: 'Action updated successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14,
        );
      }
    } catch (e) {
      ReusableToast.showToast(
        message: 'Error: $e',
        bgColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(PreventiveItemModel item) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Action'),
        content: Text('Are you sure you want to delete "${item.action}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await context
                    .read<PreventiveProvider>()
                    .deletePreventiveItem(item.id!);
                ReusableToast.showToast(
                  message: 'Action deleted',
                  bgColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 14,
                );
              } catch (e) {
                ReusableToast.showToast(
                  message: 'Error: $e',
                  bgColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 14,
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preventive Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      floatingActionButton: _selectedAppName != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEditDialog(appName: _selectedAppName!),
              icon: const Icon(Icons.add),
              label: const Text('Add Action'),
            )
          : null,
      body: Consumer2<AboutAppProvider, PreventiveProvider>(
        builder: (context, aboutAppProvider, preventiveProvider, child) {
          if (aboutAppProvider.isLoading ||
              preventiveProvider.isLoadingItems ||
              _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final appNames =
              aboutAppProvider.aboutApps.map((a) => a.appName).toSet().toList();

          if (appNames.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apps_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No Applications Found',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add apps in Manage Apps first',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Horizontal app name list
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: appNames.length,
                  itemBuilder: (context, index) {
                    final appName = appNames[index];
                    final isSelected = _selectedAppName == appName;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(appName),
                        avatar: Icon(
                          Icons.apps,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedAppName = selected ? appName : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Divider
              const Divider(height: 1),

              // Actions list for selected app
              Expanded(
                child: _selectedAppName == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select an app above',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'to view its preventive actions',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildActionsList(_selectedAppName!),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionsList(String appName) {
    return Consumer<PreventiveProvider>(
      builder: (context, provider, child) {
        final items = provider.preventiveItems
            .where((item) => item.appName == appName)
            .toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No actions for $appName',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add a preventive action',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showAddEditDialog(item: item, appName: appName),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.build,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.action,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteItem(item),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
