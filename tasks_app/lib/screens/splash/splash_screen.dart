import 'package:flutter/material.dart';
import 'package:tasks_app/common_widgets/custom_widgets/custom_text.dart';
import 'package:tasks_app/utils/app_assets.dart';
import 'package:tasks_app/utils/app_colors.dart';
import 'package:tasks_app/utils/app_route.dart';

import '../../common_widgets/resuable_widgets/resuable_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
 
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        navigateToReplacementNamed(context, AppRoute.loginRouteName);
        // navigateToReplacementNamed(context, AppRoute.authWrapperRouteName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final kHeight = size.height;
    final kWidth = size.width;
    final double fontSize = 18;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: kHeight * 0.0,
            child: Image.asset(
              AppAssets.taskSplashLogo,
              height: kHeight * 0.8,
              width: kWidth * 0.8,
              fit: BoxFit.fill,
            ),
          ),

          Positioned(
            top: kHeight * 0.85,
            child: CustomText(
              text: 'قطاع التكنولوجيا والخدمات الرقمية',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),

          Positioned(
            top: kHeight * 0.9,
            left: kWidth * 0.1,
            right: kWidth * 0.1,
            child: CustomText(
              text: 'إدارة البرامج وصيانتها',
              fontSize: fontSize - 2,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.normal,
              color: AppColors.grayColor,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
