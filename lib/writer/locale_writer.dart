import 'dart:io';

class LocaleWriter {
  /// Writes the locale mixin file by **merging** the new entries with existing ones.
  ///
  /// - Existing keys and translations are **kept** (we don't overwrite manual changes).
  /// - New keys from [data] are **added only if they don't already exist**.
  static void write(Map<String, String> data) {
    final dir = Directory('lib/l10n');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final file = File('${dir.path}/app_locale.dart');

    // Parse existing file if it exists
    final Map<String, Map<String, String>> existingTranslations = {};
    final Set<String> existingKeys = {};

    if (file.existsSync()) {
      try {
        final parsed = _parseExistingMixin(file.readAsStringSync());
        existingTranslations.addAll(parsed.translations);
        existingKeys.addAll(parsed.keys);
      } catch (e) {
        // If parsing fails, we just treat it as empty and regenerate.
        print('⚠️ Could not parse existing mixin: $e');
      }
    }

    // Start with existing translations
    final Map<String, Map<String, String>> allTranslations = {};
    existingTranslations.forEach((lang, translations) {
      allTranslations[lang] = Map<String, String>.from(translations);
    });

    // Ensure EN map exists
    if (!allTranslations.containsKey('EN')) {
      allTranslations['EN'] = {};
    }

    // Add new keys only if they don't already exist
    data.forEach((key, value) {
      if (!existingKeys.contains(key)) {
        // Add to EN map (default language)
        allTranslations['EN']![key] = value;
        existingKeys.add(key);

        // Add entries for other languages if they exist (use EN value as placeholder)
        allTranslations.forEach((lang, translations) {
          if (lang != 'EN' && !translations.containsKey(key)) {
            translations[key] = value; // Use EN value as placeholder
          }
        });
      }
    });

    // Generate the mixin code
    final code = _generateMixinCode(
      existingKeys.toList()..sort(),
      allTranslations,
    );
    file.writeAsStringSync(code);

    print('✅ app_locale.dart generated');
  }

  static _ParsedMixin _parseExistingMixin(String content) {
    final Map<String, Map<String, String>> translations = {};
    final Set<String> keys = {};

    // Extract static const String key declarations
    // Pattern: static const String keyName = 'keyName';
    // Match both single and double quotes
    final keyPattern1 = RegExp(
      r"static\s+const\s+String\s+(\w+)\s*=\s*'[\w]+';",
    );
    final keyPattern2 = RegExp(
      r'static\s+const\s+String\s+(\w+)\s*=\s*"[\w]+";',
    );
    final keyMatches1 = keyPattern1.allMatches(content);
    final keyMatches2 = keyPattern2.allMatches(content);
    for (final match in keyMatches1) {
      keys.add(match.group(1)!);
    }
    for (final match in keyMatches2) {
      keys.add(match.group(1)!);
    }

    // Extract language maps
    // Pattern: static const Map<String, dynamic> EN = { ... };
    // Use a more robust pattern that handles nested braces
    final langPattern = RegExp(
      r'static\s+const\s+Map<String,\s*dynamic>\s+(\w+)\s*=\s*\{',
      multiLine: true,
    );

    int startPos = 0;
    while (true) {
      final langMatches = langPattern.allMatches(content.substring(startPos));
      if (langMatches.isEmpty) break;
      final langMatch = langMatches.first;

      final lang = langMatch.group(1)!;
      final mapStart = startPos + langMatch.end;

      // Find the matching closing brace
      int braceCount = 1;
      int pos = mapStart;
      while (pos < content.length && braceCount > 0) {
        if (content[pos] == '{') braceCount++;
        if (content[pos] == '}') braceCount--;
        pos++;
      }

      if (braceCount == 0) {
        final mapContent = content.substring(mapStart, pos - 1);
        final langMap = <String, String>{};

        // Extract key-value pairs from the map
        // Pattern: keyName: 'value',
        // Match both single and double quotes
        final entryPattern1 = RegExp(r"(\w+):\s*'([^']*)',?");
        final entryPattern2 = RegExp(r'(\w+):\s*"([^"]*)",?');
        final entryMatches1 = entryPattern1.allMatches(mapContent);
        final entryMatches2 = entryPattern2.allMatches(mapContent);

        for (final entryMatch in entryMatches1) {
          final key = entryMatch.group(1)!;
          final value = entryMatch.group(2)!;
          langMap[key] = value;
        }
        for (final entryMatch in entryMatches2) {
          final key = entryMatch.group(1)!;
          final value = entryMatch.group(2)!;
          langMap[key] = value;
        }

        if (langMap.isNotEmpty) {
          translations[lang] = langMap;
        }
      }

      startPos = startPos + langMatch.end;
    }

    return _ParsedMixin(translations, keys);
  }

  static String _generateMixinCode(
    List<String> sortedKeys,
    Map<String, Map<String, String>> translations,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('mixin AppLocale {');

    // Generate static const String fields
    for (final key in sortedKeys) {
      buffer.writeln("  static const String $key = '$key';");
    }

    buffer.writeln();

    // Generate Map for each language
    final sortedLangs = translations.keys.toList()..sort();
    for (final lang in sortedLangs) {
      final langMap = translations[lang]!;
      buffer.writeln('  static const Map<String, dynamic> $lang = {');

      for (final key in sortedKeys) {
        final value = langMap[key] ?? '';
        // Escape single quotes in the value
        final escapedValue = value.replaceAll("'", "\\'");
        buffer.writeln("    $key: '$escapedValue',");
      }

      buffer.writeln('  };');
      if (lang != sortedLangs.last) {
        buffer.writeln();
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }
}

class _ParsedMixin {
  final Map<String, Map<String, String>> translations;
  final Set<String> keys;

  _ParsedMixin(this.translations, this.keys);
}
