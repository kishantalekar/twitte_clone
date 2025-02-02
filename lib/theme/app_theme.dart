import 'package:flutter/material.dart';
import 'package:twitte_clone/theme/pallete.dart';

class AppTheme {
  static ThemeData theme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Pallete.backgroundColor,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Pallete.blueColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
  );
}
