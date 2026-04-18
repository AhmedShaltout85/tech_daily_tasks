import 'package:flutter/material.dart';
import 'package:tasks_app/utils/app_colors.dart';

// ignore: must_be_immutable
class CustomTextFiled extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color? color;
  bool? obscureText;
  final Widget? suffixIcon;
  final Widget prefixIcon;
  final TextInputType? textInputType;
  final TextStyle? hintStyle;
  final double? padding;
  CustomTextFiled({
    super.key,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.color,
    this.suffixIcon,
    this.textInputType,
    this.hintStyle,
    this.obscureText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 36.0),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.lightGrayColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                hintStyle ??
                TextStyle(color: AppColors.grayColor, fontSize: 16),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }
}
