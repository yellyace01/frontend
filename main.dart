import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(BarangaySystemApp());
}

class BarangaySystemApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barangay Management System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
