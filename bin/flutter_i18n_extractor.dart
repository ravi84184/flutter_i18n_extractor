import 'dart:io';

import 'package:flutter_i18n_extractor/utils/key_generator.dart';
import 'package:flutter_i18n_extractor/utils/string_filter.dart';
import 'package:flutter_i18n_extractor/writer/arb_writer.dart';

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

  final Map<String, String> arb = {};

  for (final text in allTexts) {
    if (!StringFilter.isValid(text)) continue;

    final key = KeyGenerator.generate(text);
    arb[key] = text;
  }

  ArbWriter.write(arb);
}
