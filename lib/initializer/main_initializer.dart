import 'dart:io';

class MainInitializer {
  /// Ensures FlutterLocalization.instance.ensureInitialized() is called in main()
  static void ensureInitialization() {
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('⚠️ lib/main.dart not found');
      return;
    }

    final content = mainFile.readAsStringSync();

    // Check if initialization already exists
    if (_hasInitialization(content)) {
      print('✅ FlutterLocalization initialization already exists');
      return;
    }

    // Modify the file
    final modified = _addInitialization(content);
    if (modified != null) {
      mainFile.writeAsStringSync(modified);
      print('✅ Added FlutterLocalization initialization to main()');
    } else {
      print('⚠️ Could not modify main() function');
    }
  }

  static bool _hasInitialization(String content) {
    // Check for the initialization call within main() function
    // Look for await FlutterLocalization.instance.ensureInitialized() after main() {
    final mainPattern = RegExp(
      r'void\s+main\s*\([^)]*\)\s*\{|Future<void>\s+main\s*\([^)]*\)\s+async\s*\{',
    );
    final mainMatch = mainPattern.firstMatch(content);

    if (mainMatch == null) return false;

    // Check if the call exists after main() declaration
    final afterMain = content.substring(mainMatch.end);
    return RegExp(
      r'await\s+FlutterLocalization\.instance\.ensureInitialized\(\)',
    ).hasMatch(afterMain);
  }

  static String? _addInitialization(String content) {
    // Pattern 1: void main() { ... }
    final voidMainPattern = RegExp(r'void\s+main\s*\([^)]*\)\s*\{');

    // Pattern 2: Future<void> main() async { ... }
    final futureMainPattern = RegExp(
      r'Future<void>\s+main\s*\([^)]*\)\s+async\s*\{',
    );

    String? result;

    // Try Future<void> main() async { ... } first
    if (futureMainPattern.hasMatch(content)) {
      result = content.replaceFirst(
        futureMainPattern,
        'Future<void> main() async {\n    await FlutterLocalization.instance.ensureInitialized();\n',
      );
    }
    // Try void main() { ... } and convert to async
    else if (voidMainPattern.hasMatch(content)) {
      result = content.replaceFirst(
        voidMainPattern,
        'Future<void> main() async {\n    await FlutterLocalization.instance.ensureInitialized();\n',
      );
    }

    // If we modified the content, ensure the import exists
    if (result != null) {
      result = _ensureImport(result);
    }

    return result;
  }

  static String _ensureImport(String content) {
    // Check if flutter_localization package import exists
    if (content.contains("package:flutter_localization") ||
        content.contains('package:flutter_localization')) {
      return content; // Import already exists
    }

    // Find the last import statement - match both single and double quotes
    final singleQuotePattern = RegExp(r"import\s+'[^']*';", multiLine: true);
    final doubleQuotePattern = RegExp(r'import\s+"[^"]*";', multiLine: true);

    final singleImports = singleQuotePattern.allMatches(content);
    final doubleImports = doubleQuotePattern.allMatches(content);

    // Combine and find the last one
    final allImports = <RegExpMatch>[];
    allImports.addAll(singleImports);
    allImports.addAll(doubleImports);

    if (allImports.isEmpty) {
      // No imports, add at the beginning
      final import =
          "import 'package:flutter_localization/flutter_localization.dart';\n";
      return import + content;
    }

    // Sort by position and get the last one
    allImports.sort((a, b) => a.start.compareTo(b.start));
    final lastImport = allImports.last;

    // Add after last import
    final before = content.substring(0, lastImport.end);
    final after = content.substring(lastImport.end);
    final import =
        "\nimport 'package:flutter_localization/flutter_localization.dart';\n";
    return before + import + after;
  }
}
