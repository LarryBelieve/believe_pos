import 'package:flutter/material.dart';

import 'themes/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Believe POS',

      // Believe POS theme
      theme: AppTheme.light,

      // Dark Believe POS theme
      darkTheme: AppTheme.dark,

      // Always use the Believe POS dark design
      themeMode: ThemeMode.dark,

      home: const HomeScreen(),

      debugShowCheckedModeBanner: false,
    );
  }
}
