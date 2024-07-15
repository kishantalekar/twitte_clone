import 'package:flutter/material.dart';
import 'package:twitte_clone/theme/theme.dart';

class AuthField extends StatelessWidget {
  const AuthField({super.key, required this.controller, required this.title});

  final TextEditingController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: title,
        hintStyle: const TextStyle(fontSize: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Pallete.greyColor, width: 2.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Pallete.blueColor,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding: const EdgeInsets.all(22),
      ),
    );
  }
}
