import 'dart:io';

import 'package:flutter_i18n_extractor/replacer/replace_visitor.dart';
import 'package:flutter_i18n_extractor/utils/key_generator.dart';
import 'package:flutter_i18n_extractor/utils/string_filter.dart';
import 'package:flutter_i18n_extractor/writer/locale_writer.dart';
import 'package:flutter_i18n_extractor/initializer/main_initializer.dart';

import '../lib/scanner/file_scanner.dart';
import '../lib/scanner/ast_parser.dart';

void main(List<String> args) {
  if (Directory.current.path.endsWith('flutter_i18n_extractor')) {
    print(
      '⚠️ You are running the extractor inside its own package.\n'
      '👉 Run it inside a Flutter app instead.',
    );
  }

  final paths = FileScanner.scanFlutterLib();

  final parser = AstParser(paths);
  final Set<String> allTexts = {};

  for (final path in paths) {
    allTexts.addAll(parser.extractStrings(path));
  }

  print('📝 Found ${allTexts.length} strings');
  allTexts.forEach(print);

  final Map<String, String> locale = {};

  for (final text in allTexts) {
    final normalized = _normalizePlaceholders(text);

    if (!StringFilter.isValid(normalized)) continue;

    final key = KeyGenerator.generate(normalized);
    locale[key] = normalized;
  }

  LocaleWriter.write(locale);
  final stringToKey = parseAppLocale();
  print(stringToKey);

  for (final path in paths) {
    replaceStringsInFile(path, stringToKey);
  }
  // Ensure FlutterLocalization initialization exists in main()
  MainInitializer.ensureInitialization();
}

/// Normalize Dart interpolations like `$value` / `${value}` into `%a` placeholders.
String _normalizePlaceholders(String input) {
  var result = input;

  // `${...}` style
  result = result.replaceAll(RegExp(r'\$\{[^}]+\}'), '%a');

  // `$variable` style
  result = result.replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), '%a');

  // Collapse multiple `%a` with optional spaces into a single `%a`
  result = result.replaceAll(RegExp(r'(%a\s*)+'), '%a ');

  return result.trim();
}
