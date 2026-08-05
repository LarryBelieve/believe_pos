import 'package:flutter/material.dart';
import 'themes/app_theme.dart'; // Make sure this import is correct
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      theme: AppTheme.light, // ✅ Changed from lightTheme to light
      darkTheme: AppTheme.dark, // ✅ Changed from darkTheme to dark
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
