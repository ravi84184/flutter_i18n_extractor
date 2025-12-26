import 'dart:io';
import 'package:path/path.dart' as p;

class FileScanner {
  static List<String> scanFlutterLib() {
    final cwd = Directory.current.path;
    final libPath = p.normalize(p.join(cwd, 'lib'));
    final libDir = Directory(libPath);

    if (!libDir.existsSync()) {
      throw Exception(
        '❌ lib/ folder not found.\n'
        '👉 Run this command inside a Flutter project root.',
      );
    }

    return libDir
        .listSync(recursive: true)
        .whereType<File>()
        // Only Dart files
        .where((f) => f.path.endsWith('.dart'))
        // Exclude generated localization mixin / l10n Dart files
        .where((f) {
          final relative = p.relative(f.path, from: libPath);
          // Ignore anything under lib/l10n/ (including app_locale.dart)
          if (relative.startsWith('l10n${p.separator}')) return false;
          return true;
        })
        .map((f) => p.normalize(p.absolute(f.path)))
        .toList();
  }
}
