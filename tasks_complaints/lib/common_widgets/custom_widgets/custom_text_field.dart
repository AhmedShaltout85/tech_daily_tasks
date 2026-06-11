import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final String? initialValue;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      initialValue: initialValue,
      onSaved: onSaved,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
    );
  }
}
