import 'package:flutter/material.dart';
import 'package:shining/theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? kPrimary : kBackground,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : kTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
