// class KeyGenerator {
//   static String generate(String text) {
//     return text
//         .toLowerCase()
//         .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
//         .split(' ')
//         .where((e) => e.isNotEmpty)
//         .map((e) => e[0].toUpperCase() + e.substring(1))
//         .join()
//         .replaceFirstMapped(
//           RegExp(r'^[A-Z]'),
//           (m) => m.group(0)!.toLowerCase(),
//         );
//   }
// }

import 'dart:convert';
import 'package:crypto/crypto.dart';

class KeyGenerator {
  static String generate(String text) {
    final trimmed = text.trim();

    // 1️⃣ If ASCII English → human readable key
    if (_isAscii(trimmed)) {
      return _camelCase(trimmed);
    }

    // 2️⃣ Non-English → stable hash key
    final hash = md5.convert(utf8.encode(trimmed)).toString().substring(0, 6);
    return 'text_$hash';
  }

  static bool _isAscii(String input) {
    return input.codeUnits.every((c) => c < 128);
  }

  static String _camelCase(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join()
        .replaceFirstMapped(
          RegExp(r'^[A-Z]'),
          (m) => m.group(0)!.toLowerCase(),
        );
  }
}
