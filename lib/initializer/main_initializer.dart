import 'dart:io';
import 'package:yaml/yaml.dart';

class MainInitializer {
  static void ensureInitialization() {
    _fixMainDart();
    _ensureFlutterLocalizationDependency();
  }

  static void _fixMainDart() {
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('⚠️ lib/main.dart not found');
      return;
    }
    var content = mainFile.readAsStringSync();

    // Ensure 'package:flutter/material.dart' import
    if (!content.contains("package:flutter/material.dart")) {
      content = "import 'package:flutter/material.dart';\n" + content;
    }

    // Ensure 'package:flutter_localization/flutter_localization.dart' import
    if (!content.contains(
      "package:flutter_localization/flutter_localization.dart",
    )) {
      content =
          "import 'package:flutter_localization/flutter_localization.dart';\n" +
          content;
    }

    // Ensure WidgetsFlutterBinding.ensureInitialized();
    final mainFuncPattern = RegExp(
      r'Future<void>\s+main\s*\([^)]*\)\s+async\s*\{',
    );
    final match = mainFuncPattern.firstMatch(content);
    if (match != null) {
      final bodyStart = match.end;
      final afterMain = content.substring(bodyStart);
      if (!afterMain.contains('WidgetsFlutterBinding.ensureInitialized();')) {
        // Insert after opening {
        content = content.replaceFirst(
          mainFuncPattern,
          '${match.group(0)}\n  WidgetsFlutterBinding.ensureInitialized();',
        );
      }
      if (!afterMain.contains(
        'await FlutterLocalization.instance.ensureInitialized();',
      )) {
        content = content.replaceFirst(
          mainFuncPattern,
          '${match.group(0)}\n  await FlutterLocalization.instance.ensureInitialized();',
        );
      }
    }
    mainFile.writeAsStringSync(content);
    print('✅ main.dart updated for initialization.');
  }

  static void _ensureFlutterLocalizationDependency() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('⚠️ pubspec.yaml not found');
      return;
    }
    final lines = pubspecFile.readAsLinesSync();
    bool found = false;
    final newLines = <String>[];
    var inDependencies = false;
    for (final line in lines) {
      newLines.add(line);
      if (line.trim() == 'dependencies:') {
        inDependencies = true;
      }
      if (inDependencies && line.contains('flutter_localization')) {
        found = true;
      }
      if (inDependencies && line.trim().isEmpty) {
        if (!found) {
          newLines.add('  flutter_localization: any');
          found = true;
        }
        inDependencies = false;
      }
    }
    if (!found) {
      // dependencies: was never found or no empty line after
      for (int i = 0; i < newLines.length; i++) {
        if (newLines[i].trim() == 'dependencies:') {
          newLines.insert(i + 1, '  flutter_localization: any');
          break;
        }
      }
    }
    pubspecFile.writeAsStringSync(newLines.join('\n'));
    print('✅ flutter_localization ensured in pubspec.yaml.');
  }
}
