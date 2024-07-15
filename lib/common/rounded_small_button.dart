import 'package:flutter/material.dart';

class RoundedSmallButton extends StatelessWidget {
  const RoundedSmallButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onTap;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          label: Text(
            label,
            style: TextStyle(
              color: textColor,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: backgroundColor),
    );
  }
}
