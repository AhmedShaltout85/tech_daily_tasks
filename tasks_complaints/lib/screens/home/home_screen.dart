import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_route.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('شكاوى الموظفين'),
      leading: kIsWeb ? const SizedBox.shrink() : null,
      automaticallyImplyLeading: !kIsWeb,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBanner(),
          const SizedBox(height: 16),
          _buildNavigationGrid(context),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.appBarGradientStart, AppColors.appBarGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'مركز الدعم الفني',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'نحول المشاكل إلى حلول',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildDesktopGrid(context);
          }
          return _buildMobileGrid(context);
        },
      ),
    );
  }

  Widget _buildMobileGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNavCard(
            context,
            icon: Icons.smart_toy_outlined,
            title: 'تشات بوت',
            subtitle: 'تحدث مع البوت',
            route: AppRoute.chatbotChatRoute,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'شات بوت الدعم الفني',
            subtitle: 'اسأل الأسئلة الشائعة',
            route: AppRoute.chatbotRoute,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavCard(
            context,
            icon: Icons.add_circle_outline,
            title: 'إضافة شكوى',
            subtitle: 'تقديم شكوى جديدة',
            route: AppRoute.addComplaintRoute,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopGrid(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          children: [
            Expanded(
              child: _buildNavCard(
                context,
                icon: Icons.smart_toy_outlined,
                title: 'تشات بوت',
                subtitle: 'تحدث مع البوت',
                route: AppRoute.chatbotChatRoute,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNavCard(
                context,
                icon: Icons.chat_bubble_outline,
                title: 'شات بوت الدعم الفني',
                subtitle: 'اسأل الأسئلة الشائعة',
                route: AppRoute.chatbotRoute,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNavCard(
                context,
                icon: Icons.add_circle_outline,
                title: 'إضافة شكوى',
                subtitle: 'تقديم شكوى جديدة',
                route: AppRoute.addComplaintRoute,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
