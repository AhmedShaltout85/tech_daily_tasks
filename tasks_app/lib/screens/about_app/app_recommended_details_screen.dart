import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/about_app_provider.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/services/connectivity_service.dart';

class AppRecommendedDetailsScreen extends StatefulWidget {
  final String appName;
  final int appId;

  const AppRecommendedDetailsScreen({
    super.key,
    required this.appName,
    required this.appId,
  });

  @override
  State<AppRecommendedDetailsScreen> createState() =>
      _AppRecommendedDetailsScreenState();
}

class _AppRecommendedDetailsScreenState
    extends State<AppRecommendedDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ConnectivityService _connectivity = ConnectivityService();
  List<String> _recommendedItems = [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }
    await context.read<AboutAppProvider>().fetchAllAboutApps();
    final provider = context.read<AboutAppProvider>();
    final aboutApp = provider.aboutApps.firstWhere(
      (a) => a.appName == widget.appName,
      orElse: () => throw Exception('App not found'),
    );
    setState(() {
      _recommendedItems = aboutApp.recommended ?? [];
    });
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
    final recommendedController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Add Recommended'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: recommendedController,
            decoration: const InputDecoration(
              labelText: 'Recommended Value',
              hintText: 'Enter recommended value',
              prefixIcon: Icon(Icons.thumb_up_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter recommended value';
              }
              return null;
            },
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
                await _addRecommended(recommendedController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecommended(String recommended) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    // Get existing recommended list and add the new one
    final provider = context.read<AboutAppProvider>();
    final aboutApp = provider.aboutApps.firstWhere(
      (a) => a.appName == widget.appName,
      orElse: () => throw Exception('App not found'),
    );

    final currentRecommended = List<String>.from(aboutApp.recommended ?? []);
    currentRecommended.add(recommended);

    await provider.updateAboutApp(
      aboutApp.id!,
      widget.appName,
      aboutApp.department ?? 'IT',
      currentRecommended,
    );
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
          message: 'Recommended added successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
        _fetchData();
      }
    }
  }

  void _showEditDialog(int index, String currentRecommended) {
    final recommendedController =
        TextEditingController(text: currentRecommended);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Colors.orange),
            SizedBox(width: 12),
            Text('Edit Recommended'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: recommendedController,
            decoration: const InputDecoration(
              labelText: 'Recommended Value',
              hintText: 'Enter recommended value',
              prefixIcon: Icon(Icons.thumb_up_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter recommended value';
              }
              return null;
            },
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
                await _updateRecommended(
                  index,
                  recommendedController.text.trim(),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRecommended(int index, String recommended) async {
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      _showNoInternetDialog();
      return;
    }

    final provider = context.read<AboutAppProvider>();
    final aboutApp = provider.aboutApps.firstWhere(
      (a) => a.appName == widget.appName,
      orElse: () => throw Exception('App not found'),
    );

    // Update the specific recommended value at index
    final currentRecommended = List<String>.from(aboutApp.recommended ?? []);
    if (index < currentRecommended.length) {
      currentRecommended[index] = recommended;
    }

    await provider.updateAboutApp(
      aboutApp.id!,
      widget.appName,
      aboutApp.department ?? 'IT',
      currentRecommended,
    );
    // Trigger sync - notify AppNameProvider to refresh

    if (mounted) {
      final newProvider = context.read<AboutAppProvider>();
      if (newProvider.error != null) {
        ReusableToast.showToast(
          message: newProvider.error!,
          bgColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
        newProvider.clearError();
      } else {
        ReusableToast.showToast(
          message: 'Recommended updated successfully',
          bgColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16,
        );
        _fetchData();
      }
    }
  }

  Future<void> _showDeleteConfirmation(int index, String recommended) async {
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
            Text('Delete Recommended'),
          ],
        ),
        content: Text('Are you sure you want to delete "$recommended"?'),
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
      final provider = context.read<AboutAppProvider>();
      final aboutApp = provider.aboutApps.firstWhere(
        (a) => a.appName == widget.appName,
        orElse: () => throw Exception('App not found'),
      );

      await provider.deleteAboutApp(aboutApp.id!);
      // Trigger sync - notify AppNameProvider to refresh

      if (mounted) {
        final newProvider = context.read<AboutAppProvider>();
        if (newProvider.error != null) {
          ReusableToast.showToast(
            message: newProvider.error!,
            bgColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16,
          );
          newProvider.clearError();
        } else {
          ReusableToast.showToast(
            message: 'Recommended deleted successfully',
            bgColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16,
          );
          _fetchData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final appColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName),
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

          final aboutApps = provider.aboutApps
              .where((a) => a.appName == widget.appName)
              .toList();

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
                        child: Icon(Icons.thumb_up, color: appColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recommended Values',
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
                          '${aboutApps.length}',
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
                  child: aboutApps.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_up_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recommended values yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _showAddDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Recommended'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: aboutApps.length,
                            itemBuilder: (context, index) {
                              final aboutApp = aboutApps[index];
                              return _buildRecommendedCard(
                                aboutApp,
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

  Widget _buildRecommendedCard(
    dynamic aboutApp,
    int index,
    bool isDark,
    ColorScheme colorScheme,
    Color appColor,
  ) {
    // Use the state's _recommendedItems list for displaying
    final recommendedValue =
        index < _recommendedItems.length ? _recommendedItems[index] : '';

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
            recommendedValue,
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
                'Recommended',
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
                  onPressed: () => _showEditDialog(index, recommendedValue),
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
                  onPressed: () =>
                      _showDeleteConfirmation(index, recommendedValue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
