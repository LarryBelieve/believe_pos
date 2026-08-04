import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const BelievePOS());
}

class BelievePOS extends StatelessWidget {
  const BelievePOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Believe POS',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}