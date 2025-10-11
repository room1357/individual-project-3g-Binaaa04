import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track your Money',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey
      ),
      home: const LoginScreen(),
    );
  }
  
}
