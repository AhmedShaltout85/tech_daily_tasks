import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CustomLoading extends StatelessWidget {
  final double size;
  final Color color;

  const CustomLoading({
    super.key,
    this.size = 40,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
