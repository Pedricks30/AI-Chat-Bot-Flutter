import 'package:flutter/material.dart';

// light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 177, 63, 28),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

// dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 177, 63, 28),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
