import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/common_widgets/resuable_widgets/reusable_toast.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/controller/user_provider.dart';
import 'package:tasks_app/screens/about_app/manage_about_app_screen.dart';
import 'package:tasks_app/screens/places/manage_place_screen.dart';
import 'package:tasks_app/screens/report/report_screen.dart';
import 'package:tasks_app/screens/settings/settings_screen.dart';
import 'package:tasks_app/screens/user/manage_user_screen.dart';

class CustomDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onIndexChanged;

  const CustomDrawer({
    super.key,
    this.selectedIndex = 1,
    this.onIndexChanged,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _selectedIndex;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    // Get provider reference at init time
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = themeProvider.isDark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = userProvider.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [colorScheme.surface, colorScheme.surface.withOpacity(0.95)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(
                isDark,
                colorScheme,
                currentUser?.displayName ?? 'User',
                currentUser?.username ?? ''),
            Expanded(
              child: FadeTransition(
                opacity: _animation,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(
                      context,
                      index: 1,
                      icon: Icons.task,
                      title: 'Dashboard',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        widget.onIndexChanged?.call(1);
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      index: 2,
                      icon: Icons.people_rounded,
                      title: 'Manage Users',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () async {
                        setState(() => _selectedIndex = 2);
                        widget.onIndexChanged?.call(2);
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageUserScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      index: 3,
                      icon: Icons.apps_outage,
                      title: 'Manage Apps',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () async {
                        setState(() => _selectedIndex = 4);
                        widget.onIndexChanged?.call(4);
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageAboutAppScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      index: 4,
                      icon: Icons.location_on_rounded,
                      title: 'Manage Places',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () async {
                        setState(() => _selectedIndex = 4);
                        widget.onIndexChanged?.call(4);
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManagePlaceScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      index: 5,
                      icon: Icons.assessment_rounded,
                      title: 'Reports',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () {
                        setState(() => _selectedIndex = 5);
                        widget.onIndexChanged?.call(5);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      index: 6,
                      icon: isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      title: isDark ? 'Light Mode' : 'Dark Mode',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () {
                        setState(() => _selectedIndex = 6);
                        widget.onIndexChanged?.call(6);
                        Navigator.pop(context);
                        themeProvider.toggleTheme();
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      index: 7,
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onTap: () {
                        setState(() => _selectedIndex = 7);
                        widget.onIndexChanged?.call(7);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildLogoutSection(isDark, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark, ColorScheme colorScheme,
      String displayName, String username) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.primary,
                  colorScheme.secondary.withOpacity(0.9),
                ]
              : [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.9),
                  colorScheme.secondary.withOpacity(0.7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'user_avatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 38,
                backgroundColor: isDark ? colorScheme.surface : Colors.white,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: isDark
                      ? colorScheme.primaryContainer
                      : colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            displayName,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  username,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.home_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required bool isDark,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withOpacity(0.2)
                        : isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? colorScheme.primary
                        : isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            _showLogoutDialog(context, isDark, colorScheme);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Clear user data and navigate
              _userProvider.clearUserData();
              ReusableToast.showToast(
                message: 'Logged out successfully',
                bgColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
