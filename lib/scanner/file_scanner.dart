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
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => p.normalize(p.absolute(f.path)))
        .toList();
  }
}
