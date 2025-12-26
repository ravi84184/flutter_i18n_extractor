import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String textString = "textString";
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: Column(
          children: const [
            Text("Welcome Back"),
            Text("Login"),
            Text("Invalid OTP"),
            Text("Invalid OTP"),
            Text("Invalid OTP"),
          ],
        ),
      ),
    );
  }
}
