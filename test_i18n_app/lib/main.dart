import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

Future<void> main() async {
  await FlutterLocalization.instance.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String textString = "textString";
  final String textString1 = "textString1";
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: Builder(
          builder: (context) {
            final String textString2 = "textString2";
            return Column(
              children: [
                Text(
                  "Welcome Back $textString test $textString2 and $textString",
                ),
                Text("Login"),
                Text("Invalid OTP"),
                Text("Invalid OTP"),
                Text("Invalid OTP"),
              ],
            );
          },
        ),
      ),
    );
  }
}
