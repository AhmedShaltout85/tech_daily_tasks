import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/screens/about_app/app_recommended_details_screen.dart';
import 'package:tasks_app/services/connectivity_service.dart';

class ManageAboutAppScreen extends StatefulWidget {
  const ManageAboutAppScreen({super.key});

  @override
  State<ManageAboutAppScreen> createState() => _ManageAboutAppScreenState();
}

class _ManageAboutAppScreenState extends State<ManageAboutAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible
    _fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void _onAppNameChanged() {
    if (mounted) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }
    await context.read<AboutAppProvider>().fetchAllAboutApps();
    _animationController.forward();
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet'),
        content: const Text(
          'No internet found. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final appNameController = TextEditingController();
    final recommendedController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Add About App'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: appNameController,
                decoration: const InputDecoration(
                  labelText: 'App Name',
                  hintText: 'Enter app name',
                  prefixIcon: Icon(Icons.apps),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter app name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: recommendedController,
                decoration: const InputDecoration(
                  labelText: 'Recommended (optional)',
                  hintText: 'Enter recommended value',
                  prefixIcon: Icon(Icons.thumb_up_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                final recommended = recommendedController.text.trim();
                await _addAboutApp(
                  appNameController.text.trim(),
                  recommended.isNotEmpty ? [recommended] : [],
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAboutApp(String appName, List<String> recommended) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    await context
        .read<AboutAppProvider>()
        .addAboutApp(appName, 'IT', recommended);
    // Trigger sync - notify AppNameProvider to refresh

    if (mounted) {
      final provider = context.read<AboutAppProvider>();
      if (provider.error != null) {
        ReusableToast.showToast(
          message: provider.error!,
          bgColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
        provider.clearError();
      } else {
        ReusableToast.showToast(
          message: 'About app added successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
        _fetchData();
      }
    }
  }

  void _showEditDialog(dynamic aboutApp) {
    final appNameController = TextEditingController(text: aboutApp.appName);
    final recommendedText = aboutApp.recommended is List
        ? (aboutApp.recommended as List).join(', ')
        : aboutApp.recommended?.toString() ?? '';
    final recommendedController = TextEditingController(text: recommendedText);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Colors.orange),
            SizedBox(width: 12),
            Text('Edit About App'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: appNameController,
                decoration: const InputDecoration(
                  labelText: 'App Name',
                  hintText: 'Enter app name',
                  prefixIcon: Icon(Icons.apps),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter app name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: recommendedController,
                decoration: const InputDecoration(
                  labelText: 'Recommended (optional)',
                  hintText: 'Enter recommended values (comma separated)',
                  prefixIcon: Icon(Icons.thumb_up_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                final recommended = recommendedController.text.trim();
                final recommendedList = recommended.isNotEmpty
                    ? recommended.split(',').map((e) => e.trim()).toList()
                    : <String>[];
                await _updateAboutApp(
                  int.tryParse(aboutApp.id.toString()) ?? 0,
                  appNameController.text.trim(),
                  recommendedList,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAboutApp(
      int id, String appName, List<String> recommended) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    await context
        .read<AboutAppProvider>()
        .updateAboutApp(id, appName, 'IT', recommended);
    // Trigger sync - notify AppNameProvider to refresh

    if (mounted) {
      final provider = context.read<AboutAppProvider>();
      if (provider.error != null) {
        ReusableToast.showToast(
          message: provider.error!,
          bgColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
        provider.clearError();
      } else {
        ReusableToast.showToast(
          message: 'About app updated successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
        _fetchData();
      }
    }
  }

  Future<void> _showDeleteConfirmation(dynamic aboutApp) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete About App'),
          ],
        ),
        content: Text('Are you sure you want to delete "${aboutApp.appName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = int.tryParse(aboutApp.id.toString());
      if (id != null) {
        await context.read<AboutAppProvider>().deleteAboutApp(id);
        // Trigger sync - notify AppNameProvider to refresh
      }

      if (mounted) {
        final provider = context.read<AboutAppProvider>();
        if (provider.error != null) {
          ReusableToast.showToast(
            message: provider.error!,
            bgColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16,
          );
          provider.clearError();
        } else {
          ReusableToast.showToast(
            message: 'About app deleted successfully',
            bgColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16,
          );
          _fetchData();
        }
      }
    }
  }

  Map<String, List<dynamic>> _groupByAppName(List<dynamic> aboutApps) {
    final Map<String, List<dynamic>> grouped = {};
    for (var app in aboutApps) {
      if (grouped.containsKey(app.appName)) {
        grouped[app.appName]!.add(app);
      } else {
        grouped[app.appName] = [app];
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final appColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Applications'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showAddDialog,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.add,
                    color: isDark ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AboutAppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.aboutApps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedApps = _groupByAppName(provider.aboutApps);
          final appNames = groupedApps.keys.toList();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.info_outline, color: appColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'About Apps',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: appColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${appNames.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: appNames.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No about apps added yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _showAddDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add About App'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: appNames.length,
                            itemBuilder: (context, index) {
                              final appName = appNames[index];
                              final apps = groupedApps[appName]!;
                              return _buildAppCard(
                                appName,
                                apps.length,
                                index,
                                isDark,
                                colorScheme,
                                appColor,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppCard(
    String appName,
    int recommendedCount,
    int index,
    bool isDark,
    ColorScheme colorScheme,
    Color appColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: Colors.grey.shade800) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: appColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            appName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '$recommendedCount recommended value${recommendedCount != 1 ? 's' : ''}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    final provider = context.read<AboutAppProvider>();
                    final apps = provider.aboutApps
                        .where((a) => a.appName == appName)
                        .toList();
                    if (apps.isNotEmpty) {
                      _showEditDialog(apps.first);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    final provider = context.read<AboutAppProvider>();
                    final apps = provider.aboutApps
                        .where((a) => a.appName == appName)
                        .toList();
                    if (apps.isNotEmpty) {
                      _showDeleteConfirmation(apps.first);
                    }
                  },
                ),
              ),
            ],
          ),
          onTap: () async {
            final provider = context.read<AboutAppProvider>();
            final apps =
                provider.aboutApps.where((a) => a.appName == appName).toList();
            if (apps.isNotEmpty) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppRecommendedDetailsScreen(
                    appName: appName,
                    appId: apps.first.id!,
                  ),
                ),
              );
              _fetchData();
            }
          },
        ),
      ),
    );
  }
}
