import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? hint;
  final List<String> items;
  final String? value;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final IconData? icon;

  const CustomDropdown({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    this.value,
    this.validator,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
