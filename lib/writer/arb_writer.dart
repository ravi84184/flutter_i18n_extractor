import 'dart:convert';
import 'dart:io';

class ArbWriter {
  /// Writes the ARB file by **merging** the new entries with existing ones.
  ///
  /// - Existing keys are **kept** (we don't overwrite manual changes).
  /// - New keys from [data] are **added only if they don't already exist**.
  static void write(Map<String, String> data) {
    final dir = Directory('lib/l10n');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final file = File('${dir.path}/app_en.arb');

    final Map<String, dynamic> existing = {};

    if (file.existsSync()) {
      try {
        final raw = file.readAsStringSync();
        if (raw.trim().isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            existing.addAll(decoded);
          }
        }
      } catch (_) {
        // If parsing fails, we just treat it as empty and regenerate.
      }
    }

    // Start with existing keys
    final Map<String, String> merged = {};
    existing.forEach((key, value) {
      if (value is String) {
        merged[key] = value;
      } else if (value != null) {
        merged[key] = value.toString();
      }
    });

    // Add only keys that don't already exist
    data.forEach((key, value) {
      merged.putIfAbsent(key, () => value);
    });

    final json = JsonEncoder.withIndent('  ').convert(merged);
    file.writeAsStringSync(json);

    print('✅ app_en.arb updated');
  }
}
