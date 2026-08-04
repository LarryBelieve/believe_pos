import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BelievePOS());
}

class BelievePOS extends StatelessWidget {
  const BelievePOS({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}