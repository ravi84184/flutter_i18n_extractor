import 'dart:convert';
import 'dart:io';

class ArbWriter {
  static void write(Map<String, String> data) {
    final dir = Directory('lib/l10n');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final file = File('${dir.path}/app_en.arb');

    final json = JsonEncoder.withIndent('  ').convert(data);
    file.writeAsStringSync(json);

    print('✅ app_en.arb generated');
  }
}
